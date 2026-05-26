package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.service.PaymentService;
import com.omoikaneinnovations.omoiservespare.dto.PaymentRequestDTO;
import com.omoikaneinnovations.omoiservespare.dto.PaymentInitResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.PaymentVerifyRequestDTO;
import com.omoikaneinnovations.omoiservespare.exception.PaymentException;
import com.omoikaneinnovations.omoiservespare.exception.FraudDetectedException;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;

import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
@Slf4j
public class PaymentController {

    private final PaymentService paymentService;
    private final UserRepository userRepository;

    /**
     * STEP 1: Initiate Payment
     * 
     * Request:
     * {
     *   "orderCode": "ORD123",
     *   "gateway": "razorpay",
     *   "paymentMethod": "card",
     *   "amount": 500.00,
     *   "currency": "INR",
     *   "deviceId": "device_123"
     * }
     * 
     * Response:
     * {
     *   "transactionId": "order_123456",
     *   "status": "INITIATED",
     *   "riskLevel": "MEDIUM",
     *   "requires3DS": true,
     *   "razorpayOrderId": "order_123456",
     *   "authenticationUrl": "https://razorpay.com/3ds/auth/order_123456",
     *   "message": "3D Secure authentication required"
     * }
     */
    @PostMapping("/initiate")
    public ResponseEntity<?> initiatePayment(
            @RequestBody PaymentRequestDTO request,
            HttpServletRequest httpRequest) {

        try {
            // Extract device info for fraud detection
            String ipAddress = getClientIpAddress(httpRequest);
            String userAgent = httpRequest.getHeader("User-Agent");

            // Initiate payment with fraud detection
            PaymentInitResponseDTO response = paymentService.initiatePayment(
                    request.getOrderCode(),
                    request.getGateway(),
                    request,
                    request.getDeviceId(),
                    ipAddress,
                    userAgent);

            log.info("Payment initiated - Order: {}, Risk Level: {}, Requires 3DS: {}",
                    request.getOrderCode(), response.getRiskLevel(), response.isRequires3DS());

            return ResponseEntity.ok(response);

        } catch (FraudDetectedException e) {
            log.warn("Fraud detected - Risk Level: {}, Risk Score: {}", e.getRiskLevel(), e.getRiskScore());
            return ResponseEntity.status(403).body(Map.of(
                    "error", "FRAUD_DETECTED",
                    "message", e.getMessage(),
                    "riskLevel", e.getRiskLevel(),
                    "riskScore", e.getRiskScore()
            ));

        } catch (PaymentException e) {
            log.error("Payment initiation failed - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                    "error", e.getErrorCode(),
                    "message", e.getErrorMessage()
            ));

        } catch (Exception e) {
            log.error("Payment initiation failed", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "INTERNAL_ERROR",
                    "message", "Payment initiation failed: " + e.getMessage()
            ));
        }
    }
    /**
     * STEP 1: Initiate Payment from Cart
     *
     * Request:
     * {
     *   "gateway": "razorpay",
     *   "paymentMethod": "card",
     *   "amount": 500.00,
     *   "currency": "INR",
     *   "deviceId": "device_123",
     *   "note": "Extra spicy",
     *   "createOrderFromCart": true
     * }
     *
     * Response:
     * {
     *   "transactionId": "order_123456",
     *   "status": "INITIATED",
     *   "riskLevel": "MEDIUM",
     *   "requires3DS": true,
     *   "razorpayOrderId": "order_123456",
     *   "authenticationUrl": "https://razorpay.com/3ds/auth/order_123456",
     *   "message": "3D Secure authentication required"
     * }
     */
    @PostMapping("/initiate-from-cart")
    public ResponseEntity<?> initiatePaymentFromCart(
            @RequestBody PaymentRequestDTO request,
            HttpServletRequest httpRequest) {

        try {
            // Get current user
            User user = getCurrentUser();

            // Extract device info for fraud detection
            String ipAddress = getClientIpAddress(httpRequest);
            String userAgent = httpRequest.getHeader("User-Agent");

            // Initiate payment from cart with fraud detection
            PaymentInitResponseDTO response = paymentService.initiatePaymentFromCart(
                    user,
                    request.getGateway(),
                    request,
                    request.getDeviceId(),
                    ipAddress,
                    userAgent);

            log.info("Payment initiated from cart - User: {}, Risk Level: {}, Requires 3DS: {}",
                    user.getEmail(), response.getRiskLevel(), response.isRequires3DS());

            return ResponseEntity.ok(response);

        } catch (FraudDetectedException e) {
            log.warn("Fraud detected - Risk Level: {}, Risk Score: {}", e.getRiskLevel(), e.getRiskScore());
            return ResponseEntity.status(403).body(Map.of(
                    "error", "FRAUD_DETECTED",
                    "message", e.getMessage(),
                    "riskLevel", e.getRiskLevel(),
                    "riskScore", e.getRiskScore()
            ));

        } catch (PaymentException e) {
            log.error("Payment initiation from cart failed - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                    "error", e.getErrorCode(),
                    "message", e.getErrorMessage()
            ));

        } catch (Exception e) {
            log.error("Payment initiation from cart failed", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "INTERNAL_ERROR",
                    "message", "Payment initiation failed: " + e.getMessage()
            ));
        }
    }

    /**
     * STEP 2: Verify Payment (After 3D Secure or gateway callback)
     * 
     * Request:
     * {
     *   "orderCode": "ORD123",
     *   "transactionId": "order_123456",
     *   "razorpayPaymentId": "pay_123456",
     *   "razorpayOrderId": "order_123456",
     *   "signature": "9ef4dffbfd84f1318f6739a3ce19f9d85851857ae648f114332d8401e0949a3d",
     *   "cavv": "jJ81HAh4OVNHjEEQMDuUVAAAAAA=",
     *   "eci": "05"
     * }
     */
    @PostMapping("/verify")
    public ResponseEntity<?> verifyPayment(
            @RequestBody PaymentVerifyRequestDTO request) {

        try {
            paymentService.verifyPayment(
                    request.getOrderCode(),
                    request.getTransactionId(),
                    request.getRazorpayPaymentId(),
                    request.getRazorpayOrderId(),
                    request.getSignature(),
                    request.getCavv(),
                    request.getEci());

            log.info("Payment verified successfully - Order: {}", request.getOrderCode());

            return ResponseEntity.ok(Map.of(
                    "status", "success",
                    "message", "Payment verified successfully"
            ));

        } catch (PaymentException e) {
            log.error("Payment verification failed - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                    "error", e.getErrorCode(),
                    "message", e.getErrorMessage()
            ));

        } catch (Exception e) {
            log.error("Payment verification failed", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "INTERNAL_ERROR",
                    "message", "Payment verification failed: " + e.getMessage()
            ));
        }
    }

    /**
     * Get Payment Status
     */
    @GetMapping("/status/{transactionId}")
    public ResponseEntity<?> getPaymentStatus(@PathVariable String transactionId) {
        try {
            // TODO: Implement - fetch payment status from database
            return ResponseEntity.ok(Map.of(
                    "transactionId", transactionId,
                    "status", "success"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(400).body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Refund Payment (for cancelled orders)
     */
    @PostMapping("/refund/{canteenOrderId}")
    public ResponseEntity<?> refundPayment(
            @PathVariable Long canteenOrderId,
            @RequestParam String reason) {

        try {
            paymentService.refundCanteenOrder(canteenOrderId, reason);

            log.info("Refund processed - Canteen Order: {}", canteenOrderId);

            return ResponseEntity.ok(Map.of(
                    "status", "success",
                    "message", "Refund processed successfully"
            ));

        } catch (PaymentException e) {
            log.error("Refund failed - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                    "error", e.getErrorCode(),
                    "message", e.getErrorMessage()
            ));

        } catch (Exception e) {
            log.error("Refund failed", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "INTERNAL_ERROR",
                    "message", "Refund failed: " + e.getMessage()
            ));
        }
    }

    // ============================================
    // HELPER METHODS
    // ============================================

    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0];
        }
        return request.getRemoteAddr();
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            throw new RuntimeException("Unauthenticated");
        }
        
        String email = auth.getName(); // email
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}