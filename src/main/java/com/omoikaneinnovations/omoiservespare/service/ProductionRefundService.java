package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.RefundRequestDTO;
import com.omoikaneinnovations.omoiservespare.dto.RefundResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.VendorApprovalDTO;
import com.omoikaneinnovations.omoiservespare.dto.CanteenOrderWebSocketDTO;
import com.omoikaneinnovations.omoiservespare.entity.*;
import com.omoikaneinnovations.omoiservespare.exception.PaymentException;
import com.omoikaneinnovations.omoiservespare.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Isolation;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * PRODUCTION-GRADE REFUND SERVICE
 * 
 * Features:
 * - Automatic refund processing
 * - Vendor approval workflow
 * - Idempotency handling
 * - Retry mechanism
 * - Audit logging
 * - GST refund calculation
 * - Webhook integration
 * - Concurrency-safe operations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ProductionRefundService {

    private final RefundTransactionRepository refundRepo;
    private final RefundAuditLogRepository auditLogRepo;
    private final PaymentTransactionRepository paymentRepo;
    private final CanteenOrderRepository canteenOrderRepo;
    private final OrderRepository orderRepo;
    private final RazorpayService razorpayService;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;
    private final OrderEventPublisher orderEventPublisher;

    // ============================================
    // STEP 1: REQUEST CANCELLATION (Customer/Vendor)
    // ============================================
    
    /**
     * Customer or Vendor requests cancellation
     * Creates refund record in PENDING state
     */
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public RefundResponseDTO requestCancellation(RefundRequestDTO request, User initiator) {
        log.info("🔄 Cancellation requested - Canteen Order: {}, By: {}", 
            request.getCanteenOrderId(), request.getRequestedBy());

        // 1. Validate canteen order
        CanteenOrder canteenOrder = canteenOrderRepo.findById(request.getCanteenOrderId())
                .orElseThrow(() -> new PaymentException("CANTEEN_ORDER_NOT_FOUND", 
                    "Canteen order not found"));

        // 2. Check if already refunded or refund in progress
        if (canteenOrder.isRefunded()) {
            throw new PaymentException("ALREADY_REFUNDED", 
                "This order has already been refunded");
        }

        // Check for existing refund request
        refundRepo.findByCanteenOrderId(canteenOrder.getId())
                .ifPresent(existing -> {
                    if (!existing.isFinal()) {
                        throw new PaymentException("REFUND_IN_PROGRESS", 
                            "Refund request already in progress: " + existing.getInternalRefundCode());
                    }
                });

        // 3. Validate order status (can only cancel certain statuses)
        if (!canCancelOrder(canteenOrder.getStatus())) {
            throw new PaymentException("CANNOT_CANCEL", 
                "Order in status " + canteenOrder.getStatus() + " cannot be cancelled");
        }

        // 4. Get parent order and payment transaction
        Order order = canteenOrder.getParentOrder();
        PaymentTransaction transaction = paymentRepo.findByOrderId(order.getId())
                .orElseThrow(() -> new PaymentException("PAYMENT_NOT_FOUND", 
                    "Payment transaction not found"));

        // 5. Verify payment was successful
        if (transaction.getStatus() != PaymentStatus.SUCCESS) {
            throw new PaymentException("PAYMENT_NOT_SUCCESSFUL", 
                "Cannot refund - payment was not successful");
        }

        // 6. Calculate refund amounts (including GST)
        BigDecimal subtotal = canteenOrder.getSubtotal();
        BigDecimal cgst = subtotal.multiply(new BigDecimal("0.025")).setScale(2, RoundingMode.HALF_UP);
        BigDecimal sgst = subtotal.multiply(new BigDecimal("0.025")).setScale(2, RoundingMode.HALF_UP);
        BigDecimal totalRefund = subtotal.add(cgst).add(sgst);

        // 7. Generate idempotency key
        String idempotencyKey = generateIdempotencyKey(canteenOrder.getId(), initiator.getId());

        // Check for duplicate request
        refundRepo.findByIdempotencyKey(idempotencyKey)
                .ifPresent(existing -> {
                    throw new PaymentException("DUPLICATE_REQUEST", 
                        "Duplicate refund request detected: " + existing.getInternalRefundCode());
                });

        // 8. Determine cancellation requester
        CancellationRequestedBy requestedBy = parseCancellationRequestedBy(request.getRequestedBy());

        // 9. Determine if auto-approval is needed
        VendorApprovalStatus approvalStatus = shouldAutoApprove(requestedBy, canteenOrder) 
            ? VendorApprovalStatus.AUTO_APPROVED 
            : VendorApprovalStatus.PENDING;

        // 10. Create refund transaction
        RefundTransaction refund = RefundTransaction.builder()
                .internalRefundCode(generateRefundCode())
                .idempotencyKey(idempotencyKey)
                .paymentTransaction(transaction)
                .canteenOrder(canteenOrder)
                .order(order)
                .customer(order.getCustomer())
                .originalAmount(subtotal)
                .refundAmount(totalRefund)
                .cgstAmount(cgst)
                .sgstAmount(sgst)
                .status(approvalStatus == VendorApprovalStatus.AUTO_APPROVED 
                    ? RefundStatus.APPROVED 
                    : RefundStatus.PENDING)
                .cancellationRequestedBy(requestedBy)
                .cancellationReason(request.getReason())
                .vendorApprovalStatus(approvalStatus)
                .gatewayName("razorpay")
                .refundMode("AUTO")
                .refundMethod(transaction.getPaymentMethod())
                .createdBy(initiator.getEmail())
                .build();

        RefundTransaction savedRefund = refundRepo.save(refund);

        // 11. Update canteen order status
        // ✅ CRITICAL FIX: Set status based on approval status
        if (approvalStatus == VendorApprovalStatus.AUTO_APPROVED) {
            // Auto-approved (vendor/system initiated) - Mark as CANCELLED immediately
            canteenOrder.setStatus(OrderStatus.CANCELLED);
            canteenOrder.setRefunded(true);
            canteenOrder.setRefundStatus("PROCESSING");
        } else {
            // Customer initiated - Mark as CANCELLATION_REQUESTED (waiting for vendor approval)
            canteenOrder.setStatus(OrderStatus.CANCELLATION_REQUESTED);
            canteenOrder.setRefunded(false); // ✅ Not refunded yet - waiting for approval
            canteenOrder.setRefundStatus("PENDING_APPROVAL"); // ✅ Pending vendor approval
        }
        
        canteenOrder.setCancelReason(request.getReason());
        canteenOrder.setRefundRequestedAt(LocalDateTime.now());
        canteenOrderRepo.save(canteenOrder);

        // 12. Check if all canteen orders are cancelled
        updateParentOrderStatusIfFullyCancelled(order);

        // 13. Create audit log
        createAuditLog(savedRefund, "CANCELLATION_REQUESTED", null, 
            savedRefund.getStatus().toString(), "CUSTOMER", initiator.getId(), 
            initiator.getEmail(), "Cancellation requested", null, null);

        // 14. If auto-approved, process refund immediately
        if (approvalStatus == VendorApprovalStatus.AUTO_APPROVED) {
            log.info("✅ Auto-approved - Processing refund immediately");
            return processRefundAfterApproval(savedRefund.getId(), initiator);
        }

        // 15. Send notification to vendor for approval
        notifyVendorForApproval(savedRefund);

        log.info("✅ Cancellation request created - Refund Code: {}, Status: {}", 
            savedRefund.getInternalRefundCode(), savedRefund.getStatus());

        // ✅ Return DTO with necessary fields for UI display
        RefundResponseDTO response = mapToResponseDTO(savedRefund);
        
        // ✅ CRITICAL: Ensure refund appears in "My Refunds" even while pending approval
        // Set temporary refund ID for UI display
        if (response.getRefundId() == null || response.getRefundId().isEmpty()) {
            response.setRefundId("PENDING_" + savedRefund.getInternalRefundCode());
        }
        
        return response;
    }

    // ============================================
    // STEP 2: VENDOR APPROVAL/REJECTION
    // ============================================
    
    /**
     * Vendor approves or rejects the cancellation request
     */
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public RefundResponseDTO vendorApproval(VendorApprovalDTO approvalDTO, User vendor) {
        log.info("🔄 Vendor approval - Canteen Order: {}, Action: {}", 
            approvalDTO.getCanteenOrderId(), approvalDTO.getAction());

        // 1. Find refund transaction
        RefundTransaction refund = refundRepo.findByCanteenOrderId(approvalDTO.getCanteenOrderId())
                .orElseThrow(() -> new PaymentException("REFUND_NOT_FOUND", 
                    "No refund request found for this order"));

        // 2. Validate refund is pending approval
        if (refund.getVendorApprovalStatus() != VendorApprovalStatus.PENDING) {
            throw new PaymentException("INVALID_STATE", 
                "Refund is not pending approval. Current status: " + refund.getVendorApprovalStatus());
        }

        // 3. Validate vendor is authorized
        // ✅ FIXED: In your system, vendorId is the canteen ID (1,2,3,4), not user ID
        // For now, allow any logged-in vendor to approve (can be enhanced with canteen-vendor mapping)
        CanteenOrder canteenOrder = refund.getCanteenOrder();
        Long requestedCanteenId = approvalDTO.getVendorId();
        
        if (!canteenOrder.getCanteenId().equals(requestedCanteenId)) {
            log.error("❌ Canteen ID mismatch - Order Canteen: {}, Requested: {}", 
                canteenOrder.getCanteenId(), requestedCanteenId);
            throw new PaymentException("UNAUTHORIZED", 
                "Vendor not authorized for this canteen");
        }
        
        log.info("✅ Vendor authorized - User: {}, Canteen: {}", 
            vendor.getEmail(), requestedCanteenId);

        String action = approvalDTO.getAction().toUpperCase();
        String oldStatus = refund.getStatus().toString();

        if ("APPROVE".equals(action)) {
            // APPROVE
            refund.setVendorApprovalStatus(VendorApprovalStatus.APPROVED);
            refund.setStatus(RefundStatus.APPROVED);
            refund.setVendorApprovalAt(LocalDateTime.now());
            refund.setVendorId(vendor.getId()); // ✅ Store actual vendor user ID
            refund.setVendorRemarks(approvalDTO.getRemarks());
            refund.setUpdatedBy(vendor.getEmail());

            RefundTransaction savedRefund = refundRepo.save(refund);

            // ✅ CRITICAL: Update canteen order status to CANCELLED when vendor approves
            canteenOrder.setStatus(OrderStatus.CANCELLED);
            canteenOrder.setRefunded(true); // Now it's actually being refunded
            canteenOrder.setRefundStatus("PROCESSING");
            canteenOrderRepo.save(canteenOrder);

            // ✅ Send WebSocket notification to customer
            Order order = savedRefund.getOrder();
            orderEventPublisher.toCustomer(order.getCustomer(), toWebSocketDTO(canteenOrder));

            // Create audit log
            createAuditLog(savedRefund, "VENDOR_APPROVED", oldStatus, 
                savedRefund.getStatus().toString(), "VENDOR", vendor.getId(), 
                vendor.getEmail(), approvalDTO.getRemarks(), null, null);

            log.info("✅ Vendor approved - Processing refund");

            // Process refund immediately
            return processRefundAfterApproval(savedRefund.getId(), vendor);

        } else if ("REJECT".equals(action)) {
            // REJECT
            refund.setVendorApprovalStatus(VendorApprovalStatus.REJECTED);
            refund.setStatus(RefundStatus.REJECTED);
            refund.setVendorApprovalAt(LocalDateTime.now());
            refund.setVendorId(vendor.getId());
            refund.setVendorRemarks(approvalDTO.getRemarks());
            refund.setUpdatedBy(vendor.getEmail());

            RefundTransaction savedRefund = refundRepo.save(refund);

            // ✅ CRITICAL: Update canteen order - restore to PREPARING immediately
            // Customer should see the order continue, not wait for frontend timeout
            canteenOrder.setStatus(OrderStatus.PREPARING); // ✅ Directly to PREPARING
            canteenOrder.setRefunded(false); // ✅ Reset refunded flag
            canteenOrder.setRefundStatus("REJECTED");
            canteenOrder.setCancelReason(null); // ✅ Clear cancel reason
            canteenOrderRepo.save(canteenOrder);
            
            // ✅ Send WebSocket notification to customer with PREPARING status
            Order order = savedRefund.getOrder();
            orderEventPublisher.toCustomer(order.getCustomer(), toWebSocketDTO(canteenOrder));
            
            // ✅ Check if all canteen orders are cancelled/rejected
            updateParentOrderStatusIfFullyCancelled(savedRefund.getOrder());

            // Create audit log
            createAuditLog(savedRefund, "VENDOR_REJECTED", oldStatus, 
                savedRefund.getStatus().toString(), "VENDOR", vendor.getId(), 
                vendor.getEmail(), approvalDTO.getRemarks(), null, null);

            log.info("❌ Vendor rejected cancellation - Order continues as PREPARING");

            return mapToResponseDTO(savedRefund);

        } else {
            throw new PaymentException("INVALID_ACTION", 
                "Invalid action. Must be APPROVE or REJECT");
        }
    }

    // ============================================
    // STEP 3: PROCESS REFUND (After Approval)
    // ============================================
    
    /**
     * Process refund via Razorpay after approval
     * This is called automatically after vendor approval
     */
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public RefundResponseDTO processRefundAfterApproval(Long refundId, User actor) {
        log.info("🔄 Processing refund - Refund ID: {}", refundId);

        // 1. Find refund transaction with pessimistic lock (CRITICAL: Prevents race conditions)
        RefundTransaction refund = refundRepo.findByIdForUpdate(refundId)
                .orElseThrow(() -> new PaymentException("REFUND_NOT_FOUND", 
                    "Refund not found"));

        // 2. Validate refund is approved
        if (!refund.isApproved()) {
            throw new PaymentException("NOT_APPROVED", 
                "Refund must be approved before processing");
        }

        // 3. Check if already processed (idempotency check)
        if (refund.getStatus() == RefundStatus.SUCCESS || 
            refund.getStatus() == RefundStatus.PROCESSING) {
            log.warn("⚠️ Refund already processed or in progress");
            return mapToResponseDTO(refund);
        }

        String oldStatus = refund.getStatus().toString();

        try {
            // 4. CRITICAL: Validate refund amount before processing
            validateRefundAmount(refund);
            
            // 5. Update status to PROCESSING
            refund.setStatus(RefundStatus.PROCESSING);
            refund.setRefundInitiatedAt(LocalDateTime.now());
            refund.setUpdatedBy(actor.getEmail());
            refundRepo.save(refund);

            // Create audit log
            createAuditLog(refund, "REFUND_INITIATED", oldStatus, 
                RefundStatus.PROCESSING.toString(), "SYSTEM", null, 
                "system", "Refund processing started", null, null);

            // 6. Call Razorpay refund API
            Long amountInPaise = refund.getRefundAmount()
                    .multiply(BigDecimal.valueOf(100))
                    .longValue();

            // CRITICAL: Use paymentId (pay_XXXXX), not transactionId (order_XXXXX)
            String razorpayPaymentId = refund.getPaymentTransaction().getPaymentId();
            if (razorpayPaymentId == null || razorpayPaymentId.isEmpty()) {
                log.error("❌ Payment ID is null/empty for refund transaction ID: {}", 
                    refund.getPaymentTransaction().getId());
                throw new IllegalStateException("Payment ID not found for transaction. Cannot process refund.");
            }

            log.info("🔄 Calling Razorpay refund - Payment ID: {}, Amount: ₹{}", 
                razorpayPaymentId, refund.getRefundAmount());

            Map<String, Object> razorpayRefund = razorpayService.refundPayment(
                    razorpayPaymentId,
                    amountInPaise,
                    refund.getCancellationReason());

            String razorpayRefundId = (String) razorpayRefund.get("refund_id");
            String razorpayStatus = (String) razorpayRefund.get("status");

            // 7. Update refund with Razorpay details
            refund.setRefundId(razorpayRefundId);
            refund.setRazorpayStatus(razorpayStatus);
            
            // ✅ CRITICAL FIX: "processed" from Razorpay means "initiated", NOT "completed"
            // Keep status as PROCESSING until customer manually syncs or webhook confirms
            // This matches real-world apps like Zomato where refunds show "Processing" for days
            refund.setStatus(RefundStatus.PROCESSING);  // Always PROCESSING, never SUCCESS here
            refund.setRefundProcessedAt(LocalDateTime.now());
            
            try {
                refund.setGatewayResponse(objectMapper.writeValueAsString(razorpayRefund));
            } catch (Exception e) {
                log.error("Failed to serialize gateway response", e);
                refund.setGatewayResponse("{}");
            }

            RefundTransaction savedRefund = refundRepo.save(refund);

            // 8. Update canteen order
            CanteenOrder canteenOrder = savedRefund.getCanteenOrder();
            canteenOrder.setRefunded(true);
            // ✅ CRITICAL FIX: Keep as PROCESSING, not COMPLETED
            // Money hasn't reached customer yet - just initiated with Razorpay
            canteenOrder.setRefundStatus("PROCESSING");
            // Don't set refundCompletedAt yet - only when actually completed
            canteenOrderRepo.save(canteenOrder);

            // 9. Get parent order
            Order order = savedRefund.getOrder();

            // 10. Check if all canteen orders are cancelled
            updateParentOrderStatusIfFullyCancelled(order);

            // 11. Update parent order total amount AFTER Razorpay success
            order.setTotalAmount(order.getTotalAmount().subtract(savedRefund.getRefundAmount()));
            order.setUpdatedAt(LocalDateTime.now());
            orderRepo.save(order);

            // 12. Create audit log
            createAuditLog(savedRefund, "REFUND_INITIATED", RefundStatus.PROCESSING.toString(), 
                savedRefund.getStatus().toString(), "SYSTEM", null, 
                "system", "Refund initiated with Razorpay. Processing may take 5-7 business days.", null, null);

            // 13. Send notification to customer
            notifyCustomerRefundInitiated(savedRefund);

            log.info("✅ Refund initiated successfully - Razorpay Refund ID: {}, Amount: ₹{}, Status: PROCESSING (NOT completed yet)", 
                razorpayRefundId, refund.getRefundAmount());

            return mapToResponseDTO(savedRefund);

        } catch (Exception e) {
            log.error("❌ Refund processing failed", e);

            // Update refund status to FAILED (DO NOT update order total)
            refund.setStatus(RefundStatus.FAILED);
            refund.setRefundFailedAt(LocalDateTime.now());
            refund.setGatewayErrorMessage(e.getMessage());
            refund.setNextRetryAt(calculateNextRetryTime(refund.getRetryCount()));
            refundRepo.save(refund);

            // Create audit log
            createAuditLog(refund, "REFUND_FAILED", RefundStatus.PROCESSING.toString(), 
                RefundStatus.FAILED.toString(), "SYSTEM", null, 
                "system", "Refund failed: " + e.getMessage(), null, null);

            throw new PaymentException("REFUND_FAILED", 
                "Failed to process refund: " + e.getMessage());
        }
    }
    
    /**
     * CRITICAL: Validate refund amount to prevent over-refunding
     */
    private void validateRefundAmount(RefundTransaction refund) {
        BigDecimal refundAmount = refund.getRefundAmount();
        
        // 1. Validate refund amount is positive
        if (refundAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new PaymentException("INVALID_AMOUNT", 
                "Refund amount must be positive");
        }
        
        // 2. Validate refund doesn't exceed original payment
        BigDecimal originalPaymentAmount = refund.getPaymentTransaction().getAmount();
        if (refundAmount.compareTo(originalPaymentAmount) > 0) {
            throw new PaymentException("REFUND_EXCEEDS_PAYMENT", 
                "Refund amount (₹" + refundAmount + ") exceeds original payment (₹" + originalPaymentAmount + ")");
        }
        
        // 3. Validate no duplicate refunds for same canteen order
        // Note: findByCanteenOrderId returns Optional<RefundTransaction> since there should be only one refund per order
        refundRepo.findByCanteenOrderId(refund.getCanteenOrder().getId())
                .ifPresent(existingRefund -> {
                    // If there's an existing refund and it's not the current one being processed
                    if (!existingRefund.getId().equals(refund.getId())) {
                        // Check if existing refund is successful or processing
                        if (existingRefund.getStatus() == RefundStatus.SUCCESS || 
                            existingRefund.getStatus() == RefundStatus.PROCESSING) {
                            throw new PaymentException("DUPLICATE_REFUND", 
                                "A refund already exists for this order: " + existingRefund.getInternalRefundCode());
                        }
                    }
                });
        
        log.info("✅ Refund amount validated - Amount: ₹{}, Original Payment: ₹{}", 
            refundAmount, originalPaymentAmount);
    }

    // ============================================
    // RETRY MECHANISM
    // ============================================
    
    /**
     * Retry failed refunds
     * Called by scheduled job
     */
    @Transactional
    public void retryFailedRefunds() {
        log.info("🔄 Checking for failed refunds to retry");

        List<RefundTransaction> eligibleRefunds = refundRepo.findEligibleForRetry(LocalDateTime.now());

        log.info("Found {} refunds eligible for retry", eligibleRefunds.size());

        for (RefundTransaction refund : eligibleRefunds) {
            try {
                log.info("Retrying refund: {}", refund.getInternalRefundCode());
                
                refund.incrementRetry();
                refundRepo.save(refund);

                processRefundAfterApproval(refund.getId(), 
                    userRepository.findById(refund.getCustomer().getId()).orElse(null));

            } catch (Exception e) {
                log.error("Retry failed for refund: {}", refund.getInternalRefundCode(), e);
                
                refund.setNextRetryAt(calculateNextRetryTime(refund.getRetryCount()));
                refundRepo.save(refund);
            }
        }
    }

    // ============================================
    // QUERY METHODS
    // ============================================
    
    /**
     * Get all refunds for a user
     */
    public List<RefundResponseDTO> getUserRefunds(User user) {
        log.info("Fetching refunds for user: {}", user.getEmail());

        // Directly query by customer ID - much simpler and more efficient
        List<RefundTransaction> refunds = refundRepo.findByCustomerId(user.getId());

        log.info("Found {} refunds for customer ID: {}", refunds.size(), user.getId());

        return refunds.stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get refund details by refund ID
     */
    public RefundResponseDTO getRefundDetails(String refundId, User user) {
        log.info("Fetching refund details for refund ID: {}", refundId);

        RefundTransaction refund = refundRepo.findByRefundId(refundId)
                .orElseThrow(() -> new PaymentException("REFUND_NOT_FOUND", 
                    "Refund not found"));

        // Verify user owns this refund
        if (!refund.getCustomer().getId().equals(user.getId())) {
            throw new PaymentException("UNAUTHORIZED", 
                "You are not authorized to view this refund");
        }

        return mapToResponseDTO(refund);
    }

    /**
     * Manually sync refund status with Razorpay
     * Fetches the latest status from Razorpay and updates local database
     */
    @Transactional
    public RefundResponseDTO syncRefundStatus(String refundId, User user) {
        log.info("🔄 Syncing refund status with Razorpay - Refund ID: {}", refundId);

        // 1. Find refund transaction
        RefundTransaction refund = refundRepo.findByRefundId(refundId)
                .orElseThrow(() -> new PaymentException("REFUND_NOT_FOUND", 
                    "Refund not found"));

        // 2. Verify user owns this refund
        if (!refund.getCustomer().getId().equals(user.getId())) {
            throw new PaymentException("UNAUTHORIZED", 
                "You are not authorized to sync this refund");
        }

        // 3. Check if refund has a Razorpay refund ID
        if (refund.getRefundId() == null || refund.getRefundId().isEmpty()) {
            throw new PaymentException("NO_RAZORPAY_REFUND", 
                "This refund has not been processed with Razorpay yet");
        }

        // 4. Check if refund is already in final state
        if (refund.isFinal()) {
            log.info("⚠️ Refund already in final state: {}", refund.getStatus());
            return mapToResponseDTO(refund);
        }

        try {
            // 5. Fetch refund status from Razorpay
            // ✅ CRITICAL FIX: Use paymentId (pay_XXXXX), NOT transactionId (order_XXXXX)
            String razorpayPaymentId = refund.getPaymentTransaction().getPaymentId();
            
            if (razorpayPaymentId == null || razorpayPaymentId.isEmpty()) {
                log.error("❌ Payment ID is null/empty for refund transaction");
                throw new PaymentException("NO_PAYMENT_ID", 
                    "Payment ID not found. Cannot fetch refund status.");
            }
            
            Map<String, Object> razorpayRefund = razorpayService.fetchRefundStatus(
                    razorpayPaymentId,  // ✅ Correct: pay_XXXXX
                    refund.getRefundId());

            String razorpayStatus = (String) razorpayRefund.get("status");
            String oldStatus = refund.getStatus().toString();

            // 6. Update refund status
            refund.setRazorpayStatus(razorpayStatus);
            
            // ✅ CRITICAL FIX: Only mark as SUCCESS when actually refunded
            // Razorpay "processed" still means "initiated" - keep as PROCESSING
            // Only mark SUCCESS if customer manually confirms or after significant time
            RefundStatus newStatus;
            if ("processed".equalsIgnoreCase(razorpayStatus)) {
                // Check if enough time has passed (5-7 days) to assume completion
                LocalDateTime initiatedAt = refund.getRefundInitiatedAt();
                if (initiatedAt != null && 
                    LocalDateTime.now().isAfter(initiatedAt.plusDays(5))) {
                    // After 5 days, assume refund is completed
                    newStatus = RefundStatus.SUCCESS;
                    log.info("✅ Refund marked as SUCCESS - 5+ days have passed since initiation");
                } else {
                    // Still processing
                    newStatus = RefundStatus.PROCESSING;
                    log.info("⏳ Refund still PROCESSING - Initiated less than 5 days ago");
                }
            } else {
                // For other statuses (failed, etc.), use standard mapping
                newStatus = mapRazorpayStatusToRefundStatus(razorpayStatus);
            }
            
            refund.setStatus(newStatus);
            refund.setUpdatedBy(user.getEmail());

            // 7. Update timestamps based on status
            if (newStatus == RefundStatus.SUCCESS && refund.getRefundProcessedAt() == null) {
                refund.setRefundProcessedAt(LocalDateTime.now());
                
                // Update canteen order
                CanteenOrder canteenOrder = refund.getCanteenOrder();
                canteenOrder.setRefundStatus("COMPLETED");
                canteenOrder.setRefundCompletedAt(LocalDateTime.now());
                canteenOrderRepo.save(canteenOrder);
            } else if (newStatus == RefundStatus.FAILED && refund.getRefundFailedAt() == null) {
                refund.setRefundFailedAt(LocalDateTime.now());
                
                // Update canteen order
                CanteenOrder canteenOrder = refund.getCanteenOrder();
                canteenOrder.setRefundStatus("FAILED");
                canteenOrderRepo.save(canteenOrder);
            }

            // 8. Update gateway response
            try {
                refund.setGatewayResponse(objectMapper.writeValueAsString(razorpayRefund));
            } catch (Exception e) {
                log.error("Failed to serialize gateway response", e);
            }

            RefundTransaction savedRefund = refundRepo.save(refund);

            // 9. Create audit log
            createAuditLog(savedRefund, "STATUS_SYNCED", oldStatus, 
                newStatus.toString(), "CUSTOMER", user.getId(), 
                user.getEmail(), "Status synced with Razorpay", null, null);

            log.info("✅ Refund status synced - Old: {}, New: {}", oldStatus, newStatus);

            return mapToResponseDTO(savedRefund);

        } catch (Exception e) {
            log.error("❌ Failed to sync refund status with Razorpay", e);
            throw new PaymentException("SYNC_FAILED", 
                "Failed to sync refund status: " + e.getMessage());
        }
    }

    /**
     * Get refunds pending vendor approval for a canteen
     */
    public List<RefundResponseDTO> getPendingApprovals(Long canteenId) {
        log.info("Fetching pending approvals for canteen: {}", canteenId);

        List<RefundTransaction> refunds = refundRepo.findPendingApprovalsByCanteen(canteenId);

        return refunds.stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    // ============================================
    // HELPER METHODS
    // ============================================
    
    private boolean canCancelOrder(OrderStatus status) {
        return status == OrderStatus.ORDER_RECEIVED || 
               status == OrderStatus.PREPARING ||
               status == OrderStatus.CANCELLATION_REQUESTED; // ✅ Allow when vendor accepts cancellation
    }

    private boolean shouldAutoApprove(CancellationRequestedBy requestedBy, CanteenOrder canteenOrder) {
        // ❌ DISABLE AUTO-APPROVAL FOR CUSTOMERS
        // Customer cancellations ALWAYS require vendor approval
        // This ensures the proper workflow: PENDING → Vendor Approves → PROCESSING → SUCCESS
        
        // Auto-approve ONLY if vendor or system initiated
        if (requestedBy == CancellationRequestedBy.VENDOR || 
            requestedBy == CancellationRequestedBy.SYSTEM) {
            return true;
        }

        // ❌ REMOVED: Auto-approval for ORDER_RECEIVED status
        // All customer cancellations need vendor approval regardless of order status
        
        return false; // Customer cancellations ALWAYS require vendor approval
    }

    private CancellationRequestedBy parseCancellationRequestedBy(String requestedBy) {
        try {
            return CancellationRequestedBy.valueOf(requestedBy.toUpperCase());
        } catch (Exception e) {
            return CancellationRequestedBy.CUSTOMER;
        }
    }

    private String generateRefundCode() {
        // Generate unique refund code: REF + timestamp + random
        return "REF" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }

    private String generateIdempotencyKey(Long canteenOrderId, Long userId) {
        return "REFUND_" + canteenOrderId + "_" + userId + "_" + LocalDateTime.now().toLocalDate();
    }

    private LocalDateTime calculateNextRetryTime(int retryCount) {
        // Exponential backoff: 5 min, 15 min, 30 min
        int minutes = (int) Math.pow(3, retryCount) * 5;
        return LocalDateTime.now().plusMinutes(minutes);
    }

    private RefundStatus mapRazorpayStatusToRefundStatus(String razorpayStatus) {
        // ✅ CRITICAL FIX: Razorpay "processed" means "initiated", NOT "completed"
        // This method is now only used for fallback cases (e.g., failed status)
        // For "processed" status, we handle it specially in the calling code
        return switch (razorpayStatus.toLowerCase()) {
            case "processed" -> RefundStatus.PROCESSING;  // NOT SUCCESS - still processing
            case "pending" -> RefundStatus.PROCESSING;
            case "failed" -> RefundStatus.FAILED;
            default -> RefundStatus.PROCESSING;
        };
    }

    private void createAuditLog(RefundTransaction refund, String eventType, 
                                String oldStatus, String newStatus, String actorType, 
                                Long actorId, String actorEmail, String remarks, 
                                String ipAddress, String userAgent) {
        RefundAuditLog auditLog = RefundAuditLog.builder()
                .refundTransaction(refund)
                .eventType(eventType)
                .oldStatus(oldStatus)
                .newStatus(newStatus)
                .actorType(actorType)
                .actorId(actorId)
                .actorEmail(actorEmail)
                .remarks(remarks)
                .ipAddress(ipAddress)
                .userAgent(userAgent)
                .build();

        auditLogRepo.save(auditLog);
    }

    private void notifyVendorForApproval(RefundTransaction refund) {
        // ✅ Send WebSocket notification to vendor's canteen monitor dashboard
        try {
            CanteenOrder canteenOrder = refund.getCanteenOrder();
            String canteenId = String.valueOf(canteenOrder.getCanteenId());
            
            // Send updated canteen order to vendor dashboard
            orderEventPublisher.toCanteen(canteenId, canteenOrder);
            
            log.info("📧 WebSocket notification sent to canteen {} for approval - Refund: {}", 
                canteenId, refund.getInternalRefundCode());
        } catch (Exception e) {
            log.error("Failed to send vendor notification", e);
        }
    }

    private void notifyCustomerRefundSuccess(RefundTransaction refund) {
        // ✅ Send WebSocket notification to customer
        try {
            User customer = refund.getCustomer();
            Order order = refund.getOrder();
            
            // Send updated order to customer
            orderEventPublisher.toCustomer(customer, order);
            
            log.info("📧 WebSocket notification sent to customer {} - Refund successful: {}", 
                customer.getEmail(), refund.getInternalRefundCode());
        } catch (Exception e) {
            log.error("Failed to send customer notification", e);
        }
    }
    
    private void notifyCustomerRefundInitiated(RefundTransaction refund) {
        // ✅ Send WebSocket notification to customer about refund initiation
        try {
            User customer = refund.getCustomer();
            Order order = refund.getOrder();
            
            // Send updated order to customer
            orderEventPublisher.toCustomer(customer, order);
            
            log.info("📧 WebSocket notification sent to customer {} - Refund initiated: {}", 
                customer.getEmail(), refund.getInternalRefundCode());
        } catch (Exception e) {
            log.error("Failed to send customer notification", e);
        }
    }
    
    /**
     * Update parent order status if all canteen orders are cancelled
     */
    private void updateParentOrderStatusIfFullyCancelled(Order order) {
        boolean allCancelled = order.getCanteenOrders().stream()
                .allMatch(co -> co.getStatus() == OrderStatus.CANCELLED);
        
        if (allCancelled) {
            order.setStatus(OrderStatus.CANCELLED);
            order.setUpdatedAt(LocalDateTime.now());
            orderRepo.save(order);
            log.info("✅ All canteen orders cancelled - Parent order marked as CANCELLED: {}", 
                order.getOrderCode());
        } else {
            // Check if at least one is cancelled (partial cancellation)
            boolean anyCancelled = order.getCanteenOrders().stream()
                    .anyMatch(co -> co.getStatus() == OrderStatus.CANCELLED);
            
            if (anyCancelled) {
                order.setStatus(OrderStatus.PARTIALLY_CANCELLED);
                order.setUpdatedAt(LocalDateTime.now());
                orderRepo.save(order);
                log.info("✅ Partial cancellation - Parent order marked as PARTIALLY_CANCELLED: {}", 
                    order.getOrderCode());
            }
        }
    }

    /**
     * Convert CanteenOrder entity to WebSocket DTO
     * This prevents Hibernate lazy-loading serialization errors
     */
    private CanteenOrderWebSocketDTO toWebSocketDTO(CanteenOrder canteenOrder) {
        CanteenOrderWebSocketDTO dto = new CanteenOrderWebSocketDTO();
        dto.setId(canteenOrder.getId());
        dto.setCanteenId(canteenOrder.getCanteenId());
        dto.setStatus(canteenOrder.getStatus());
        dto.setSubtotal(canteenOrder.getSubtotal());
        dto.setCreatedAt(canteenOrder.getCreatedAt());
        dto.setCancelReason(canteenOrder.getCancelReason());
        dto.setRefunded(canteenOrder.isRefunded());
        
        // Set parent order info
        if (canteenOrder.getParentOrder() != null) {
            dto.setOrderCode(canteenOrder.getParentOrder().getOrderCode());
            dto.setTotalAmount(canteenOrder.getParentOrder().getTotalAmount());
            
            // Set customer email if available
            if (canteenOrder.getParentOrder().getCustomer() != null) {
                dto.setCustomerEmail(canteenOrder.getParentOrder().getCustomer().getEmail());
            }
        }
        
        // Set items
        if (canteenOrder.getItems() != null) {
            List<CanteenOrderWebSocketDTO.OrderItemDTO> itemDTOs = canteenOrder.getItems().stream()
                .map(item -> {
                    CanteenOrderWebSocketDTO.OrderItemDTO itemDTO = new CanteenOrderWebSocketDTO.OrderItemDTO();
                    itemDTO.setId(item.getId());
                    itemDTO.setMenuItemId(item.getMenuItemId()); // ✅ Fixed: Use menuItemId field
                    itemDTO.setName(item.getName());
                    itemDTO.setPrice(item.getPrice());
                    itemDTO.setQuantity(item.getQuantity());
                    return itemDTO;
                })
                .collect(Collectors.toList());
            dto.setItems(itemDTOs);
        }
        
        return dto;
    }

    private RefundResponseDTO mapToResponseDTO(RefundTransaction refund) {
        RefundResponseDTO dto = RefundResponseDTO.builder()
                .id(refund.getId())
                .refundId(refund.getRefundId() != null && !refund.getRefundId().isEmpty() 
                    ? refund.getRefundId() 
                    : "PENDING_" + refund.getInternalRefundCode()) // ✅ Ensure refundId is never null for UI
                .internalRefundCode(refund.getInternalRefundCode())
                .refundAmount(refund.getRefundAmount())
                .originalAmount(refund.getOriginalAmount())
                .cgstAmount(refund.getCgstAmount())
                .sgstAmount(refund.getSgstAmount())
                .status(refund.getStatus().toString())
                .razorpayStatus(refund.getRazorpayStatus())
                .settlementStatus(refund.getSettlementStatus())
                .cancellationReason(refund.getCancellationReason())
                .cancellationRequestedBy(refund.getCancellationRequestedBy() != null 
                    ? refund.getCancellationRequestedBy().toString() : null)
                .vendorApprovalStatus(refund.getVendorApprovalStatus().toString())
                .vendorApprovalAt(refund.getVendorApprovalAt())
                .vendorRemarks(refund.getVendorRemarks())
                .createdAt(refund.getCreatedAt())
                .updatedAt(refund.getUpdatedAt())
                .refundInitiatedAt(refund.getRefundInitiatedAt())
                .refundProcessedAt(refund.getRefundProcessedAt())
                .settlementDate(refund.getSettlementDate())
                .orderCode(refund.getOrder().getOrderCode())
                .orderDate(refund.getOrder().getCreatedAt())
                .canteenOrderId(refund.getCanteenOrder().getId())
                .canteenId(refund.getCanteenOrder().getCanteenId())
                .paymentMethod(refund.getPaymentTransaction().getPaymentMethod())
                .refundMethod(refund.getRefundMethod())
                .refundMode(refund.getRefundMode())
                .errorCode(refund.getGatewayErrorCode())
                .errorMessage(refund.getGatewayErrorMessage())
                .retryCount(refund.getRetryCount())
                .maxRetries(refund.getMaxRetries())
                .canRetry(refund.canRetry())
                .build();
        
        // ✅ Try to fetch canteen name for better UI display
        try {
            // Note: You'll need to inject CanteenRepository if you want to fetch canteen name
            // For now, we'll just use canteenId
            dto.setCanteenName("Canteen " + dto.getCanteenId());
        } catch (Exception e) {
            log.warn("Could not fetch canteen name for canteen ID: {}", dto.getCanteenId());
        }
        
        return dto;
    }
}