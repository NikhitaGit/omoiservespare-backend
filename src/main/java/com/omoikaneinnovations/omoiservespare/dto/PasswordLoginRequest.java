package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Password-based login request
 * Works for all roles: USER, VENDOR, ADMIN
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PasswordLoginRequest {
    private String email;
    private String password;
}
