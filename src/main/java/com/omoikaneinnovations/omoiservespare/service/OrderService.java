package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.CartItem;
import com.omoikaneinnovations.omoiservespare.entity.Order;
import com.omoikaneinnovations.omoiservespare.entity.OrderItem;
import com.omoikaneinnovations.omoiservespare.entity.OrderStatus;
import com.omoikaneinnovations.omoiservespare.entity.PaymentStatus;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.MenuItemRepository;
import com.omoikaneinnovations.omoiservespare.repository.OrderRepository;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import jakarta.transaction.Transactional;
import com.omoikaneinnovations.omoiservespare.repository.CanteenOrderRepository;
import com.omoikaneinnovations.omoiservespare.dto.RefundRequestDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import java.util.Map;
import org.springframework.stereotype.Service;
import com.omoikaneinnovations.omoiservespare.dto.CanteenOrderDTO;
import com.omoikaneinnovations.omoiservespare.dto.OrderItemDTO;
import com.omoikaneinnovations.omoiservespare.dto.OrderResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.CanteenOrderWebSocketDTO;
import com.omoikaneinnovations.omoiservespare.entity.CanteenOrder;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {

    private final OrderRepository repo;
    private final OrderEventPublisher publisher;
    private final CartService cartService;
    private final MenuItemRepository menuItemRepository;
    private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
    private final CanteenOrderRepository canteenOrderRepo;
    private final OrderCodeGeneratorService orderCodeGenerator;
    private final ProductionRefundService refundService;
    private final UserRepository userRepository;

    /*
     * ==============================
     * PLACE ORDER
     * ==============================
     */
    public OrderResponseDTO placeOrder(User user) {
        return placeOrder(user, null); // Default to null, will be set during payment confirmation
    }
    
    /*
     * ==============================
     * PLACE ORDER WITH PAYMENT METHOD
     * ==============================
     */
    public OrderResponseDTO placeOrder(User user, String paymentMethod) {

        String email = user.getEmail();
        Order order = new Order();
        order.setCustomer(user);
        List<CartItem> cart = cartService.getCartRaw(email);

        if (cart == null || cart.isEmpty())
            throw new RuntimeException("Cart empty");

        // Generate order code based on payment method (if provided) or use temporary UUID
        if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
            order.setOrderCode(orderCodeGenerator.generateOrderCode(paymentMethod));
            order.setPaymentMethod(paymentMethod);
            // For cash orders, mark as success immediately
            if ("CASH".equalsIgnoreCase(paymentMethod) || "COD".equalsIgnoreCase(paymentMethod)) {
                order.setPaymentStatus(PaymentStatus.SUCCESS);
                order.setStatus(OrderStatus.ORDER_RECEIVED); // Cash orders go directly to ORDER_RECEIVED
            } else {
                order.setPaymentStatus(PaymentStatus.PENDING);
                order.setStatus(OrderStatus.PENDING); // Online orders stay PENDING until payment
            }
        } else {
            // Use temporary UUID, will be replaced during payment confirmation
            order.setOrderCode(UUID.randomUUID().toString());
            order.setPaymentStatus(PaymentStatus.PENDING);
            order.setStatus(OrderStatus.PENDING); // Stay PENDING until payment confirmed
        }
        
        order.setCreatedAt(LocalDateTime.now());

        Map<Long, List<CartItem>> grouped = cart.stream()
                .collect(Collectors.groupingBy(
                        item -> menuItemRepository
                                .findById(item.getMenuItemId())
                                .orElseThrow()
                                .getCanteenId()));

        BigDecimal grandTotal = BigDecimal.ZERO;
        List<CanteenOrder> canteenOrders = new ArrayList<>();

        for (Map.Entry<Long, List<CartItem>> entry : grouped.entrySet()) {

            Long canteenId = entry.getKey();
            List<CartItem> items = entry.getValue();

            CanteenOrder co = new CanteenOrder();
            co.setParentOrder(order);
            co.setCanteenId(canteenId);
            // Set status based on payment method
            if (paymentMethod != null && ("CASH".equalsIgnoreCase(paymentMethod) || "COD".equalsIgnoreCase(paymentMethod))) {
                co.setStatus(OrderStatus.ORDER_RECEIVED); // Cash orders go directly to canteen
            } else {
                co.setStatus(OrderStatus.PENDING); // Wait for payment confirmation
            }
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

                subtotal = subtotal.add(
                        oi.getPrice().multiply(BigDecimal.valueOf(oi.getQuantity())));

                orderItems.add(oi);
            }

            co.setSubtotal(subtotal);
            co.setItems(orderItems);

            grandTotal = grandTotal.add(subtotal);
            canteenOrders.add(co);
        }

        order.setTotalAmount(grandTotal);
        order.setCanteenOrders(canteenOrders);

        Order saved = repo.save(order);
        
        // For cash orders, send notifications immediately
        if (paymentMethod != null && ("CASH".equalsIgnoreCase(paymentMethod) || "COD".equalsIgnoreCase(paymentMethod))) {
            // Send WebSocket messages to each canteen
            for (CanteenOrder canteenOrder : saved.getCanteenOrders()) {
                publisher.toCanteen(String.valueOf(canteenOrder.getCanteenId()), toCanteenDTO(canteenOrder));
            }
            // Send to customer
            publisher.toCustomer(saved.getCustomer(), saved);
            // Clear cart for cash orders
            cartService.clearCart(user.getEmail());
        }

        return mapToDTO(saved);
    }

    /*
     * ==============================
     * UPDATE STATUS (Monitor / QR)
     * ==============================
     */
    public OrderResponseDTO updateStatus(String orderCode, OrderStatus next) {
        Order order = repo.findByOrderCode(orderCode)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        validateTransition(order.getStatus(), next);

        order.setStatus(next);
        order.setUpdatedAt(LocalDateTime.now());

        Order saved = repo.save(order);

        publisher.toCustomer(saved.getCustomer(), saved);
        publisher.toOrder(saved.getOrderCode(), saved);

        return mapToDTO(saved);
    }

    /**
     * Update status for a specific canteen order
     */
    @Transactional
    public CanteenOrder updateCanteenOrderStatus(Long canteenOrderId, OrderStatus next) {
        CanteenOrder canteenOrder = canteenOrderRepo.findById(canteenOrderId)
                .orElseThrow(() -> new RuntimeException("Canteen order not found"));

        validateTransition(canteenOrder.getStatus(), next);

        canteenOrder.setStatus(next);
        CanteenOrder saved = canteenOrderRepo.save(canteenOrder);

        // Re-fetch parent order to get fresh canteen order statuses (avoids stale Hibernate cache)
        Order parentOrder = repo.findById(saved.getParentOrder().getId())
                .orElseThrow(() -> new RuntimeException("Parent order not found"));

        // If all canteen orders are delivered/cancelled, mark parent as DELIVERED
        if (next == OrderStatus.DELIVERED) {
            boolean allDone = parentOrder.getCanteenOrders()
                    .stream()
                    .allMatch(co -> co.getStatus() == OrderStatus.DELIVERED
                                || co.getStatus() == OrderStatus.CANCELLED);
            if (allDone) {
                parentOrder.setStatus(OrderStatus.DELIVERED);
                repo.save(parentOrder);
            }
        }

        // Send WebSocket message to canteen
        publisher.toCanteen(String.valueOf(saved.getCanteenId()), toCanteenDTO(saved));

        // Send updated order DTO to customer (matches the format the frontend expects)
        publisher.toCustomer(parentOrder.getCustomer(), mapToDTO(parentOrder));

        return saved;
    }

    /**
     * Update canteen order status by order code (for QR scanning)
     */
    @Transactional
    public void updateCanteenOrderStatusByOrderCode(String orderCode, OrderStatus status) {
        Order order = repo.findByOrderCode(orderCode)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        // Update all canteen orders for this order
        for (CanteenOrder canteenOrder : order.getCanteenOrders()) {
            canteenOrder.setStatus(status);
            CanteenOrder saved = canteenOrderRepo.save(canteenOrder);
            
            // Send WebSocket message to canteen
            publisher.toCanteen(String.valueOf(saved.getCanteenId()), toCanteenDTO(saved));
        }

        // Send updated order to customer
        publisher.toCustomer(order.getCustomer(), order);
    }

    /*
     * ==============================
     * CUSTOMER REQUEST CANCEL
     * ==============================
     */
    public void requestCanteenCancel(Long canteenOrderId, String reason) {

        CanteenOrder co = canteenOrderRepo.findById(canteenOrderId)
                .orElseThrow(() -> new RuntimeException("Canteen order not found"));

        if (co.getStatus() != OrderStatus.ORDER_RECEIVED)
            throw new RuntimeException("Cannot cancel");

        co.setStatus(OrderStatus.CANCELLATION_REQUESTED);
        co.setCancelReason(reason);

        canteenOrderRepo.save(co);

        publisher.toCanteen(String.valueOf(co.getCanteenId()), toCanteenDTO(co));
        publisher.toCustomer(co.getParentOrder().getCustomer(), mapToDTO(co.getParentOrder()));
    }

    /*
     * ==============================
     * ACCEPT CANCELLATION
     * ==============================
     */
    public CanteenOrder acceptCanteenCancellation(Long canteenOrderId, User vendor) {
        log.info("========================================");
        log.info("ACCEPT CANCELLATION CALLED - ID: {}", canteenOrderId);
        log.info("========================================");

        CanteenOrder co = canteenOrderRepo.findById(canteenOrderId)
                .orElseThrow(() -> new RuntimeException("Canteen order not found with ID: " + canteenOrderId));

        if (co.getStatus() != OrderStatus.CANCELLATION_REQUESTED) {
            throw new RuntimeException("Cannot accept cancellation. Order status is " + co.getStatus() + 
                                     " but expected CANCELLATION_REQUESTED");
        }

        log.info("✅ Vendor accepted cancellation for canteen order: {}", canteenOrderId);
        log.info("🔍 DEBUG: Vendor: {}", vendor.getEmail());

        Order parentOrder = co.getParentOrder();
        String paymentMethod = parentOrder.getPaymentMethod();
        PaymentStatus paymentStatus = parentOrder.getPaymentStatus();

        log.info("📋 Order payment details - Method: {}, Status: {}", paymentMethod, paymentStatus);

        // Check if this is a cash order or payment not completed
        boolean isCashOrder = "CASH".equalsIgnoreCase(paymentMethod) || "COD".equalsIgnoreCase(paymentMethod);
        boolean paymentNotCompleted = paymentStatus != PaymentStatus.SUCCESS;

        if (isCashOrder || paymentNotCompleted) {
            // ✅ SIMPLE CANCELLATION (No refund needed for cash orders or unpaid orders)
            log.info("💵 Cash order or payment not completed - Simple cancellation without refund");
            
            co.setStatus(OrderStatus.CANCELLED);
            co.setRefunded(false);
            co.setRefundStatus("NOT_APPLICABLE");
            co = canteenOrderRepo.save(co);
            
            log.info("✅ Order cancelled successfully without refund processing");
            
        } else {
            // ✅ ONLINE PAYMENT - Process refund using ProductionRefundService
            log.info("💳 Online payment detected - Processing refund via Razorpay");
            
            try {
                String reason = co.getCancelReason() != null ? co.getCancelReason() : "Vendor accepted cancellation";
                
                log.info("🔄 Processing refund via ProductionRefundService - Canteen Order: {}, Reason: {}", canteenOrderId, reason);
                
                // Create refund request DTO
                RefundRequestDTO refundRequest = new RefundRequestDTO();
                refundRequest.setCanteenOrderId(canteenOrderId);
                refundRequest.setReason(reason);
                refundRequest.setRequestedBy("VENDOR"); // Vendor is accepting cancellation - will auto-approve
                
                // Request cancellation - this will:
                // 1. Auto-approve (vendor-initiated)
                // 2. Process with Razorpay immediately  
                // 3. Update canteen order status to CANCELLED
                // 4. Create refund record with SUCCESS status
                // 5. Adjust parent order total
                refundService.requestCancellation(refundRequest, vendor);
                
                // Reload canteen order to get updated status
                co = canteenOrderRepo.findById(canteenOrderId)
                        .orElseThrow(() -> new RuntimeException("Canteen order not found"));
                
                log.info("✅ Refund processed successfully - Canteen Order: {}, Status: {}, RefundStatus: {}", 
                    canteenOrderId, co.getStatus(), co.getRefundStatus());
                
            } catch (Exception e) {
                log.error("❌ Refund processing failed for canteen order: {}", canteenOrderId, e);
                log.error("❌ Exception: {}", e.getMessage(), e);
                
                // If refund fails, manually mark order as cancelled but refund failed
                co.setStatus(OrderStatus.CANCELLED);
                co.setRefunded(false);
                co.setRefundStatus("FAILED");
                co = canteenOrderRepo.save(co);
                
                log.warn("⚠️ Order cancelled but refund failed. Manual refund required.");
                // Don't re-throw - allow the cancellation to proceed even if refund fails
                // The order should still be cancelled for the vendor
            }
        }

        // ✅ STEP 2: Publish updates via WebSocket
        publisher.toCanteen(String.valueOf(co.getCanteenId()), toCanteenDTO(co));
        
        // Reload parent order to get fresh state
        Order freshParent = repo.findById(parentOrder.getId())
                .orElse(parentOrder);
        publisher.toCustomer(freshParent.getCustomer(), mapToDTO(freshParent));
        
        log.info("✅ WebSocket notifications sent for order: {}", canteenOrderId);
        return co;
    }

    /*
     * ==============================
     * REJECT CANCELLATION
     * + AUTO-RESUME AFTER DELAY
     * ==============================
     */
    public CanteenOrder rejectCanteenCancellation(Long canteenOrderId, User vendor) {

        CanteenOrder co = canteenOrderRepo.findById(canteenOrderId)
                .orElseThrow(() -> new RuntimeException("Canteen order not found with ID: " + canteenOrderId));

        if (co.getStatus() != OrderStatus.CANCELLATION_REQUESTED) {
            throw new RuntimeException("Cannot reject cancellation. Order status is " + co.getStatus() + 
                                     " but expected CANCELLATION_REQUESTED");
        }

        log.info("❌ Vendor rejected cancellation for canteen order: {}", canteenOrderId);
        log.info("🔍 DEBUG: Vendor: {}", vendor.getEmail());

        // 1️⃣ Set rejection status (NOT CANCELLED - just REJECTED)
        co.setStatus(OrderStatus.CANCELLATION_REJECTED);
        co.setRefunded(false);
        co.setRefundStatus("NOT_APPLICABLE");
        co = canteenOrderRepo.save(co);

        // 2️⃣ Send immediate WebSocket updates
        publisher.toCanteen(String.valueOf(co.getCanteenId()), toCanteenDTO(co));
        // Reload parent from DB so canteenOrders reflect the saved CANCELLATION_REJECTED status
        Order freshParent = repo.findById(co.getParentOrder().getId())
                .orElse(co.getParentOrder());
        publisher.toCustomer(freshParent.getCustomer(), mapToDTO(freshParent));

        log.info("📤 WebSocket sent CANCELLATION_REJECTED status");

        // 3️⃣ Auto resume to PREPARING after delay
        int DELAY_SECONDS = 5;

        scheduler.schedule(() -> {

            CanteenOrder delayed = canteenOrderRepo
                    .findById(canteenOrderId)
                    .orElse(null);

            if (delayed == null) {
                log.warn("⚠️ Canteen order {} not found during auto-resume", canteenOrderId);
                return;
            }

            // Only auto-resume if still in CANCELLATION_REJECTED status
            if (delayed.getStatus() != OrderStatus.CANCELLATION_REJECTED) {
                log.info("⚠️ Canteen order {} status changed to {}, skipping auto-resume", 
                    canteenOrderId, delayed.getStatus());
                return;
            }

            delayed.setStatus(OrderStatus.PREPARING);
            delayed.setCancelReason(null);

            canteenOrderRepo.save(delayed);

            log.info("🔄 Auto-resumed order {} to PREPARING", canteenOrderId);

            publisher.toCanteen(String.valueOf(delayed.getCanteenId()), toCanteenDTO(delayed));
            Order delayedParent = repo.findById(delayed.getParentOrder().getId()).orElse(null);
            if (delayedParent != null) {
                publisher.toCustomer(delayedParent.getCustomer(), mapToDTO(delayedParent));
                log.info("📤 WebSocket sent PREPARING status after auto-resume");
            }

        }, DELAY_SECONDS, TimeUnit.SECONDS);

        return co;
    }

    /*
     * ==============================
     * FETCHERS
     * ==============================
     */
    public List<CanteenOrderWebSocketDTO> getCanteenOrders(Long canteenId) {
        return canteenOrderRepo.findByCanteenIdOrderByCreatedAtDesc(canteenId)
                .stream()
                .map(this::toCanteenDTO)
                .collect(Collectors.toList());
    }

    public List<Order> getOrdersByCustomer(User customer) {
        return repo.findByCustomer(customer);
    }

    /*
     * ==============================
     * VALIDATION
     * ==============================
     */
    private void validateTransition(OrderStatus current, OrderStatus next) {
        
        // ✅ Add logging to see what's happening
        log.info("🔍 Validating transition: {} → {}", current, next);

        if (current == OrderStatus.DELIVERED) {
            throw new RuntimeException("Order already delivered");
        }

        if (current == OrderStatus.CANCELLATION_REQUESTED) {
            throw new RuntimeException("Cancellation in progress");
        }

        if (current == OrderStatus.ORDER_RECEIVED && next != OrderStatus.PREPARING) {
            log.error("❌ Invalid transition: Cannot go from ORDER_RECEIVED to {}", next);
            throw new RuntimeException("Invalid transition: ORDER_RECEIVED can only go to PREPARING");
        }

        if (current == OrderStatus.PREPARING && next != OrderStatus.PREPARED) {
            log.error("❌ Invalid transition: Cannot go from PREPARING to {}", next);
            throw new RuntimeException("Invalid transition: PREPARING can only go to PREPARED");
        }

        if (current == OrderStatus.CANCELLATION_REJECTED && next != OrderStatus.PREPARING) {
            log.error("❌ Invalid transition: Cannot go from CANCELLATION_REJECTED to {}", next);
            throw new RuntimeException("Invalid transition: CANCELLATION_REJECTED can only go to PREPARING");
        }

        if (current == OrderStatus.PREPARED && next != OrderStatus.DELIVERED) {
            log.error("❌ Invalid transition: Cannot go from PREPARED to {}", next);
            throw new RuntimeException("Invalid transition: PREPARED can only go to DELIVERED");
        }
        
        log.info("✅ Transition valid: {} → {}", current, next);
    }

    private CanteenOrderWebSocketDTO toCanteenDTO(CanteenOrder co) {
        CanteenOrderWebSocketDTO dto = new CanteenOrderWebSocketDTO();
        dto.setId(co.getId());
        dto.setCanteenId(co.getCanteenId());
        dto.setStatus(co.getStatus());
        dto.setSubtotal(co.getSubtotal());
        dto.setCreatedAt(co.getCreatedAt());
        dto.setCancelReason(co.getCancelReason());
        dto.setRefunded(co.isRefunded());
        if (co.getParentOrder() != null) {
            dto.setOrderCode(co.getParentOrder().getOrderCode());
            dto.setTotalAmount(co.getParentOrder().getTotalAmount());
            if (co.getParentOrder().getCustomer() != null) {
                dto.setCustomerEmail(co.getParentOrder().getCustomer().getEmail());
            }
        }
        if (co.getItems() != null) {
            List<CanteenOrderWebSocketDTO.OrderItemDTO> itemDTOs = co.getItems().stream().map(item -> {
                CanteenOrderWebSocketDTO.OrderItemDTO i = new CanteenOrderWebSocketDTO.OrderItemDTO();
                i.setId(item.getId());
                i.setMenuItemId(item.getMenuItemId());
                i.setName(item.getName());
                i.setPrice(item.getPrice());
                i.setQuantity(item.getQuantity());
                return i;
            }).collect(Collectors.toList());
            dto.setItems(itemDTOs);
        }
        return dto;
    }

    private OrderResponseDTO mapToDTO(Order order) {

        List<CanteenOrderDTO> canteenDTOs = new ArrayList<>();
        
        // Calculate actual order total from canteen orders (ignoring refund reductions)
        BigDecimal calculatedTotal = BigDecimal.ZERO;

        if (order.getCanteenOrders() != null) {
            for (CanteenOrder co : order.getCanteenOrders()) {

                List<OrderItemDTO> itemDTOs = new ArrayList<>();

                if (co.getItems() != null) {
                    for (OrderItem item : co.getItems()) {
                        itemDTOs.add(
                                OrderItemDTO.builder()
                                        .menuItemId(item.getMenuItemId())
                                        .name(item.getName())
                                        .price(item.getPrice())
                                        .quantity(item.getQuantity())
                                        .build());
                    }
                }
                
                // Add this canteen order's total (subtotal + GST) to the calculated total
                BigDecimal subtotal = co.getSubtotal();
                BigDecimal cgst = subtotal.multiply(new BigDecimal("0.025")).setScale(2, java.math.RoundingMode.HALF_UP);
                BigDecimal sgst = subtotal.multiply(new BigDecimal("0.025")).setScale(2, java.math.RoundingMode.HALF_UP);
                BigDecimal canteenTotal = subtotal.add(cgst).add(sgst);
                calculatedTotal = calculatedTotal.add(canteenTotal);

                canteenDTOs.add(
                        CanteenOrderDTO.builder()
                                .id(co.getId())
                                .canteenId(co.getCanteenId())
                                .status(co.getStatus() != null ? co.getStatus().name() : "UNKNOWN")
                                .subtotal(co.getSubtotal())
                                .createdAt(co.getCreatedAt())
                                .refunded(co.isRefunded())
                                .refundStatus(co.getRefundStatus())
                                .refundRequestedAt(co.getRefundRequestedAt())
                                .refundCompletedAt(co.getRefundCompletedAt())
                                .cancelReason(co.getCancelReason())
                                .items(itemDTOs)
                                .build());
            }
        }
        
        // Use calculated total instead of order.getTotalAmount() which may be reduced by refunds
        // This ensures Past Orders screen always shows the original order amount matching invoices
        return OrderResponseDTO.builder()
                .orderCode(order.getOrderCode())
                .totalAmount(calculatedTotal)  // ✅ FIX: Use calculated total from canteen orders
                .status(order.getStatus() != null ? order.getStatus().name() : "UNKNOWN")
                .createdAt(order.getCreatedAt())
                .canteenOrders(canteenDTOs)
                .paymentStatus(order.getPaymentStatus() != null ? order.getPaymentStatus().name() : "UNKNOWN")
                .paymentMethod(order.getPaymentMethod())
                .build();
    }

    public List<OrderResponseDTO> getOrdersByCustomerDTO(User customer) {

        List<Order> orders = repo.findByCustomer(customer);

        List<OrderResponseDTO> dtoList = new ArrayList<>();

        for (Order order : orders) {
            // ✅ ONLY exclude fully cancelled orders
            // Partially cancelled orders should still appear in Active orders with updated status
            if (order.getStatus() == OrderStatus.CANCELLED) {
                continue; // Skip fully cancelled orders - they appear in "My Refunds" only
            }
            
            dtoList.add(mapToDTO(order));
        }

        return dtoList;
    }

    @Transactional
    public OrderResponseDTO confirmPayment(
            String orderCode,
            String method,
            User user) {

        Order order = repo
                .findByOrderCode(orderCode)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (!order.getCustomer().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        if (order.getPaymentStatus() != PaymentStatus.PENDING) {
            throw new RuntimeException("Payment already processed");
        }

        // Generate new order code based on payment method
        String newOrderCode = orderCodeGenerator.generateOrderCode(method);
        order.setOrderCode(newOrderCode);
        
        order.setPaymentStatus(PaymentStatus.SUCCESS);
        order.setPaymentMethod(method);

        // Now allow kitchen to process
        order.setStatus(OrderStatus.ORDER_RECEIVED);

        // Update all canteen orders to ORDER_RECEIVED
        for (CanteenOrder canteenOrder : order.getCanteenOrders()) {
            canteenOrder.setStatus(OrderStatus.ORDER_RECEIVED);
        }

        Order saved = repo.save(order);

        // Send WebSocket messages to each canteen
        for (CanteenOrder canteenOrder : saved.getCanteenOrders()) {
            publisher.toCanteen(String.valueOf(canteenOrder.getCanteenId()), toCanteenDTO(canteenOrder));
        }

        // Send to customer
        publisher.toCustomer(saved.getCustomer(), saved);

        // Clear cart AFTER successful payment
        cartService.clearCart(user.getEmail());

        return mapToDTO(saved);
    }
}