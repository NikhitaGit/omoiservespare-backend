package com.omoikaneinnovations.omoiservespare.dto;

import com.omoikaneinnovations.omoiservespare.entity.Role;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Signup request for USER and VENDOR roles
 * Admin accounts are created separately via AdminManagementService
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SignupRequest {
    private String email;
    private String password;
    private String companyName;
    private String phoneNumber;
    private Role role; // USER or VENDOR
}
