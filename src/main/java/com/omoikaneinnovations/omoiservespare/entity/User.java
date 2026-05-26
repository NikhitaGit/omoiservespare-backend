package com.omoikaneinnovations.omoiservespare.entity;

import com.omoikaneinnovations.omoiservespare.domain.AccountType;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String companyName;

    @Column(nullable = false, unique = true)
    private String email;

    /**
     * 🔐 Role-based authorization
     * Stored as STRING for readability & safety
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role = Role.USER;

    /**
     * 🏪 Vendor Status (only for VENDOR role)
     * Controls vendor access to the system
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "vendor_status")
    private VendorStatus vendorStatus;

    /**
     * 🔒 Account Active Flag
     * Allows system-wide account suspension
     */
    @Column(name = "account_active", nullable = false)
    private Boolean accountActive = true;

    @Enumerated(EnumType.STRING)
    @Column(nullable = true)
    private AccountType accountType;

    @Column(nullable = true)
    private String phoneNumber;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    /*
     * =========================
     * GETTERS & SETTERS
     * =========================
     */

    public Long getId() {
        return id;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public VendorStatus getVendorStatus() {
        return vendorStatus;
    }

    public void setVendorStatus(VendorStatus vendorStatus) {
        this.vendorStatus = vendorStatus;
    }

    public Boolean getAccountActive() {
        return accountActive;
    }

    public void setAccountActive(Boolean accountActive) {
        this.accountActive = accountActive;
    }

    public AccountType getAccountType() {
        return accountType;
    }

    public void setAccountType(AccountType accountType) {
        this.accountType = accountType;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    // public LocalDateTime getCreatedAt() {
    //     return createdAt;
    // }

    // public LocalDateTime getUpdatedAt() {
    //     return updatedAt;
    // }

    /**
     * 🔒 Security Helper Methods
     */
    public boolean isVendor() {
        return role == Role.VENDOR;
    }

    public boolean isAdmin() {
        return role == Role.ADMIN;
    }

    public boolean isUser() {
        return role == Role.USER;
    }

    public boolean isVendorApproved() {
        return isVendor() && vendorStatus == VendorStatus.APPROVED;
    }

    public boolean canOperate() {
        return accountActive && (!isVendor() || isVendorApproved());
    }

    /**
     * 🔐 Password for authentication
     * Stored as BCrypt hash
     */
    @Column(name = "password_hash")
    private String passwordHash;

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

}
