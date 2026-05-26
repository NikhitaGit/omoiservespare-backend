package com.omoikaneinnovations.omoiservespare.dto;

import java.time.LocalDateTime;

/**
 * 📍 Address Response DTO
 * Returns saved address details to frontend
 */
public class AddressResponse {

    private Long id;
    private String title;
    private String address;
    private Double latitude;
    private Double longitude;
    private String phoneNumber;
    private Boolean isDefault;
    private LocalDateTime createdAt;

    public AddressResponse() {}

    public AddressResponse(Long id, String title, String address, Double latitude, 
                          Double longitude, String phoneNumber, Boolean isDefault, 
                          LocalDateTime createdAt) {
        this.id = id;
        this.title = title;
        this.address = address;
        this.latitude = latitude;
        this.longitude = longitude;
        this.phoneNumber = phoneNumber;
        this.isDefault = isDefault;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public Boolean getIsDefault() {
        return isDefault;
    }

    public void setIsDefault(Boolean isDefault) {
        this.isDefault = isDefault;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
