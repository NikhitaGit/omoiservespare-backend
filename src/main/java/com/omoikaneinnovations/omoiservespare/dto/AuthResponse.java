package com.omoikaneinnovations.omoiservespare.dto;

import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.VendorStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Unified authentication response for login and signup
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private boolean success;
    private String message;
    private String token;
    private UserInfo user;
    
    /**
     * User information included in auth response
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInfo {
        private Long id;
        private String email;
        private String companyName;
        private String phoneNumber;
        private Role role;
        private VendorStatus vendorStatus;
        private Boolean accountActive;
    }
}
