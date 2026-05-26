package com.omoikaneinnovations.omoiservespare.entity;

/**
 * 🏪 Vendor Account Status
 * 
 * Controls vendor access to the system
 * 
 * PENDING   → Waiting for admin approval
 * APPROVED  → Can operate normally
 * SUSPENDED → Temporarily blocked
 * REJECTED  → Application denied
 */
public enum VendorStatus {
    PENDING,
    APPROVED,
    SUSPENDED,
    REJECTED
}
