package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.domain.AccountType;
import com.omoikaneinnovations.omoiservespare.dto.AuthResponse;
import com.omoikaneinnovations.omoiservespare.dto.PasswordLoginRequest;
import com.omoikaneinnovations.omoiservespare.dto.SignupRequest;
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.entity.VendorStatus;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UnifiedAuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    
    public AuthResponse login(PasswordLoginRequest request) {
        log.info("Login attempt for email: {}", request.getEmail());
        
        User user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new RuntimeException("Invalid email or password"));
        
        if (user.getPasswordHash() == null || 
            !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid email or password");
        }
        
        if (!user.getAccountActive()) {
            throw new RuntimeException("Account is suspended. Contact support.");
        }
        
        if (user.getRole() == Role.VENDOR) {
            if (user.getVendorStatus() == VendorStatus.PENDING) {
                throw new RuntimeException("Vendor application pending approval");
            }
            if (user.getVendorStatus() == VendorStatus.REJECTED) {
                throw new RuntimeException("Vendor application was rejected");
            }
            if (user.getVendorStatus() == VendorStatus.SUSPENDED) {
                throw new RuntimeException("Vendor account is suspended");
            }
        }
        
        String token = jwtUtil.generateTokenWithRole(user.getEmail(), user.getRole().name(), user.getAccountType());
        
        log.info("Login successful for {} with role {}", user.getEmail(), user.getRole());
        
        return new AuthResponse(true, "Login successful", token, mapToUserInfo(user));
    }
    
    @Transactional
    public AuthResponse signup(SignupRequest request) {
        log.info("Signup attempt for email: {} with role: {}", request.getEmail(), request.getRole());
        
        if (request.getRole() == Role.ADMIN) {
            throw new RuntimeException("Admin accounts cannot be created through signup");
        }
        
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered");
        }
        
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setCompanyName(request.getCompanyName());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setRole(request.getRole());
        user.setAccountActive(true);
        
        if (request.getRole() == Role.VENDOR) {
            user.setAccountType(AccountType.PROFESSIONAL);
            user.setVendorStatus(VendorStatus.PENDING);
        } else {
            user.setAccountType(AccountType.PERSONAL);
        }
        
        User savedUser = userRepository.save(user);
        
        String token = jwtUtil.generateTokenWithRole(savedUser.getEmail(), savedUser.getRole().name(), savedUser.getAccountType());
        
        String message = request.getRole() == Role.VENDOR 
            ? "Vendor registration successful. Awaiting admin approval."
            : "Signup successful";
        
        log.info("Signup successful for {} with role {}", savedUser.getEmail(), savedUser.getRole());
        
        return new AuthResponse(true, message, token, mapToUserInfo(savedUser));
    }
    
    @Transactional
    public void setPassword(String email, String newPassword) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        
        log.info("Password set for user: {}", email);
    }
    
    private AuthResponse.UserInfo mapToUserInfo(User user) {
        return new AuthResponse.UserInfo(
            user.getId(),
            user.getEmail(),
            user.getCompanyName(),
            user.getPhoneNumber(),
            user.getRole(),
            user.getVendorStatus(),
            user.getAccountActive()
        );
    }
}