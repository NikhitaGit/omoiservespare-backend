package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.*;
import com.omoikaneinnovations.omoiservespare.repository.*;
import com.omoikaneinnovations.omoiservespare.exception.PaymentException;
import com.omoikaneinnovations.omoiservespare.exception.FraudDetectedException;
import com.omoikaneinnovations.omoiservespare.dto.PaymentRequestDTO;
import com.omoikaneinnovations.omoiservespare.dto.PaymentInitResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.CanteenOrderWebSocketDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PaymentTransactionRepository paymentRepo;
    private final RefundTransactionRepository refundRepo;
    private final OrderRepository orderRepo;
    private final CanteenOrderRepository canteenOrderRepo;
    private final FraudDetectionService fraudDetectionService;
    private final ThreeDSecureService threeDSecureService;
    private final RazorpayService razorpayService;
    private final PaymentVelocityRepository velocityRepo;
    private final DeviceFingerprintRepository deviceRepo;
    private final ObjectMapper objectMapper;
    private final OrderEventPublisher orderEventPublisher;
    
    // Additional services needed for cart-based payment
    private final CartService cartService;
    private final MenuItemRepository menuItemRepository;
    private final OrderCodeGeneratorService orderCodeGenerator;
    private final UserRepository userRepository;
    private final InvoiceService invoiceService;

    /**
     * STEP 1: Initiate Payment
     * - Create payment transaction
     * - Run fraud detection
     * - Determine if 3D Secure required
     * - Create Razorpay order
     */
    @Transactional
    public PaymentInitResponseDTO initiatePayment(
            String orderCode,
            String gatewayName,
            PaymentRequestDTO request,
            String deviceId,
            String ipAddress,
            String userAgent) {

        Order order = orderRepo.findByOrderCode(orderCode)
                .orElseThrow(() -> new PaymentException("ORDER_NOT_FOUND", "Order not found"));

        // ============================================
        // 1. CHECK FOR EXISTING PAYMENT TRANSACTION
        // ============================================
        Optional<PaymentTransaction> existingTransaction = paymentRepo.findByOrderId(order.getId());
        
        if (existingTransaction.isPresent()) {
            PaymentTransaction existing = existingTransaction.get();
            
            // If payment is already successful or in progress, return existing details
            if (existing.getStatus() == PaymentStatus.PENDING || 
                existing.getStatus() == PaymentStatus.SUCCESS) {
                
                log.info("Returning existing payment transaction - Order: {}, Transaction ID: {}, Status: {}", 
                    orderCode, existing.getTransactionId(), existing.getStatus());
                
                return buildResponseFromExistingTransaction(existing);
            }
            
            // If payment failed, we can create a new one, but first delete the old one
            if (existing.getStatus() == PaymentStatus.FAILED) {
                log.info("Removing failed payment transaction for order: {}", orderCode);
                paymentRepo.delete(existing);
            }
        }

        // ============================================
        // 2. CREATE NEW PAYMENT TRANSACTION
        // ============================================
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setOrder(order);
        transaction.setGatewayName(gatewayName);
        transaction.setPaymentMethod(request.getPaymentMethod());
        transaction.setAmount(request.getAmount());
        transaction.setCurrency(request.getCurrency());
        transaction.setStatus(PaymentStatus.PENDING);
        transaction.setCreatedAt(LocalDateTime.now());

        PaymentTransaction savedTransaction = paymentRepo.save(transaction);

        // ============================================
        // 3. RUN FRAUD DETECTION
        // ============================================
        FraudDetectionLog fraudLog = fraudDetectionService.analyzePayment(
                savedTransaction,
                deviceId,
                ipAddress,
                userAgent);

        String riskLevel = fraudLog.getRiskLevel().toString();
        String action = fraudLog.getActionTaken();

        log.info("Fraud Detection Result - Risk Level: {}, Action: {}", riskLevel, action);

        // ============================================
        // 4. BLOCK IF CRITICAL RISK
        // ============================================
        if ("BLOCKED".equals(action)) {
            transaction.setStatus(PaymentStatus.FAILED);
            paymentRepo.save(transaction);
            throw new FraudDetectedException(riskLevel, fraudLog.getRiskScore().doubleValue(), 
                "Payment blocked due to fraud risk. Please contact support.");
        }

        // ============================================
        // 5. DETERMINE 3D SECURE REQUIREMENT
        // ============================================
        boolean require3DS = threeDSecureService.is3DSecureRequired(riskLevel);

        // ============================================
        // 6. CREATE RAZORPAY ORDER
        // ============================================
        Long amountInPaise = request.getAmount().multiply(BigDecimal.valueOf(100)).longValue();
        Map<String, Object> razorpayOrder = razorpayService.createOrder(
                orderCode,
                amountInPaise,
                request.getCurrency());

        String razorpayOrderId = (String) razorpayOrder.get("razorpay_order_id");
        transaction.setTransactionId(razorpayOrderId);

        try {
            transaction.setGatewayResponse(objectMapper.writeValueAsString(razorpayOrder));
        } catch (JsonProcessingException e) {
            log.error("Error serializing gateway response", e);
            transaction.setGatewayResponse("{}");
        }

        paymentRepo.save(transaction);

        // ============================================
        // 7. UPDATE DEVICE FINGERPRINT
        // ============================================
        updateDeviceFingerprint(order.getCustomer(), deviceId, ipAddress, userAgent);

        // ============================================
        // 8. UPDATE PAYMENT VELOCITY
        // ============================================
        updatePaymentVelocity(order.getCustomer(), request.getAmount());

        // ============================================
        // 9. PREPARE RESPONSE
        // ============================================
        PaymentInitResponseDTO response = new PaymentInitResponseDTO();
        response.setTransactionId(razorpayOrderId);
        response.setStatus("INITIATED");
        response.setRiskLevel(riskLevel);
        response.setRequires3DS(require3DS);
        response.setRazorpayOrderId(razorpayOrderId);

        if (require3DS) {
            ThreeDSecureService.ThreeDSecureResponse threeDSResponse = threeDSecureService.prepare3DSecure(transaction);
            response.setAuthenticationUrl(threeDSResponse.getAuthenticationUrl());
            response.setMessage("3D Secure authentication required");
        } else {
            response.setMessage("Payment initiated successfully");
        }

        log.info("Payment initiated - Order: {}, Razorpay Order ID: {}, Risk Level: {}", 
            orderCode, razorpayOrderId, riskLevel);

        return response;
    }
    /**
     * STEP 1: Initiate Payment from Cart
     * - Create order from cart items
     * - Create payment transaction
     * - Run fraud detection
     * - Determine if 3D Secure required
     * - Create Razorpay order
     */
    @Transactional
    public PaymentInitResponseDTO initiatePaymentFromCart(
            User user,
            String gatewayName,
            PaymentRequestDTO request,
            String deviceId,
            String ipAddress,
            String userAgent) {

        String email = user.getEmail();
        List<CartItem> cart = cartService.getCartRaw(email);

        if (cart == null || cart.isEmpty()) {
            throw new PaymentException("CART_EMPTY", "Cart is empty");
        }

        // ============================================
        // 1. REUSE EXISTING PENDING ORDER OR CREATE NEW
        // ============================================
        List<Order> pendingOrders = orderRepo.findByCustomerAndStatus(user, OrderStatus.PENDING);
        Order existingPendingOrder = pendingOrders.isEmpty() ? null : pendingOrders.get(0);

        // Group cart items by canteen (needed for both new and reuse paths)
        Map<Long, List<CartItem>> grouped = cart.stream()
                .collect(Collectors.groupingBy(
                        item -> menuItemRepository
                                .findById(item.getMenuItemId())
                                .orElseThrow(() -> new RuntimeException("Menu item not found: " + item.getMenuItemId()))
                                .getCanteenId()));

        BigDecimal grandTotal = BigDecimal.ZERO;

        // Calculate grand total from cart
        for (List<CartItem> items : grouped.values()) {
            for (CartItem cartItem : items) {
                grandTotal = grandTotal.add(
                        BigDecimal.valueOf(cartItem.getPrice())
                                .multiply(BigDecimal.valueOf(cartItem.getQuantity())));
            }
        }

        BigDecimal cgst = grandTotal.multiply(new BigDecimal("0.025")).setScale(2, java.math.RoundingMode.HALF_UP);
        BigDecimal sgst = grandTotal.multiply(new BigDecimal("0.025")).setScale(2, java.math.RoundingMode.HALF_UP);
        BigDecimal grandTotalWithGst = grandTotal.add(cgst).add(sgst);

        Order savedOrder;

        if (existingPendingOrder != null) {
            // Reuse existing pending order — just update the total in case cart changed
            existingPendingOrder.setTotalAmount(grandTotalWithGst);
            savedOrder = orderRepo.save(existingPendingOrder);
            log.info("Reusing existing pending order: {}", savedOrder.getOrderCode());
        } else {
            // Create a fresh order
            Order order = new Order();
            order.setCustomer(user);
            order.setOrderCode(orderCodeGenerator.generateOrderCode(request.getPaymentMethod()));
            order.setPaymentMethod(request.getPaymentMethod());
            order.setPaymentStatus(PaymentStatus.PENDING);
            order.setStatus(OrderStatus.PENDING);
            order.setCreatedAt(LocalDateTime.now());

            List<CanteenOrder> canteenOrders = new ArrayList<>();

            for (Map.Entry<Long, List<CartItem>> entry : grouped.entrySet()) {
                Long canteenId = entry.getKey();
                List<CartItem> items = entry.getValue();

                CanteenOrder co = new CanteenOrder();
                co.setParentOrder(order);
                co.setCanteenId(canteenId);
                co.setStatus(OrderStatus.PENDING);
                co.setCreatedAt(LocalDateTime.now());

                BigDecimal subtotal = BigDecimal.ZERO;
                List<OrderItem> orderItems = new ArrayList<>();

                for (CartItem cartItem : items) {
                    OrderItem oi = new OrderItem();
                    oi.setCanteenOrder(co);
                    oi.setMenuItemId(cartItem.getMenuItemId());
                    oi.setName(cartItem.getName());
                    oi.setPrice(BigDecimal.valueOf(cartItem.getPrice()));
                    oi.setQuantity(cartItem.getQuantity());
                    subtotal = subtotal.add(oi.getPrice().multiply(BigDecimal.valueOf(oi.getQuantity())));
                    orderItems.add(oi);
                }

                co.setSubtotal(subtotal);
                co.setItems(orderItems);
                canteenOrders.add(co);
            }

            order.setTotalAmount(grandTotalWithGst);
            order.setCanteenOrders(canteenOrders);
            savedOrder = orderRepo.save(order);
            log.info("Created new pending order: {}", savedOrder.getOrderCode());
        }

        // ============================================
        // 2. CREATE OR UPDATE PAYMENT TRANSACTION
        // ============================================
        PaymentTransaction transaction;
        Optional<PaymentTransaction> existingTransaction = paymentRepo.findByOrderId(savedOrder.getId());

        if (existingTransaction.isPresent()) {
            // Reuse existing transaction — update amount and reset status for retry
            transaction = existingTransaction.get();
            transaction.setAmount(grandTotalWithGst);
            transaction.setStatus(PaymentStatus.PENDING);
            transaction.setGatewayName(gatewayName);
            transaction.setPaymentMethod(request.getPaymentMethod());
            transaction.setUpdatedAt(LocalDateTime.now());
        } else {
            // Create new transaction
            transaction = new PaymentTransaction();
            transaction.setOrder(savedOrder);
            transaction.setGatewayName(gatewayName);
            transaction.setPaymentMethod(request.getPaymentMethod());
            transaction.setAmount(grandTotalWithGst);
            transaction.setCurrency(request.getCurrency());
            transaction.setStatus(PaymentStatus.PENDING);
            transaction.setCreatedAt(LocalDateTime.now());
        }

        PaymentTransaction savedTransaction = paymentRepo.save(transaction);

        // ============================================
        // 3. RUN FRAUD DETECTION
        // ============================================
        FraudDetectionLog fraudLog = fraudDetectionService.analyzePayment(
                savedTransaction,
                deviceId,
                ipAddress,
                userAgent);

        String riskLevel = fraudLog.getRiskLevel().toString();
        String action = fraudLog.getActionTaken();

        log.info("Fraud Detection Result - Risk Level: {}, Action: {}", riskLevel, action);

        // ============================================
        // 4. BLOCK IF CRITICAL RISK
        // ============================================
        if ("BLOCKED".equals(action)) {
            transaction.setStatus(PaymentStatus.FAILED);
            paymentRepo.save(transaction);
            throw new FraudDetectedException(riskLevel, fraudLog.getRiskScore().doubleValue(),
                "Payment blocked due to fraud risk. Please contact support.");
        }

        // ============================================
        // 5. DETERMINE 3D SECURE REQUIREMENT
        // ============================================
        boolean require3DS = threeDSecureService.is3DSecureRequired(riskLevel);

        // ============================================
        // 6. CREATE RAZORPAY ORDER
        // ============================================
        Long amountInPaise = grandTotalWithGst.multiply(BigDecimal.valueOf(100)).longValue();
        Map<String, Object> razorpayOrder = razorpayService.createOrder(
                savedOrder.getOrderCode(),
                amountInPaise,
                request.getCurrency());

        String razorpayOrderId = (String) razorpayOrder.get("razorpay_order_id");
        transaction.setTransactionId(razorpayOrderId);

        try {
            transaction.setGatewayResponse(objectMapper.writeValueAsString(razorpayOrder));
        } catch (JsonProcessingException e) {
            log.error("Error serializing gateway response", e);
            transaction.setGatewayResponse("{}");
        }

        paymentRepo.save(transaction);

        // ============================================
        // 7. UPDATE DEVICE FINGERPRINT
        // ============================================
        updateDeviceFingerprint(user, deviceId, ipAddress, userAgent);

        // ============================================
        // 8. UPDATE PAYMENT VELOCITY
        // ============================================
        updatePaymentVelocity(user, grandTotalWithGst);

        // ============================================
        // 9. PREPARE RESPONSE
        // ============================================
        PaymentInitResponseDTO response = new PaymentInitResponseDTO();
        response.setTransactionId(razorpayOrderId);
        response.setStatus("INITIATED");
        response.setRiskLevel(riskLevel);
        response.setRequires3DS(require3DS);
        response.setRazorpayOrderId(razorpayOrderId);
        response.setOrderCode(savedOrder.getOrderCode()); // Include order code for verification

        if (require3DS) {
            ThreeDSecureService.ThreeDSecureResponse threeDSResponse = threeDSecureService.prepare3DSecure(transaction);
            response.setAuthenticationUrl(threeDSResponse.getAuthenticationUrl());
            response.setMessage("3D Secure authentication required");
        } else {
            response.setMessage("Payment initiated successfully");
        }

        log.info("Payment initiated from cart - Order: {}, Razorpay Order ID: {}, Risk Level: {}",
            savedOrder.getOrderCode(), razorpayOrderId, riskLevel);

        return response;
    }

    /**
     * STEP 2: Verify Payment (Called after gateway callback)
     */
    @Transactional
    public void verifyPayment(
            String orderCode,
            String transactionId,
            String razorpayPaymentId,
            String razorpayOrderId,
            String signature,
            String cavv,
            String eci) {

        Order order = orderRepo.findByOrderCode(orderCode)
                .orElseThrow(() -> new PaymentException("ORDER_NOT_FOUND", "Order not found"));

        PaymentTransaction transaction = paymentRepo.findByTransactionId(transactionId)
                .orElseThrow(() -> new PaymentException("TRANSACTION_NOT_FOUND", "Transaction not found"));

        // ============================================
        // 1. VERIFY SIGNATURE
        // ============================================
        if (!razorpayService.verifyPaymentSignature(razorpayOrderId, razorpayPaymentId, signature)) {
            transaction.setStatus(PaymentStatus.FAILED);
            paymentRepo.save(transaction);
            throw new PaymentException("INVALID_SIGNATURE", "Invalid payment signature - possible tampering detected");
        }

        // ============================================
        // 2. VERIFY AMOUNT
        // ============================================
        Map<String, Object> paymentDetails = razorpayService.fetchPaymentDetails(razorpayPaymentId);
        
        // Safely convert amount - Razorpay can return Integer or Long
        Object amountObj = paymentDetails.get("amount");
        Long razorpayAmount;
        if (amountObj instanceof Integer) {
            razorpayAmount = ((Integer) amountObj).longValue();
        } else if (amountObj instanceof Long) {
            razorpayAmount = (Long) amountObj;
        } else {
            throw new PaymentException("INVALID_AMOUNT_FORMAT", "Invalid amount format from payment gateway");
        }
        
        Long expectedAmount = transaction.getAmount().multiply(BigDecimal.valueOf(100)).longValue();

        if (!razorpayAmount.equals(expectedAmount)) {
            transaction.setStatus(PaymentStatus.FAILED);
            paymentRepo.save(transaction);
            throw new PaymentException("AMOUNT_MISMATCH", "Amount mismatch - fraud detected");
        }

        // ============================================
        // 3. VERIFY 3D SECURE (if required)
        // ============================================
        if (cavv != null && eci != null) {
            threeDSecureService.verify3DSecure(transaction, cavv, eci, "success");
        }

        // ============================================
        // 4. UPDATE TRANSACTION STATUS
        // ============================================
        transaction.setStatus(PaymentStatus.SUCCESS);
        transaction.setUpdatedAt(LocalDateTime.now());
        paymentRepo.save(transaction);

        // ============================================
        // 5. UPDATE ORDER AND CANTEEN ORDERS
        // ============================================
        order.setPaymentStatus(PaymentStatus.SUCCESS);
        order.setPaymentMethod(transaction.getPaymentMethod());
        order.setStatus(OrderStatus.ORDER_RECEIVED);
        order.setUpdatedAt(LocalDateTime.now());

        // Update all canteen orders to ORDER_RECEIVED
        for (CanteenOrder canteenOrder : order.getCanteenOrders()) {
            canteenOrder.setStatus(OrderStatus.ORDER_RECEIVED);
        }

        Order savedOrder = orderRepo.save(order);

        // ============================================
        // 6. SEND WEBSOCKET MESSAGES TO CANTEENS
        // ============================================
        for (CanteenOrder canteenOrder : savedOrder.getCanteenOrders()) {
            // Create DTO to avoid circular references
            CanteenOrderWebSocketDTO dto = new CanteenOrderWebSocketDTO();
            dto.setId(canteenOrder.getId());
            dto.setCanteenId(canteenOrder.getCanteenId());
            dto.setStatus(canteenOrder.getStatus());
            dto.setSubtotal(canteenOrder.getSubtotal());
            dto.setCreatedAt(canteenOrder.getCreatedAt());
            dto.setCancelReason(canteenOrder.getCancelReason());
            dto.setRefunded(canteenOrder.isRefunded());
            
            // Parent order info
            dto.setOrderCode(savedOrder.getOrderCode());
            dto.setCustomerEmail(savedOrder.getCustomer().getEmail());
            dto.setTotalAmount(savedOrder.getTotalAmount());
            
            // Items
            if (canteenOrder.getItems() != null) {
                List<CanteenOrderWebSocketDTO.OrderItemDTO> itemDTOs = canteenOrder.getItems().stream()
                    .map(item -> {
                        CanteenOrderWebSocketDTO.OrderItemDTO itemDTO = new CanteenOrderWebSocketDTO.OrderItemDTO();
                        itemDTO.setId(item.getId());
                        itemDTO.setMenuItemId(item.getMenuItemId());
                        itemDTO.setName(item.getName());
                        itemDTO.setPrice(item.getPrice());
                        itemDTO.setQuantity(item.getQuantity());
                        return itemDTO;
                    }).collect(java.util.stream.Collectors.toList());
                dto.setItems(itemDTOs);
            }
            
            // Send to specific canteen
            orderEventPublisher.toCanteen(String.valueOf(canteenOrder.getCanteenId()), dto);
            log.info("Sent WebSocket message to canteen {} for order {}", 
                canteenOrder.getCanteenId(), orderCode);
        }

        // Send to customer (using existing DTO)
        orderEventPublisher.toCustomer(savedOrder.getCustomer(), savedOrder);

        // ============================================
        // 7. GENERATE INVOICES
        // ============================================
        try {
            invoiceService.generateInvoicesForOrder(savedOrder);
            log.info("Generated invoices for order: {}", orderCode);
        } catch (Exception e) {
            log.error("Failed to generate invoices for order {}: {}", orderCode, e.getMessage());
            // Don't fail the payment if invoice generation fails
        }

        // ============================================
        // 8. CLEAR CART AFTER SUCCESSFUL PAYMENT
        // ============================================
        cartService.clearCart(savedOrder.getCustomer().getEmail());

        log.info("Payment verified successfully - Order: {}, Transaction: {}, Razorpay Payment: {}", 
            orderCode, transactionId, razorpayPaymentId);
    }

    /**
     * STEP 3: Process Refund (for cancelled canteen orders)
     */
    @Transactional
    public void refundCanteenOrder(Long canteenOrderId, String reason) {
        CanteenOrder canteenOrder = canteenOrderRepo.findById(canteenOrderId)
                .orElseThrow(() -> new PaymentException("CANTEEN_ORDER_NOT_FOUND", "Canteen order not found"));

        Order order = canteenOrder.getParentOrder();
        PaymentTransaction transaction = paymentRepo.findByOrderId(order.getId())
                .orElseThrow(() -> new PaymentException("PAYMENT_NOT_FOUND", "Payment transaction not found"));

        // ============================================
        // 1. CALL RAZORPAY REFUND API
        // ============================================
        Long amountInPaise = canteenOrder.getSubtotal().multiply(BigDecimal.valueOf(100)).longValue();
        Map<String, Object> refundResponse = razorpayService.refundPayment(
                transaction.getTransactionId(),
                amountInPaise,
                reason);

        String refundId = (String) refundResponse.get("refund_id");

        // ============================================
        // 2. CREATE REFUND RECORD
        // ============================================
        RefundTransaction refund = new RefundTransaction();
        refund.setPaymentTransaction(transaction);
        refund.setCanteenOrder(canteenOrder);
        refund.setRefundAmount(canteenOrder.getSubtotal());
        refund.setRefundId(refundId);
        refund.setStatus(PaymentStatus.SUCCESS);
        refund.setReason(reason);
        refund.setCreatedAt(LocalDateTime.now());

        refundRepo.save(refund);

        // ============================================
        // 3. UPDATE CANTEEN ORDER
        // ============================================
        canteenOrder.setRefunded(true);
        canteenOrderRepo.save(canteenOrder);

        // ============================================
        // 4. ADJUST PARENT ORDER TOTAL
        // ============================================
        order.setTotalAmount(order.getTotalAmount().subtract(canteenOrder.getSubtotal()));
        orderRepo.save(order);

        log.info("Refund processed - Canteen Order: {}, Refund ID: {}, Amount: {}", 
            canteenOrderId, refundId, canteenOrder.getSubtotal());
    }

    // ============================================
    // WEBHOOK HANDLERS
    // ============================================

    /**
     * Handle payment.authorized webhook event
     */
    @Transactional
    public void handlePaymentAuthorized(String razorpayPaymentId, String razorpayOrderId) {
        try {
            PaymentTransaction transaction = paymentRepo.findByTransactionId(razorpayOrderId)
                    .orElseThrow(() -> new PaymentException("TRANSACTION_NOT_FOUND", "Transaction not found"));

            transaction.setStatus(PaymentStatus.SUCCESS);
            transaction.setUpdatedAt(LocalDateTime.now());
            paymentRepo.save(transaction);

            log.info("Payment authorized via webhook - Payment ID: {}, Order ID: {}", 
                razorpayPaymentId, razorpayOrderId);

        } catch (Exception e) {
            log.error("Error handling payment.authorized webhook", e);
        }
    }

    /**
     * Handle payment.failed webhook event
     */
    @Transactional
    public void handlePaymentFailed(String razorpayPaymentId, String razorpayOrderId, 
                                    String errorCode, String errorDescription) {
        try {
            PaymentTransaction transaction = paymentRepo.findByTransactionId(razorpayOrderId)
                    .orElseThrow(() -> new PaymentException("TRANSACTION_NOT_FOUND", "Transaction not found"));

            transaction.setStatus(PaymentStatus.FAILED);
            transaction.setUpdatedAt(LocalDateTime.now());
            paymentRepo.save(transaction);

            log.warn("Payment failed via webhook - Payment ID: {}, Order ID: {}, Error: {}", 
                razorpayPaymentId, razorpayOrderId, errorCode);

        } catch (Exception e) {
            log.error("Error handling payment.failed webhook", e);
        }
    }

    /**
     * Handle payment.captured webhook event
     */
    @Transactional
    public void handlePaymentCaptured(String razorpayPaymentId, String razorpayOrderId, Long amount) {
        try {
            PaymentTransaction transaction = paymentRepo.findByTransactionId(razorpayOrderId)
                    .orElseThrow(() -> new PaymentException("TRANSACTION_NOT_FOUND", "Transaction not found"));

            transaction.setStatus(PaymentStatus.SUCCESS);
            transaction.setUpdatedAt(LocalDateTime.now());
            paymentRepo.save(transaction);

            // Update order status
            Order order = transaction.getOrder();
            order.setPaymentStatus(PaymentStatus.SUCCESS);
            order.setStatus(OrderStatus.ORDER_RECEIVED);
            order.setUpdatedAt(LocalDateTime.now());
            orderRepo.save(order);

            log.info("Payment captured via webhook - Payment ID: {}, Order ID: {}, Amount: {}", 
                razorpayPaymentId, razorpayOrderId, amount);

        } catch (Exception e) {
            log.error("Error handling payment.captured webhook", e);
        }
    }

    /**
     * Handle refund.created webhook event
     */
    @Transactional
    public void handleRefundCreated(String refundId, String razorpayPaymentId, Long amount) {
        try {
            log.info("Refund created via webhook - Refund ID: {}, Payment ID: {}, Amount: {}", 
                refundId, razorpayPaymentId, amount);

            // Update refund status if needed
            // This is typically handled by the refund API call

        } catch (Exception e) {
            log.error("Error handling refund.created webhook", e);
        }
    }

    /**
     * Handle refund.failed webhook event
     */
    @Transactional
    public void handleRefundFailed(String refundId, String razorpayPaymentId, String errorCode) {
        try {
            log.warn("Refund failed via webhook - Refund ID: {}, Payment ID: {}, Error: {}", 
                refundId, razorpayPaymentId, errorCode);

            // Update refund status to failed
            // Alert admin for manual intervention

        } catch (Exception e) {
            log.error("Error handling refund.failed webhook", e);
        }
    }

    // ============================================
    // HELPER METHODS
    // ============================================

    private void updateDeviceFingerprint(User customer, String deviceId, String ipAddress, String userAgent) {
        if (deviceId == null || deviceId.isEmpty()) return;

        DeviceFingerprint device = deviceRepo.findByCustomerIdAndDeviceId(customer.getId(), deviceId)
                .orElse(new DeviceFingerprint());

        device.setCustomer(customer);
        device.setDeviceId(deviceId);
        device.setIpAddress(ipAddress);
        device.setUserAgent(userAgent);
        device.setLastUsed(LocalDateTime.now());

        if (device.getId() == null) {
            device.setCreatedAt(LocalDateTime.now());
            device.setIsTrusted(false); // Default to untrusted for new devices
        }

        deviceRepo.save(device);
    }

    private void updatePaymentVelocity(User customer, BigDecimal amount) {
        PaymentVelocity velocity = velocityRepo.findByCustomerId(customer.getId())
                .orElse(new PaymentVelocity());

        velocity.setCustomer(customer);
        velocity.setPaymentCount1h(velocity.getPaymentCount1h() != null ? velocity.getPaymentCount1h() + 1 : 1);
        velocity.setPaymentCount24h(velocity.getPaymentCount24h() != null ? velocity.getPaymentCount24h() + 1 : 1);
        velocity.setTotalAmount1h(velocity.getTotalAmount1h() != null ? velocity.getTotalAmount1h().add(amount) : amount);
        velocity.setTotalAmount24h(velocity.getTotalAmount24h() != null ? velocity.getTotalAmount24h().add(amount) : amount);
        velocity.setLastPaymentTime(LocalDateTime.now());
        velocity.setUpdatedAt(LocalDateTime.now());

        velocityRepo.save(velocity);
    }

    /**
     * Build response from existing payment transaction
     */
    private PaymentInitResponseDTO buildResponseFromExistingTransaction(PaymentTransaction transaction) {
        PaymentInitResponseDTO response = new PaymentInitResponseDTO();
        response.setTransactionId(transaction.getTransactionId());
        response.setStatus(transaction.getStatus().toString());
        response.setRiskLevel("LOW"); // Default for existing transactions
        response.setRequires3DS(false); // Assume no 3DS for existing
        response.setRazorpayOrderId(transaction.getTransactionId());
        response.setMessage("Using existing payment transaction");
        
        return response;
    }
}