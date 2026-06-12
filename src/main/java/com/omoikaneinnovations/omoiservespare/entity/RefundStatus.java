package com.omoikaneinnovations.omoiservespare.entity;

/**
 * Production-grade refund status enum
 * Tracks the complete lifecycle of a refund
 */
public enum RefundStatus {
    // Initial states
    PENDING("Refund request pending vendor approval"),
    APPROVED("Vendor approved, awaiting processing"),
    REJECTED("Vendor rejected the refund request"),
    
    // Processing states
    PROCESSING("Refund is being processed with payment gateway"),
    QUEUED("Refund queued for retry"),
    
    // Final states
    SUCCESS("Refund completed successfully"),
    FAILED("Refund failed"),
    CANCELLED("Refund cancelled"),
    
    // Settlement states
    SETTLED("Refund settled to customer account"),
    SETTLEMENT_FAILED("Settlement to customer failed");
    
    private final String description;
    
    RefundStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
    
    public boolean isFinal() {
        return this == SUCCESS || this == FAILED || this == CANCELLED || this == SETTLED;
    }
    
    public boolean canRetry() {
        return this == FAILED || this == QUEUED;
    }
}