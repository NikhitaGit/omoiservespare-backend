package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;

/**
 * Admin Creation Request
 * Only existing admins can create new admins
 */
@Data
public class AdminCreationRequest {
    private String email;
    private String phoneNumber;
    private String fullName;
    private String secretKey; // For first admin creation only
}
