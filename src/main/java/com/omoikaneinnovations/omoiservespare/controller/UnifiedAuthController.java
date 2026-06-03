package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.*;
import com.omoikaneinnovations.omoiservespare.service.ProductionAuthService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * 🔐 Unified Authentication Controller
 * 
 * Endpoints:
 * - POST /api/auth/vendor/login - Vendor login (email + password)
 * - POST /api/auth/user/login - User/Admin login (company + email → OTP)
 * - POST /api/auth/verify-otp - Verify OTP and complete login
 * - POST /api/auth/refresh - Refresh access token
 * 
 * Features:
 * - Separate login flows for different roles
 * - Unified response format
 * - JWT token generation
 * - Refresh token support
 * - Device-bound tokens
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(
    origins = {
        "https://lata-frontend-flame.vercel.app",
        "https://lata-frontend-git-main-omoi-servespare-s-projects.vercel.app",
        "http://localhost:5173",
        "http://localhost:5174"
    },
    allowCredentials = "true"
)
public class UnifiedAuthController {
    
    private final ProductionAuthService authService;
    
    /**
     * ========================================
     * VENDOR LOGIN (Email + Password)
     * ========================================
     * 
     * Used by: Vendors on port 5174
     * Flow: Email + Password → JWT tokens
     * 
     * Request:
     * {
     *   "email": "vendor@restaurant.com",
     *   "password": "vendor123"
     * }
     * 
     * Response:
     * {
     *   "success": true,
     *   "message": "Login successful",
     *   "accessToken": "eyJ...",
     *   "refreshToken": "...",
     *   "userId": 1,
     *   "email": "vendor@restaurant.com",
     *   "role": "VENDOR",
     *   "vendorStatus": "APPROVED"
     * }
     */
    @PostMapping("/vendor/login")
    public ResponseEntity<UnifiedLoginResponse> vendorLogin(
            @Valid @RequestBody VendorLoginRequest request,
            @RequestHeader(value = "X-Device-Id", required = false) String deviceId,
            HttpServletResponse response) {
        
        log.info("Vendor login request: {}", request.getEmail());
        
        // Generate device ID if not provided
        if (deviceId == null || deviceId.trim().isEmpty()) {
            deviceId = java.util.UUID.randomUUID().toString();
            log.info("Generated device ID: {}", deviceId);
        }
        
        try {
            UnifiedLoginResponse loginResponse = authService.vendorLogin(request, deviceId, response);
            return ResponseEntity.ok(loginResponse);
            
        } catch (Exception e) {
            log.error("Vendor login failed: {}", e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(UnifiedLoginResponse.error(e.getMessage()));
        }
    }
    
    /**
     * ========================================
     * USER/ADMIN LOGIN (Company + Email → OTP)
     * ========================================
     * 
     * Used by: Users and Admins on port 5173
     * Flow: Company + Email → OTP sent → Verify OTP → JWT tokens
     * 
     * Request:
     * {
     *   "companyName": "Omoiservespare Pvt Ltd",
     *   "email": "user@company.com",
     *   "phoneNumber": "+91-9876543210"
     * }
     * 
     * Response:
     * {
     *   "success": true,
     *   "message": "OTP sent successfully to your email",
     *   "otpRequired": true
     * }
     */
    @PostMapping("/user/login")
    public ResponseEntity<UnifiedLoginResponse> userAdminLogin(
            @Valid @RequestBody UserAdminLoginRequest request) {
        
        log.info("User/Admin login request: {} from {}", 
                request.getEmail(), request.getCompanyName());
        
        try {
            UnifiedLoginResponse loginResponse = authService.userAdminLogin(request);
            return ResponseEntity.ok(loginResponse);
            
        } catch (Exception e) {
            log.error("User/Admin login failed: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(UnifiedLoginResponse.error(e.getMessage()));
        }
    }
    
    /**
     * ========================================
     * VERIFY OTP (Complete User/Admin Login)
     * ========================================
     * 
     * Used by: Users and Admins after receiving OTP
     * Flow: Email + OTP → JWT tokens
     * 
     * Request:
     * {
     *   "email": "user@company.com",
     *   "otp": "1234"
     * }
     * 
     * Response:
     * {
     *   "success": true,
     *   "message": "Login successful",
     *   "accessToken": "eyJ...",
     *   "refreshToken": "...",
     *   "userId": 1,
     *   "email": "user@company.com",
     *   "role": "USER"
     * }
     */
    @PostMapping("/verify-otp")
    public ResponseEntity<UnifiedLoginResponse> verifyOtp(
            @Valid @RequestBody OtpRequest request,
            @RequestHeader(value = "X-Device-Id", required = false) String deviceId,
            HttpServletResponse response) {
        
        log.info("OTP verification request: {}", request.getEmail());
        
        // Generate device ID if not provided
        if (deviceId == null || deviceId.trim().isEmpty()) {
            deviceId = java.util.UUID.randomUUID().toString();
            log.info("Generated device ID: {}", deviceId);
        }
        
        try {
            UnifiedLoginResponse loginResponse = authService.verifyOtpAndLogin(
                    request, deviceId, response);
            return ResponseEntity.ok(loginResponse);
            
        } catch (Exception e) {
            log.error("OTP verification failed: {}", e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(UnifiedLoginResponse.error(e.getMessage()));
        }
    }
    
    /**
     * ========================================
     * REFRESH TOKEN
     * ========================================
     * 
     * Used by: All roles to refresh expired access tokens
     * Flow: Refresh token (cookie) → New access token
     * 
     * Response:
     * {
     *   "success": true,
     *   "accessToken": "eyJ...",
     *   "refreshToken": "..."
     * }
     */
    @PostMapping("/refresh")
    public ResponseEntity<UnifiedLoginResponse> refreshToken(
            @CookieValue(name = "refreshToken") String refreshToken,
            @RequestHeader("X-Device-Id") String deviceId,
            HttpServletResponse response) {
        
        log.info("Token refresh request");
        
        try {
            // Reuse existing refresh logic from AuthService
            // This would need to be implemented in ProductionAuthService
            return ResponseEntity.ok(UnifiedLoginResponse.error("Refresh token logic to be implemented"));
            
        } catch (Exception e) {
            log.error("Token refresh failed: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(UnifiedLoginResponse.error(e.getMessage()));
        }
    }
    
    /**
     * ========================================
     * HEALTH CHECK
     * ========================================
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Unified Auth API is running");
    }
}
