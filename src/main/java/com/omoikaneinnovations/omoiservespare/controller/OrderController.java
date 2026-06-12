package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.OrderResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.CanteenOrderWebSocketDTO;
import com.omoikaneinnovations.omoiservespare.entity.OrderStatus;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import com.omoikaneinnovations.omoiservespare.entity.CanteenOrder;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService service;
    private final UserRepository userRepository;

    /*
     * =========================
     * 🛒 PLACE ORDER
     * =========================
     */
    @PostMapping
    public OrderResponseDTO placeOrder() {

        User user = getCurrentUser();

        return service.placeOrder(user);
    }
    
    /*
     * =========================
     * 🛒 PLACE ORDER WITH PAYMENT METHOD
     * =========================
     */
    @PostMapping("/with-payment")
    public OrderResponseDTO placeOrderWithPayment(@RequestParam String paymentMethod) {

        User user = getCurrentUser();

        return service.placeOrder(user, paymentMethod);
    }

    /*
     * 🔄 UPDATE STATUS
     */
    @PatchMapping("/{orderCode}/status")
    public OrderResponseDTO updateStatus(
            @PathVariable String orderCode,
            @RequestParam OrderStatus status) {

        return service.updateStatus(orderCode, status);
    }

    /*
     * 🔄 UPDATE CANTEEN ORDER STATUS
     */
    @PatchMapping("/canteen-order/{canteenOrderId}/status")
    public CanteenOrder updateCanteenOrderStatus(
            @PathVariable Long canteenOrderId,
            @RequestParam OrderStatus status) {

        return service.updateCanteenOrderStatus(canteenOrderId, status);
    }

    /*
     * 🔄 UPDATE CANTEEN ORDER STATUS BY QR CODE
     */
    @PatchMapping("/{orderCode}/canteen-status")
    public void updateCanteenOrderStatusByOrderCode(
            @PathVariable String orderCode,
            @RequestParam OrderStatus status) {

        service.updateCanteenOrderStatusByOrderCode(orderCode, status);
    }

    /*
     * 👤 MY ORDERS
     */
    @GetMapping("/me")
    public List<OrderResponseDTO> myOrders() {

        User user = getCurrentUser();

        return service.getOrdersByCustomerDTO(user);
    }

    /*
     * 🔐 HELPER
     */
    private User getCurrentUser() {

        Authentication auth = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (auth == null || !auth.isAuthenticated()) {
            throw new RuntimeException("Unauthenticated request");
        }

        String email = auth.getName();

        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    /*
     * =========================
     * ❌ REQUEST CANTEEN CANCEL
     * =========================
     */
    @PostMapping("/canteen-order/{canteenOrderId}/cancel")
    public void requestCancel(
            @PathVariable Long canteenOrderId,
            @RequestParam String reason) {

        service.requestCanteenCancel(canteenOrderId, reason);
    }

    /*
     * =========================
     * 🏪 CANTEEN DASHBOARD
     * =========================
     */
    @GetMapping("/canteen/{canteenId}")
    public List<CanteenOrderWebSocketDTO> canteenOrders(@PathVariable Long canteenId) {
        return service.getCanteenOrders(canteenId);
    }

    /*
     * =========================
     * ✅ ACCEPT CANCELLATION
     * =========================
     */
    @PatchMapping("/canteen-order/{canteenOrderId}/cancel/accept")
    public CanteenOrder acceptCancel(
            @PathVariable Long canteenOrderId) {

        User vendor = getCurrentUser();
        return service.acceptCanteenCancellation(canteenOrderId, vendor);
    }

    /*
     * =========================
     * ❌ REJECT CANCELLATION
     * =========================
     */
    @PatchMapping("/canteen-order/{canteenOrderId}/cancel/reject")
    public CanteenOrder rejectCancel(
            @PathVariable Long canteenOrderId) {

        User vendor = getCurrentUser();
        return service.rejectCanteenCancellation(canteenOrderId, vendor);
    }

    @PatchMapping("/{orderCode}/confirm-payment")
    public OrderResponseDTO confirmPayment(
            @PathVariable String orderCode,
            @RequestParam String method) {

        User user = getCurrentUser();
        return service.confirmPayment(orderCode, method, user);
    }
}