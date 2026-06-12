package com.omoikaneinnovations.omoiservespare.entity;

/**
 * Who initiated the cancellation request
 */
public enum CancellationRequestedBy {
    CUSTOMER("Customer requested cancellation"),
    VENDOR("Vendor cancelled the order"),
    SYSTEM("System auto-cancelled (timeout, fraud, etc)"),
    ADMIN("Admin cancelled the order");
    
    private final String description;
    
    CancellationRequestedBy(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}