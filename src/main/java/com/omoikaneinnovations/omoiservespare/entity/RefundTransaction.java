package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Production-grade RefundTransaction entity
 * Handles complete refund lifecycle with vendor approval workflow
 */
@Entity
@Table(name = "refund_transactions", indexes = {
    @Index(name = "idx_refund_id", columnList = "refundId"),
    @Index(name = "idx_internal_code", columnList = "internalRefundCode"),
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_vendor_approval", columnList = "vendorApprovalStatus"),
    @Index(name = "idx_customer", columnList = "customer_id"),
    @Index(name = "idx_idempotency", columnList = "idempotencyKey")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RefundTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ============================================
    // IDENTIFIERS
    // ============================================
    
    @Column(name = "refund_id", unique = true, nullable = true, length = 100)
    private String refundId; // Razorpay refund ID (set after processing)
    
    @Column(name = "internal_refund_code", unique = true, nullable = false, length = 50)
    private String internalRefundCode; // Our internal tracking code (e.g., REF0001)
    
    @Column(name = "idempotency_key", unique = true, length = 100)
    private String idempotencyKey; // Prevent duplicate refunds

    // ============================================
    // RELATIONSHIPS
    // ============================================
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_transaction_id", nullable = false)
    private PaymentTransaction paymentTransaction;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "canteen_order_id", nullable = false)
    private CanteenOrder canteenOrder;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order; // Parent order for quick lookup
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer; // Customer for quick lookup

    // ============================================
    // AMOUNTS (with GST breakdown)
    // ============================================
    
    @Column(name = "original_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal originalAmount; // Original canteen order amount
    
    @Column(name = "refund_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal refundAmount; // Actual refund amount
    
    @Column(name = "cgst_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal cgstAmount = BigDecimal.ZERO;
    
    @Column(name = "sgst_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal sgstAmount = BigDecimal.ZERO;

    // ============================================
    // STATUS TRACKING
    // ============================================
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    @Builder.Default
    private RefundStatus status = RefundStatus.PENDING;
    
    @Column(name = "razorpay_status", length = 50)
    private String razorpayStatus; // Raw status from Razorpay

    // ============================================
    // CANCELLATION WORKFLOW
    // ============================================
    
    @Enumerated(EnumType.STRING)
    @Column(name = "cancellation_requested_by", length = 50)
    private CancellationRequestedBy cancellationRequestedBy;
    
    @Column(name = "cancellation_reason", columnDefinition = "TEXT")
    private String cancellationReason;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "vendor_approval_status", length = 50)
    @Builder.Default
    private VendorApprovalStatus vendorApprovalStatus = VendorApprovalStatus.PENDING;
    
    @Column(name = "vendor_approval_at")
    private LocalDateTime vendorApprovalAt;
    
    @Column(name = "vendor_id")
    private Long vendorId; // Vendor who approved/rejected
    
    @Column(name = "vendor_remarks", columnDefinition = "TEXT")
    private String vendorRemarks;

    // ============================================
    // REFUND PROCESSING TIMESTAMPS
    // ============================================
    
    @Column(name = "refund_initiated_at")
    private LocalDateTime refundInitiatedAt;
    
    @Column(name = "refund_processed_at")
    private LocalDateTime refundProcessedAt;
    
    @Column(name = "refund_failed_at")
    private LocalDateTime refundFailedAt;

    // ============================================
    // GATEWAY DETAILS
    // ============================================
    
    @Column(name = "gateway_name", length = 50)
    @Builder.Default
    private String gatewayName = "razorpay";
    
    @Column(name = "gateway_response", columnDefinition = "TEXT")
    private String gatewayResponse; // Full JSON response
    
    @Column(name = "gateway_error_code", length = 100)
    private String gatewayErrorCode;
    
    @Column(name = "gateway_error_message", columnDefinition = "TEXT")
    private String gatewayErrorMessage;

    // ============================================
    // REFUND METHOD
    // ============================================
    
    @Column(name = "refund_method", length = 50)
    private String refundMethod; // UPI, CARD, WALLET, NETBANKING
    
    @Column(name = "refund_mode", length = 50)
    @Builder.Default
    private String refundMode = "AUTO"; // AUTO or MANUAL

    // ============================================
    // SETTLEMENT TRACKING
    // ============================================
    
    @Column(name = "settlement_status", length = 50)
    @Builder.Default
    private String settlementStatus = "PENDING"; // PENDING, SETTLED, FAILED
    
    @Column(name = "settlement_date")
    private LocalDateTime settlementDate;
    
    @Column(name = "settlement_utr", length = 100)
    private String settlementUtr; // UTR/Reference number

    // ============================================
    // RETRY MECHANISM
    // ============================================
    
    @Column(name = "retry_count")
    @Builder.Default
    private Integer retryCount = 0;
    
    @Column(name = "max_retries")
    @Builder.Default
    private Integer maxRetries = 3;
    
    @Column(name = "next_retry_at")
    private LocalDateTime nextRetryAt;

    // ============================================
    // AUDIT TRAIL
    // ============================================
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "created_by", length = 100)
    private String createdBy;
    
    @Column(name = "updated_by", length = 100)
    private String updatedBy;

    // ============================================
    // METADATA
    // ============================================
    
    @Column(name = "metadata", columnDefinition = "JSONB")
    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    private String metadata; // Additional metadata as JSON
    
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes; // Internal notes

    // ============================================
    // LIFECYCLE CALLBACKS
    // ============================================
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // ============================================
    // HELPER METHODS
    // ============================================
    
    public boolean canRetry() {
        return status.canRetry() && retryCount < maxRetries;
    }
    
    public boolean isFinal() {
        return status.isFinal();
    }
    
    public boolean isApproved() {
        return vendorApprovalStatus == VendorApprovalStatus.APPROVED || 
               vendorApprovalStatus == VendorApprovalStatus.AUTO_APPROVED;
    }
    
    public boolean isPending() {
        return vendorApprovalStatus == VendorApprovalStatus.PENDING;
    }
    
    public void incrementRetry() {
        this.retryCount++;
    }
}