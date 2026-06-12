package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Audit log for tracking all refund state changes
 * Critical for compliance and debugging
 */
@Entity
@Table(name = "refund_audit_logs", indexes = {
    @Index(name = "idx_refund_transaction", columnList = "refund_transaction_id"),
    @Index(name = "idx_event_type", columnList = "eventType"),
    @Index(name = "idx_created_at", columnList = "createdAt")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RefundAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "refund_transaction_id", nullable = false)
    private RefundTransaction refundTransaction;

    // Event details
    @Column(name = "event_type", nullable = false, length = 50)
    private String eventType; // CREATED, STATUS_CHANGED, APPROVED, REJECTED, etc

    @Column(name = "old_status", length = 50)
    private String oldStatus;

    @Column(name = "new_status", length = 50)
    private String newStatus;

    // Actor details
    @Column(name = "actor_type", length = 50)
    private String actorType; // CUSTOMER, VENDOR, SYSTEM, WEBHOOK

    @Column(name = "actor_id")
    private Long actorId;

    @Column(name = "actor_email")
    private String actorEmail;

    // Change details
    @Column(name = "changes", columnDefinition = "JSONB")
    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    private String changes; // JSON of what changed

    @Column(name = "remarks", columnDefinition = "TEXT")
    private String remarks;

    // Request details
    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    @Column(name = "user_agent", columnDefinition = "TEXT")
    private String userAgent;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}