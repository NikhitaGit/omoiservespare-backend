package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.service.PaymentService;
import com.omoikaneinnovations.omoiservespare.service.RazorpayService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.json.JSONObject;

import java.util.Map;

@RestController
@RequestMapping("/api/payments/webhook")
@RequiredArgsConstructor
@Slf4j
public class PaymentWebhookController {

    private final PaymentService paymentService;
    private final RazorpayService razorpayService;

    /**
     * Razorpay Webhook Handler
     * 
     * Events:
     * - payment.authorized
     * - payment.failed
     * - payment.captured
     * - refund.created
     * - refund.failed
     */
    @PostMapping("/razorpay")
    public ResponseEntity<?> handleRazorpayWebhook(
            @RequestBody String payload,
            @RequestHeader("X-Razorpay-Signature") String signature) {

        try {
            log.info("Received Razorpay webhook");

            // ============================================
            // 1. VERIFY WEBHOOK SIGNATURE
            // ============================================
            if (!razorpayService.verifyWebhookSignature(payload, signature)) {
                log.error("Invalid webhook signature - Possible tampering detected");
                return ResponseEntity.status(401).body(Map.of(
                        "error", "Invalid signature",
                        "message", "Webhook signature verification failed"
                ));
            }

            // ============================================
            // 2. PARSE WEBHOOK PAYLOAD
            // ============================================
            JSONObject webhookData = new JSONObject(payload);
            String eventType = webhookData.getString("event");
            JSONObject eventPayload = webhookData.getJSONObject("payload");

            log.info("Processing webhook event: {}", eventType);

            // ============================================
            // 3. HANDLE DIFFERENT EVENTS
            // ============================================
            switch (eventType) {
                case "payment.authorized":
                    handlePaymentAuthorized(eventPayload);
                    break;

                case "payment.failed":
                    handlePaymentFailed(eventPayload);
                    break;

                case "payment.captured":
                    handlePaymentCaptured(eventPayload);
                    break;

                case "refund.created":
                    handleRefundCreated(eventPayload);
                    break;

                case "refund.failed":
                    handleRefundFailed(eventPayload);
                    break;

                default:
                    log.warn("Unknown webhook event type: {}", eventType);
            }

            // ============================================
            // 4. RETURN SUCCESS
            // ============================================
            return ResponseEntity.ok(Map.of(
                    "status", "success",
                    "message", "Webhook processed successfully"
            ));

        } catch (Exception e) {
            log.error("Error processing webhook", e);
            return ResponseEntity.status(500).body(Map.of(
                    "error", "Webhook processing failed",
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * Handle payment.authorized event
     */
    private void handlePaymentAuthorized(JSONObject payload) {
        try {
            JSONObject payment = payload.getJSONObject("payment");
            String razorpayPaymentId = payment.getString("id");
            String razorpayOrderId = payment.getString("order_id");

            log.info("Payment authorized - Payment ID: {}, Order ID: {}", razorpayPaymentId, razorpayOrderId);

            // Update payment status in database
            paymentService.handlePaymentAuthorized(razorpayPaymentId, razorpayOrderId);

        } catch (Exception e) {
            log.error("Error handling payment.authorized event", e);
        }
    }

    /**
     * Handle payment.failed event
     */
    private void handlePaymentFailed(JSONObject payload) {
        try {
            JSONObject payment = payload.getJSONObject("payment");
            String razorpayPaymentId = payment.getString("id");
            String razorpayOrderId = payment.getString("order_id");
            String errorCode = payment.optString("error_code", "UNKNOWN");
            String errorDescription = payment.optString("error_description", "Unknown error");

            log.warn("Payment failed - Payment ID: {}, Order ID: {}, Error: {}", 
                razorpayPaymentId, razorpayOrderId, errorCode);

            // Update payment status in database
            paymentService.handlePaymentFailed(razorpayPaymentId, razorpayOrderId, errorCode, errorDescription);

        } catch (Exception e) {
            log.error("Error handling payment.failed event", e);
        }
    }

    /**
     * Handle payment.captured event
     */
    private void handlePaymentCaptured(JSONObject payload) {
        try {
            JSONObject payment = payload.getJSONObject("payment");
            String razorpayPaymentId = payment.getString("id");
            String razorpayOrderId = payment.getString("order_id");
            Long amount = payment.getLong("amount");

            log.info("Payment captured - Payment ID: {}, Order ID: {}, Amount: {}", 
                razorpayPaymentId, razorpayOrderId, amount);

            // Update payment status in database
            paymentService.handlePaymentCaptured(razorpayPaymentId, razorpayOrderId, amount);

        } catch (Exception e) {
            log.error("Error handling payment.captured event", e);
        }
    }

    /**
     * Handle refund.created event
     */
    private void handleRefundCreated(JSONObject payload) {
        try {
            JSONObject refund = payload.getJSONObject("refund");
            String refundId = refund.getString("id");
            String razorpayPaymentId = refund.getString("payment_id");
            Long amount = refund.getLong("amount");

            log.info("Refund created - Refund ID: {}, Payment ID: {}, Amount: {}", 
                refundId, razorpayPaymentId, amount);

            // Update refund status in database
            paymentService.handleRefundCreated(refundId, razorpayPaymentId, amount);

        } catch (Exception e) {
            log.error("Error handling refund.created event", e);
        }
    }

    /**
     * Handle refund.failed event
     */
    private void handleRefundFailed(JSONObject payload) {
        try {
            JSONObject refund = payload.getJSONObject("refund");
            String refundId = refund.getString("id");
            String razorpayPaymentId = refund.getString("payment_id");
            String errorCode = refund.optString("error_code", "UNKNOWN");

            log.warn("Refund failed - Refund ID: {}, Payment ID: {}, Error: {}", 
                refundId, razorpayPaymentId, errorCode);

            // Update refund status in database
            paymentService.handleRefundFailed(refundId, razorpayPaymentId, errorCode);

        } catch (Exception e) {
            log.error("Error handling refund.failed event", e);
        }
    }
}