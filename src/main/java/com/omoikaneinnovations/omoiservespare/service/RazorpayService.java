package com.omoikaneinnovations.omoiservespare.service;

import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Order;
import com.razorpay.Payment;
import com.razorpay.Refund;
import com.omoikaneinnovations.omoiservespare.exception.PaymentException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class RazorpayService {

    @Value("${razorpay.key-id}")
    private String razorpayKeyId;

    @Value("${razorpay.key-secret}")
    private String razorpayKeySecret;

    private RazorpayClient razorpayClient;

    /**
     * Initialize Razorpay client
     */
    private void initializeClient() {
        if (razorpayClient == null) {
            try {
                log.info("Initializing Razorpay client with Key ID: {} (length: {})", 
                    razorpayKeyId != null ? razorpayKeyId.substring(0, Math.min(razorpayKeyId.length(), 15)) + "..." : "null",
                    razorpayKeyId != null ? razorpayKeyId.length() : 0);
                log.info("Key Secret length: {}", razorpayKeySecret != null ? razorpayKeySecret.length() : 0);
                
                if (razorpayKeyId == null || razorpayKeyId.trim().isEmpty()) {
                    throw new IllegalArgumentException("Razorpay Key ID is null or empty");
                }
                if (razorpayKeySecret == null || razorpayKeySecret.trim().isEmpty()) {
                    throw new IllegalArgumentException("Razorpay Key Secret is null or empty");
                }
                
                razorpayClient = new RazorpayClient(razorpayKeyId, razorpayKeySecret);
                log.info("Razorpay client initialized successfully");
            } catch (RazorpayException e) {
                log.error("Failed to initialize Razorpay client", e);
                throw new PaymentException("RAZORPAY_INIT_FAILED", "Failed to initialize payment gateway");
            }
        }
    }

    /**
     * Create Razorpay order
     */
    public Map<String, Object> createOrder(String orderCode, Long amountInPaise, String currency) {
        try {
            initializeClient();

            JSONObject orderRequest = new JSONObject();
            orderRequest.put("amount", amountInPaise); // Amount in paise
            orderRequest.put("currency", currency);
            orderRequest.put("receipt", orderCode);
            orderRequest.put("payment_capture", 1); // Auto-capture payment

            // Use the correct API for Razorpay SDK 1.4.5
            com.razorpay.Order order = razorpayClient.orders.create(orderRequest);

            Map<String, Object> response = new HashMap<>();
            response.put("razorpay_order_id", order.get("id"));
            response.put("amount", order.get("amount"));
            response.put("currency", order.get("currency"));
            response.put("status", order.get("status"));

            log.info("Razorpay order created - Order Code: {}, Razorpay Order ID: {}", 
                orderCode, order.get("id"));

            return response;

        } catch (Exception e) {
            log.error("Failed to create Razorpay order", e);
            throw new PaymentException("ORDER_CREATION_FAILED", "Failed to create payment order: " + e.getMessage());
        }
    }

    /**
     * Verify payment signature (HMAC-SHA256)
     */
    public boolean verifyPaymentSignature(String razorpayOrderId, String razorpayPaymentId, String signature) {
        try {
            String payload = razorpayOrderId + "|" + razorpayPaymentId;
            String expectedSignature = generateHmacSha256(payload, razorpayKeySecret);

            boolean isValid = expectedSignature.equals(signature);

            if (!isValid) {
                log.warn("Invalid payment signature - Possible tampering detected. Order: {}, Payment: {}", 
                    razorpayOrderId, razorpayPaymentId);
            } else {
                log.info("Payment signature verified successfully - Order: {}, Payment: {}", 
                    razorpayOrderId, razorpayPaymentId);
            }

            return isValid;

        } catch (Exception e) {
            log.error("Error verifying payment signature", e);
            throw new PaymentException("SIGNATURE_VERIFICATION_FAILED", "Failed to verify payment signature");
        }
    }

    /**
     * Fetch payment details from Razorpay
     */
    public Map<String, Object> fetchPaymentDetails(String razorpayPaymentId) {
        try {
            initializeClient();

            // Use the correct API for Razorpay SDK 1.4.5
            com.razorpay.Payment payment = razorpayClient.payments.fetch(razorpayPaymentId);

            Map<String, Object> response = new HashMap<>();
            response.put("id", payment.get("id"));
            response.put("order_id", payment.get("order_id"));
            response.put("amount", payment.get("amount"));
            response.put("currency", payment.get("currency"));
            response.put("status", payment.get("status"));
            response.put("method", payment.get("method"));
            response.put("description", payment.has("description") ? payment.get("description") : "");
            response.put("email", payment.has("email") ? payment.get("email") : "");
            response.put("contact", payment.has("contact") ? payment.get("contact") : "");
            response.put("vpa", payment.has("vpa") ? payment.get("vpa") : ""); // For UPI
            response.put("card_id", payment.has("card_id") ? payment.get("card_id") : "");
            response.put("bank", payment.has("bank") ? payment.get("bank") : "");
            response.put("wallet", payment.has("wallet") ? payment.get("wallet") : "");
            response.put("created_at", payment.get("created_at"));

            log.info("Payment details fetched - Payment ID: {}, Status: {}", 
                razorpayPaymentId, payment.get("status"));

            return response;

        } catch (Exception e) {
            log.error("Failed to fetch payment details", e);
            throw new PaymentException("FETCH_PAYMENT_FAILED", "Failed to fetch payment details: " + e.getMessage());
        }
    }

    /**
     * Refund payment
     */
    public Map<String, Object> refundPayment(String razorpayPaymentId, Long amountInPaise, String reason) {
        try {
            initializeClient();

            JSONObject refundRequest = new JSONObject();
            if (amountInPaise > 0) {
                refundRequest.put("amount", amountInPaise); // Partial refund
            }
            refundRequest.put("notes", new JSONObject().put("reason", reason));

            // Use the correct API for Razorpay SDK 1.4.5
            com.razorpay.Refund refund = razorpayClient.payments.refund(razorpayPaymentId, refundRequest);

            Map<String, Object> response = new HashMap<>();
            response.put("refund_id", refund.get("id"));
            response.put("payment_id", refund.get("payment_id"));
            response.put("amount", refund.get("amount"));
            response.put("status", refund.get("status"));
            response.put("created_at", refund.get("created_at"));

            log.info("Refund processed - Payment ID: {}, Refund ID: {}, Amount: {}", 
                razorpayPaymentId, refund.get("id"), amountInPaise);

            return response;

        } catch (Exception e) {
            log.error("Failed to refund payment", e);
            throw new PaymentException("REFUND_FAILED", "Failed to process refund: " + e.getMessage());
        }
    }

    /**
     * Generate HMAC-SHA256 signature
     */
    private String generateHmacSha256(String data, String secret) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKeySpec);
        byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));

        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    }

    /**
     * Verify webhook signature
     */
    public boolean verifyWebhookSignature(String payload, String signature) {
        try {
            String expectedSignature = generateHmacSha256(payload, razorpayKeySecret);
            return expectedSignature.equals(signature);
        } catch (Exception e) {
            log.error("Error verifying webhook signature", e);
            return false;
        }
    }
}