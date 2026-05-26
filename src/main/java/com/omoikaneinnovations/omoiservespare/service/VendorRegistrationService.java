package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.VendorRegistrationRequest;
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.entity.Vendor;
import com.omoikaneinnovations.omoiservespare.entity.VendorStatus;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.repository.VendorRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Vendor Registration Service
 * Handles vendor application process
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class VendorRegistrationService {
    
    private final UserRepository userRepository;
    private final VendorRepository vendorRepository;
    private final EmailService emailService;
    
    /**
     * Register new vendor (application)
     * Status will be PENDING until admin approves
     */
    @Transactional
    public User registerVendor(VendorRegistrationRequest request) {
        log.info("New vendor registration: {} ({})", request.getRestaurantName(), request.getEmail());
        
        // Check if user already exists
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("User with this email already exists");
        }
        
        // Check if phone number already exists
        if (userRepository.findByPhoneNumber(request.getPhoneNumber()).isPresent()) {
            throw new RuntimeException("User with this phone number already exists");
        }
        
        // Create vendor user with PENDING status
        User vendorUser = new User();
        vendorUser.setEmail(request.getEmail());
        vendorUser.setPhoneNumber(request.getPhoneNumber());
        vendorUser.setCompanyName(request.getRestaurantName());
        vendorUser.setRole(Role.VENDOR);
        vendorUser.setVendorStatus(VendorStatus.PENDING);
        vendorUser.setAccountActive(false); // Inactive until approved
        
        User savedVendor = userRepository.save(vendorUser);
        
        // Store vendor-specific details
        Vendor vendorDetails = new Vendor();
        vendorDetails.setUserId(savedVendor.getId());
        vendorDetails.setRestaurantName(request.getRestaurantName());
        vendorDetails.setOwnerName(request.getOwnerName());
        vendorDetails.setAddress(request.getAddress());
        vendorDetails.setBusinessLicense(request.getBusinessLicense());
        vendorDetails.setDescription(request.getDescription());
        
        vendorRepository.save(vendorDetails);
        log.info("Vendor application submitted: {} - Status: PENDING", savedVendor.getEmail());
        
        // Send confirmation email
        sendVendorApplicationEmail(savedVendor, request);
        
        // Notify admins about new vendor application
        notifyAdminsAboutNewVendor(savedVendor, request);
        
        return savedVendor;
    }
    
    /**
     * Check vendor application status
     */
    public VendorStatus checkApplicationStatus(String email) {
        User vendor = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Vendor not found"));
        
        if (vendor.getRole() != Role.VENDOR) {
            throw new RuntimeException("User is not a vendor");
        }
        
        return vendor.getVendorStatus();
    }
    
    private void sendVendorApplicationEmail(User vendor, VendorRegistrationRequest request) {
        try {
            // TODO: Implement vendor application email
            // For now, just log it
            log.info("Vendor application email would be sent to: {}", vendor.getEmail());
            log.info("Restaurant: {}, Owner: {}", request.getRestaurantName(), request.getOwnerName());
        } catch (Exception e) {
            log.error("Failed to send vendor application email: {}", e.getMessage());
        }
    }
    
    private void notifyAdminsAboutNewVendor(User vendor, VendorRegistrationRequest request) {
        try {
            // TODO: Implement admin notification email
            // For now, just log it
            log.info("Admin notification would be sent for new vendor: {}", vendor.getEmail());
            log.info("Restaurant: {}, License: {}", request.getRestaurantName(), request.getBusinessLicense());
        } catch (Exception e) {
            log.error("Failed to notify admins about new vendor: {}", e.getMessage());
        }
    }
}
