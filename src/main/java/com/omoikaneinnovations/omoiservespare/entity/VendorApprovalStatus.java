package com.omoikaneinnovations.omoiservespare.entity;

/**
 * Vendor approval status for cancellation/refund requests
 */
public enum VendorApprovalStatus {
    PENDING("Awaiting vendor approval"),
    APPROVED("Vendor approved the cancellation"),
    REJECTED("Vendor rejected the cancellation"),
    AUTO_APPROVED("Automatically approved by system");
    
    private final String description;
    
    VendorApprovalStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}