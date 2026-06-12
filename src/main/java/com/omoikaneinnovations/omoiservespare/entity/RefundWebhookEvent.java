package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Stores webhook events from Razorpay for refund status updates
 * Ensures idempotent webhook processing
 */
@Entity
@Table(name = "refund_webhook_events", indexes = {
    @Index(name = "idx_event_id", columnList = "eventId", unique = true),
    @Index(name = "idx_refund_id", columnList = "refundId"),
    @Index(name = "idx_processed", columnList = "processed"),
    @Index(name = "idx_received_at", columnList = "receivedAt")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RefundWebhookEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Webhook details
    @Column(name = "event_id", unique = true, nullable = false, length = 100)
    private String eventId; // Razorpay event ID

    @Column(name = "event_type", nullable = false, length = 100)
    private String eventType; // refund.processed, refund.failed, etc

    // Refund reference
    @Column(name = "refund_id", length = 100)
    private String refundId; // Razorpay refund ID

    @Column(name = "refund_transaction_id")
    private Long refundTransactionId; // Our refund transaction ID

    // Payload
    @Column(name = "payload", nullable = false, columnDefinition = "JSON")
    private String payload; // Full webhook payload

    @Column(name = "signature", length = 500)
    private String signature; // Webhook signature for verification

    // Processing status
    @Column(name = "processed")
    @Builder.Default
    private Boolean processed = false;

    @Column(name = "processed_at")
    private LocalDateTime processedAt;

    @Column(name = "processing_error", columnDefinition = "TEXT")
    private String processingError;

    // Retry
    @Column(name = "retry_count")
    @Builder.Default
    private Integer retryCount = 0;

    // Timestamp
    @Column(name = "received_at", nullable = false, updatable = false)
    private LocalDateTime receivedAt;

    @PrePersist
    protected void onCreate() {
        receivedAt = LocalDateTime.now();
    }
}