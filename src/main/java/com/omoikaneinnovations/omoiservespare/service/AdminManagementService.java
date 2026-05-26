package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.AdminCreationRequest;
import com.omoikaneinnovations.omoiservespare.dto.VendorApprovalRequest;
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.entity.VendorStatus;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Admin Management Service
 * Handles admin creation and vendor approval
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AdminManagementService {
    
    private final UserRepository userRepository;
    
    @Value("${app.admin.secret-key:SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD}")
    private String adminSecretKey;
    
    /**
     * Create first admin using secret key
     * After first admin is created, use createAdminByAdmin()
     */
    @Transactional
    public User createFirstAdmin(AdminCreationRequest request) {
        log.info("Attempting to create first admin with email: {}", request.getEmail());
        
        // Verify secret key
        if (!adminSecretKey.equals(request.getSecretKey())) {
            throw new RuntimeException("Invalid secret key");
        }
        
        // Check if any admin already exists
        long adminCount = userRepository.countByRole(Role.ADMIN);
        if (adminCount > 0) {
            throw new RuntimeException("Admin already exists. Use admin creation endpoint instead.");
        }
        
        // Check if user already exists
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("User with this email already exists");
        }
        
        // Create admin user
        User admin = new User();
        admin.setEmail(request.getEmail());
        admin.setPhoneNumber(request.getPhoneNumber());
        admin.setRole(Role.ADMIN);
        admin.setAccountActive(true);
        
        User savedAdmin = userRepository.save(admin);
        log.info("First admin created successfully: {}", savedAdmin.getEmail());
        
        return savedAdmin;
    }
    
    /**
     * Create new admin (requires existing admin)
     * Called by existing admin to create another admin
     */
    @Transactional
    public User createAdminByAdmin(AdminCreationRequest request, String creatorEmail) {
        log.info("Admin {} attempting to create new admin: {}", creatorEmail, request.getEmail());
        
        // Verify creator is admin
        User creator = userRepository.findByEmail(creatorEmail)
            .orElseThrow(() -> new RuntimeException("Creator not found"));
        
        if (creator.getRole() != Role.ADMIN) {
            throw new RuntimeException("Only admins can create other admins");
        }
        
        // Check if user already exists
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("User with this email already exists");
        }
        
        // Create admin user
        User admin = new User();
        admin.setEmail(request.getEmail());
        admin.setPhoneNumber(request.getPhoneNumber());
        admin.setRole(Role.ADMIN);
        admin.setAccountActive(true);
        
        User savedAdmin = userRepository.save(admin);
        log.info("New admin created by {}: {}", creatorEmail, savedAdmin.getEmail());
        
        return savedAdmin;
    }
    
    /**
     * Get all pending vendor applications
     */
    public List<User> getPendingVendors() {
        return userRepository.findByRoleAndVendorStatus(Role.VENDOR, VendorStatus.PENDING);
    }
    
    /**
     * Get all vendors (any status)
     */
    public List<User> getAllVendors() {
        return userRepository.findByRole(Role.VENDOR);
    }
    
    /**
     * Approve or reject vendor application
     */
    @Transactional
    public User processVendorApplication(Long vendorId, VendorApprovalRequest request, String adminEmail) {
        log.info("Admin {} processing vendor application {}: {}", adminEmail, vendorId, request.getAction());
        
        // Verify admin
        User admin = userRepository.findByEmail(adminEmail)
            .orElseThrow(() -> new RuntimeException("Admin not found"));
        
        if (admin.getRole() != Role.ADMIN) {
            throw new RuntimeException("Only admins can approve vendors");
        }
        
        // Get vendor
        User vendor = userRepository.findById(vendorId)
            .orElseThrow(() -> new RuntimeException("Vendor not found"));
        
        if (vendor.getRole() != Role.VENDOR) {
            throw new RuntimeException("User is not a vendor");
        }
        
        // Process action
        if ("APPROVE".equalsIgnoreCase(request.getAction())) {
            vendor.setVendorStatus(VendorStatus.APPROVED);
            vendor.setAccountActive(true);
            log.info("Vendor {} approved by admin {}", vendor.getEmail(), adminEmail);
        } else if ("REJECT".equalsIgnoreCase(request.getAction())) {
            vendor.setVendorStatus(VendorStatus.REJECTED);
            vendor.setAccountActive(false);
            log.info("Vendor {} rejected by admin {}: {}", vendor.getEmail(), adminEmail, request.getReason());
        } else {
            throw new RuntimeException("Invalid action. Use APPROVE or REJECT");
        }
        
        return userRepository.save(vendor);
    }
    
    /**
     * Suspend vendor
     */
    @Transactional
    public User suspendVendor(Long vendorId, String adminEmail, String reason) {
        log.info("Admin {} suspending vendor {}: {}", adminEmail, vendorId, reason);
        
        User vendor = userRepository.findById(vendorId)
            .orElseThrow(() -> new RuntimeException("Vendor not found"));
        
        if (vendor.getRole() != Role.VENDOR) {
            throw new RuntimeException("User is not a vendor");
        }
        
        vendor.setVendorStatus(VendorStatus.SUSPENDED);
        vendor.setAccountActive(false);
        
        return userRepository.save(vendor);
    }
}
