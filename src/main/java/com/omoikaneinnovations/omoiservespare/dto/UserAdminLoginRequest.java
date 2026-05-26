package com.omoikaneinnovations.omoiservespare.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * Login request for USER and ADMIN roles
 * Uses company name + email → OTP flow
 */
@Data
public class UserAdminLoginRequest {
    
    @NotBlank(message = "Company name is required")
    private String companyName;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    private String phoneNumber; // Optional, can use email OR phone
}
