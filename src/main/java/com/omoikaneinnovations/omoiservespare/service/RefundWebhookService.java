package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.*;
import com.omoikaneinnovations.omoiservespare.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Handles Razorpay webhook events for refunds
 * Ensures idempotent processing
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RefundWebhookService {

    private final RefundWebhookEventRepository webhookRepo;
    private final RefundTransactionRepository refundRepo;
    private final RefundAuditLogRepository auditLogRepo;
    private final RazorpayService razorpayService;
    private final ObjectMapper objectMapper;

    /**
     * Process incoming webhook event
     * Idempotent - safe to call multiple times with same event
     */
    @Transactional
    public void processWebhook(String payload, String signature) {
        log.info("🔔 Received refund webhook");

        try {
            // 1. Verify webhook signature
            if (!razorpayService.verifyWebhookSignature(payload, signature)) {
                log.error("❌ Invalid webhook signature - possible tampering");
                return;
            }

            // 2. Parse payload
            JsonNode json = objectMapper.readTree(payload);
            String eventId = json.get("event").asText();
            String eventType = json.get("event").asText();

            // 3. Check if already processed (idempotency)
            Optional<RefundWebhookEvent> existing = webhookRepo.findByEventId(eventId);
            if (existing.isPresent() && existing.get().getProcessed()) {
                log.info("⚠️ Webhook already processed - Event ID: {}", eventId);
                return;
            }

            // 4. Extract refund details
            JsonNode payloadNode = json.get("payload");
            JsonNode refundNode = payloadNode.get("refund").get("entity");
            
            String refundId = refundNode.get("id").asText();
            String status = refundNode.get("status").asText();
            Long amount = refundNode.get("amount").asLong();

            log.info("📦 Webhook details - Event: {}, Refund ID: {}, Status: {}", 
                eventType, refundId, status);

            // 5. Find refund transaction
            Optional<RefundTransaction> refundOpt = refundRepo.findByRefundId(refundId);
            
            Long refundTransactionId = refundOpt.map(RefundTransaction::getId).orElse(null);

            // 6. Save webhook event
            RefundWebhookEvent webhookEvent = RefundWebhookEvent.builder()
                    .eventId(eventId)
                    .eventType(eventType)
                    .refundId(refundId)
                    .refundTransactionId(refundTransactionId)
                    .payload(payload)
                    .signature(signature)
                    .processed(false)
                    .build();

            webhookRepo.save(webhookEvent);

            // 7. Process based on event type
            if (refundOpt.isPresent()) {
                RefundTransaction refund = refundOpt.get();
                String oldStatus = refund.getStatus().toString();

                switch (eventType) {
                    case "refund.processed":
                        handleRefundProcessed(refund, status);
                        break;
                    case "refund.failed":
                        handleRefundFailed(refund, refundNode);
                        break;
                    case "refund.speed_changed":
                        handleRefundSpeedChanged(refund, refundNode);
                        break;
                    default:
                        log.warn("⚠️ Unknown webhook event type: {}", eventType);
                }

                // Create audit log
                createAuditLog(refund, "WEBHOOK_" + eventType.toUpperCase(), 
                    oldStatus, refund.getStatus().toString(), 
                    "Webhook event processed");

                // Mark webhook as processed
                webhookEvent.setProcessed(true);
                webhookEvent.setProcessedAt(LocalDateTime.now());
                webhookRepo.save(webhookEvent);

                log.info("✅ Webhook processed successfully");

            } else {
                log.warn("⚠️ Refund not found for webhook - Refund ID: {}", refundId);
                webhookEvent.setProcessingError("Refund not found");
                webhookRepo.save(webhookEvent);
            }

        } catch (Exception e) {
            log.error("❌ Failed to process webhook", e);
            // Don't throw - webhook will be retried by Razorpay
        }
    }

    /**
     * Handle refund.processed event
     */
    private void handleRefundProcessed(RefundTransaction refund, String status) {
        log.info("✅ Refund processed - Refund ID: {}, Status: {}", 
            refund.getRefundId(), status);

        refund.setStatus(RefundStatus.SUCCESS);
        refund.setRazorpayStatus(status);
        refund.setRefundProcessedAt(LocalDateTime.now());
        refund.setUpdatedBy("webhook");

        refundRepo.save(refund);
    }

    /**
     * Handle refund.failed event
     */
    private void handleRefundFailed(RefundTransaction refund, JsonNode refundNode) {
        String errorCode = refundNode.has("error_code") 
            ? refundNode.get("error_code").asText() : null;
        String errorDescription = refundNode.has("error_description") 
            ? refundNode.get("error_description").asText() : null;

        log.error("❌ Refund failed - Refund ID: {}, Error: {}", 
            refund.getRefundId(), errorCode);

        refund.setStatus(RefundStatus.FAILED);
        refund.setRazorpayStatus("failed");
        refund.setRefundFailedAt(LocalDateTime.now());
        refund.setGatewayErrorCode(errorCode);
        refund.setGatewayErrorMessage(errorDescription);
        refund.setNextRetryAt(calculateNextRetryTime(refund.getRetryCount()));
        refund.setUpdatedBy("webhook");

        refundRepo.save(refund);
    }

    /**
     * Handle refund.speed_changed event
     */
    private void handleRefundSpeedChanged(RefundTransaction refund, JsonNode refundNode) {
        String speedRequested = refundNode.has("speed_requested") 
            ? refundNode.get("speed_requested").asText() : null;

        log.info("🚀 Refund speed changed - Refund ID: {}, Speed: {}", 
            refund.getRefundId(), speedRequested);

        // Update metadata
        refund.setUpdatedBy("webhook");
        refundRepo.save(refund);
    }

    /**
     * Retry unprocessed webhooks
     * Called by scheduled job
     */
    @Transactional
    public void retryUnprocessedWebhooks() {
        log.info("🔄 Retrying unprocessed webhooks");

        List<RefundWebhookEvent> unprocessed = webhookRepo.findUnprocessedWithRetries();

        log.info("Found {} unprocessed webhooks", unprocessed.size());

        for (RefundWebhookEvent webhook : unprocessed) {
            try {
                log.info("Retrying webhook: {}", webhook.getEventId());
                
                webhook.setRetryCount(webhook.getRetryCount() + 1);
                webhookRepo.save(webhook);

                processWebhook(webhook.getPayload(), webhook.getSignature());

            } catch (Exception e) {
                log.error("Retry failed for webhook: {}", webhook.getEventId(), e);
                
                webhook.setProcessingError(e.getMessage());
                webhookRepo.save(webhook);
            }
        }
    }

    private LocalDateTime calculateNextRetryTime(int retryCount) {
        int minutes = (int) Math.pow(3, retryCount) * 5;
        return LocalDateTime.now().plusMinutes(minutes);
    }

    private void createAuditLog(RefundTransaction refund, String eventType, 
                                String oldStatus, String newStatus, String remarks) {
        RefundAuditLog auditLog = RefundAuditLog.builder()
                .refundTransaction(refund)
                .eventType(eventType)
                .oldStatus(oldStatus)
                .newStatus(newStatus)
                .actorType("WEBHOOK")
                .remarks(remarks)
                .build();

        auditLogRepo.save(auditLog);
    }
}