package com.omoikaneinnovations.omoiservespare.entity;

public enum OrderStatus {
    PENDING,            // Payment pending
    ORDER_RECEIVED,
    PREPARING,
    PREPARED,
    DELIVERED,

    CANCELLATION_REQUESTED,
    CANCELLED,          // ✅ vendor accepted
    CANCELLATION_REJECTED // ✅ vendor rejected
}
