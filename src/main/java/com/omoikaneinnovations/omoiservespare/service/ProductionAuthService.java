package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.domain.AccountType;
import com.omoikaneinnovations.omoiservespare.dto.*;
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.entity.VendorStatus;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.security.JwtUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 🔐 Production-Grade Unified Authentication Service
 * 
 * Supports two authentication flows:
 * 1. USER/ADMIN: Company Name + Email → OTP → JWT
 * 2. VENDOR: Email + Password → JWT (direct)
 * 
 * Features:
 * - Unified users table with role-based access
 * - BCrypt password hashing for vendors
 * - OTP verification for users/admins
 * - JWT token generation with refresh tokens
 * - Account status validation
 * - Vendor approval workflow
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ProductionAuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthService otpAuthService; // Reuse existing OTP service
    
    /**
     * ========================================
     * VENDOR LOGIN (Email + Password)
     * ========================================
     */
    @Transactional(readOnly = true)
    public UnifiedLoginResponse vendorLogin(VendorLoginRequest request, String deviceId, HttpServletResponse response) {
        log.info("Vendor login attempt: {}", request.getEmail());
        
        // Find user by email
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));
        
        // Verify role is VENDOR
        if (user.getRole() != Role.VENDOR) {
            log.warn("Non-vendor attempted vendor login: {} (role: {})", request.getEmail(), user.getRole());
            throw new RuntimeException("Invalid credentials");
        }
        
        // Verify password
        if (user.getPasswordHash() == null || 
            !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            log.warn("Invalid password for vendor: {}", request.getEmail());
            throw new RuntimeException("Invalid credentials");
        }
        
        // Check account status
        if (!user.getAccountActive()) {
            log.warn("Inactive account login attempt: {}", request.getEmail());
            throw new RuntimeException("Account is disabled");
        }
        
        // Check vendor approval status
        if (user.getVendorStatus() != VendorStatus.APPROVED) {
            log.warn("Unapproved vendor login attempt: {} (status: {})", 
                    request.getEmail(), user.getVendorStatus());
            throw new RuntimeException("Vendor account is not approved. Status: " + user.getVendorStatus());
        }
        
        // Generate tokens
        String accessToken = jwtUtil.generateTokenWithRole(
                user.getEmail(), 
                user.getRole().name(), 
                user.getAccountType() != null ? user.getAccountType() : AccountType.PROFESSIONAL
        );
        
        String refreshToken = jwtUtil.generateRefreshToken();
        
        // Set refresh token as HTTP-only cookie
        setRefreshTokenCookie(response, refreshToken);
        
        log.info("Vendor login successful: {} (id: {})", user.getEmail(), user.getId());
        
        return UnifiedLoginResponse.loginSuccess(
                accessToken,
                refreshToken,
                user.getId(),
                user.getEmail(),
                user.getRole().name(),
                user.getCompanyName(),
                user.getPhoneNumber(),
                user.getAccountType() != null ? user.getAccountType().name() : null,
                user.getVendorStatus() != null ? user.getVendorStatus().name() : null,
                user.getCompanyName() // Using companyName as restaurantName for now
        );
    }
    
    /**
     * ========================================
     * USER/ADMIN LOGIN (Company + Email → OTP)
     * ========================================
     */
    @Transactional
    public UnifiedLoginResponse userAdminLogin(UserAdminLoginRequest request) {
        log.info("User/Admin login attempt: {} from company: {}", 
                request.getEmail(), request.getCompanyName());
        
        // Validate with HR system (existing logic)
        boolean isValid = otpAuthService.validateLogin(
                request.getCompanyName(),
                request.getEmail(),
                request.getPhoneNumber(),
                null // accountType not needed for validation
        );
        
        if (!isValid) {
            log.warn("Invalid credentials for user/admin: {}", request.getEmail());
            throw new RuntimeException("Invalid credentials or user not found in HR system");
        }
        
        // Check if user exists in database
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        
        // If user doesn't exist, create them (first-time login)
        if (user == null) {
            user = createUserFromHR(request);
            log.info("Created new user from HR data: {}", user.getEmail());
        }
        
        // Verify role is USER or ADMIN
        if (user.getRole() == Role.VENDOR) {
            log.warn("Vendor attempted user/admin login: {}", request.getEmail());
            throw new RuntimeException("Please use vendor login portal");
        }
        
        // Check account status
        if (!user.getAccountActive()) {
            log.warn("Inactive account login attempt: {}", request.getEmail());
            throw new RuntimeException("Account is disabled");
        }
        
        // OTP sent successfully
        log.info("OTP sent to: {}", request.getEmail());
        return UnifiedLoginResponse.otpRequired("OTP sent successfully to your email");
    }
    
    /**
     * ========================================
     * OTP VERIFICATION (for USER/ADMIN)
     * ========================================
     */
    @Transactional
    public UnifiedLoginResponse verifyOtpAndLogin(
            OtpRequest request, 
            String deviceId, 
            HttpServletResponse response) {
        
        log.info("OTP verification attempt: {}", request.getEmail());
        
        // Verify OTP (existing logic)
        boolean isValid = otpAuthService.verifyOtp(request.getEmail(), request.getOtp());
        
        if (!isValid) {
            log.warn("Invalid OTP for: {}", request.getEmail());
            throw new RuntimeException("Invalid or expired OTP");
        }
        
        // Get user
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Generate tokens
        String accessToken = jwtUtil.generateTokenWithRole(
                user.getEmail(),
                user.getRole().name(),
                user.getAccountType() != null ? user.getAccountType() : AccountType.PERSONAL
        );
        
        String refreshToken = jwtUtil.generateRefreshToken();
        
        // Set refresh token as HTTP-only cookie
        setRefreshTokenCookie(response, refreshToken);
        
        log.info("OTP verification successful: {} (role: {})", user.getEmail(), user.getRole());
        
        return UnifiedLoginResponse.loginSuccess(
                accessToken,
                refreshToken,
                user.getId(),
                user.getEmail(),
                user.getRole().name(),
                user.getCompanyName(),
                user.getPhoneNumber(),
                user.getAccountType() != null ? user.getAccountType().name() : null,
                user.getVendorStatus() != null ? user.getVendorStatus().name() : null,
                null // restaurantName only for vendors
        );
    }
    
    /**
     * ========================================
     * HELPER METHODS
     * ========================================
     */
    
    /**
     * Create user from HR data (first-time login)
     */
    private User createUserFromHR(UserAdminLoginRequest request) {
        User user = new User();
        user.setEmail(request.getEmail());
        user.setCompanyName(request.getCompanyName());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setRole(Role.USER); // Default role
        user.setAccountActive(true);
        
        return userRepository.save(user);
    }
    
    /**
     * Set refresh token as HTTP-only cookie
     */
    private void setRefreshTokenCookie(HttpServletResponse response, String refreshToken) {
        Cookie cookie = new Cookie("refreshToken", refreshToken);
        cookie.setHttpOnly(true);
        cookie.setSecure(false); // Set to true in production with HTTPS
        cookie.setPath("/");
        cookie.setMaxAge(7 * 24 * 60 * 60); // 7 days
        response.addCookie(cookie);
    }
    
    /**
     * ========================================
     * ADMIN OPERATIONS
     * ========================================
     */
    
    /**
     * Promote user to admin (requires existing admin)
     */
    @Transactional
    public User promoteToAdmin(String email, String adminEmail) {
        log.info("Admin {} promoting {} to ADMIN role", adminEmail, email);
        
        // Verify requester is admin
        User admin = userRepository.findByEmail(adminEmail)
                .orElseThrow(() -> new RuntimeException("Admin not found"));
        
        if (admin.getRole() != Role.ADMIN) {
            throw new RuntimeException("Only admins can promote users");
        }
        
        // Get target user
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Promote to admin
        user.setRole(Role.ADMIN);
        
        return userRepository.save(user);
    }
    
    /**
     * Set password for admin (allows admin to use vendor portal)
     */
    @Transactional
    public void setAdminPassword(String email, String password) {
        log.info("Setting password for admin: {}", email);
        
        User admin = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Admin not found"));
        
        if (admin.getRole() != Role.ADMIN) {
            throw new RuntimeException("User is not an admin");
        }
        
        admin.setPasswordHash(passwordEncoder.encode(password));
        userRepository.save(admin);
        
        log.info("Password set for admin: {}", email);
    }
}
