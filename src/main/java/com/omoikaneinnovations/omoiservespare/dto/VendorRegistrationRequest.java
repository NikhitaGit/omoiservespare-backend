package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;

/**
 * Vendor Registration Request
 * Used when a restaurant/vendor wants to register
 */
@Data
public class VendorRegistrationRequest {
    private String email;
    private String phoneNumber;
    private String restaurantName;
    private String ownerName;
    private String address;
    private String businessLicense; // License number
    private String description;
}
