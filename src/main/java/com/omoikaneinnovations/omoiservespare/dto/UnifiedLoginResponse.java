package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Unified login response for all authentication flows
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UnifiedLoginResponse {
    
    private boolean success;
    private String message;
    
    // For OTP flow (USER/ADMIN)
    private Boolean otpRequired;
    
    // For direct login (VENDOR) or after OTP verification
    private String accessToken;
    private String refreshToken;
    
    // User information
    private Long userId;
    private String email;
    private String role;
    private String companyName;
    private String phoneNumber;
    private String accountType;
    
    // Vendor-specific
    private String vendorStatus;
    private String restaurantName;
    
    /**
     * Create OTP required response
     */
    public static UnifiedLoginResponse otpRequired(String message) {
        return UnifiedLoginResponse.builder()
                .success(true)
                .message(message)
                .otpRequired(true)
                .build();
    }
    
    /**
     * Create successful login response with tokens
     */
    public static UnifiedLoginResponse loginSuccess(
            String accessToken,
            String refreshToken,
            Long userId,
            String email,
            String role,
            String companyName,
            String phoneNumber,
            String accountType,
            String vendorStatus,
            String restaurantName) {
        
        return UnifiedLoginResponse.builder()
                .success(true)
                .message("Login successful")
                .otpRequired(false)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(userId)
                .email(email)
                .role(role)
                .companyName(companyName)
                .phoneNumber(phoneNumber)
                .accountType(accountType)
                .vendorStatus(vendorStatus)
                .restaurantName(restaurantName)
                .build();
    }
    
    /**
     * Create error response
     */
    public static UnifiedLoginResponse error(String message) {
        return UnifiedLoginResponse.builder()
                .success(false)
                .message(message)
                .build();
    }
}
