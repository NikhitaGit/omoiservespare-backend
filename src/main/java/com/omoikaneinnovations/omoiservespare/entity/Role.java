package com.omoikaneinnovations.omoiservespare.entity;

/**
 * 🏷️ Role-Based Access Control (RBAC)
 * 
 * Defines what users can do in the system
 * 
 * USER    → Orders food, views restaurants
 * VENDOR  → Manages restaurant, menu, orders
 * ADMIN   → Full system control
 */
public enum Role {
    USER,
    VENDOR,
    ADMIN
}
