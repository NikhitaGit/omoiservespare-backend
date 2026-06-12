package com.omoikaneinnovations.omoiservespare.entity;

public enum OrderStatus {
    PENDING,            // Order created but payment not verified yet
    ORDER_RECEIVED,
    PREPARING,
    PREPARED,
    DELIVERED,

    CANCELLATION_REQUESTED,
    PARTIALLY_CANCELLED, // ✅ Some canteen orders cancelled, some active
    CANCELLED,          // ✅ All canteen orders cancelled (vendor accepted)
    CANCELLATION_REJECTED // ✅ vendor rejected
}