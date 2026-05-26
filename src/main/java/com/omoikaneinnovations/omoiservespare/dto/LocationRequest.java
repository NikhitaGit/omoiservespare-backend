package com.omoikaneinnovations.omoiservespare.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 📍 Location Request DTO
 * Handles both current location and manual address input
 */
public class LocationRequest {

    @NotBlank(message = "Title is required")
    private String title; // Home, Work, Other

    private String address; // Optional for current location, required for manual

    private Double latitude;
    private Double longitude;

    private String phoneNumber;

    @NotNull(message = "Location type is required")
    private LocationType type; // CURRENT or MANUAL

    public enum LocationType {
        CURRENT,  // GPS-based location
        MANUAL    // User-entered address
    }

    // Getters and Setters
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

    public LocationType getType() {
        return type;
    }

    public void setType(LocationType type) {
        this.type = type;
    }
}
