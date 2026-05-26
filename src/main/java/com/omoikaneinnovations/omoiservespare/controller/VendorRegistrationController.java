package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.VendorRegistrationRequest;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.entity.VendorStatus;
import com.omoikaneinnovations.omoiservespare.service.VendorRegistrationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Vendor Registration Controller
 * 
 * Endpoints:
 * - POST /api/vendor/register - Register as vendor (public)
 * - GET /api/vendor/status/{email} - Check application status (public)
 */
@RestController
@RequestMapping("/api/vendor")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class VendorRegistrationController {
    
    private final VendorRegistrationService vendorRegistrationService;
    
    /**
     * Register as vendor
     * Public endpoint - anyone can apply
     * Application will be PENDING until admin approves
     */
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerVendor(
            @RequestBody VendorRegistrationRequest request) {
        
        log.info("Vendor registration request: {} ({})", request.getRestaurantName(), request.getEmail());
        
        try {
            User vendor = vendorRegistrationService.registerVendor(request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Vendor application submitted successfully");
            response.put("status", "PENDING");
            response.put("email", vendor.getEmail());
            response.put("info", "Your application is under review. You will receive an email once approved.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Vendor registration failed: {}", e.getMessage());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", e.getMessage());
            
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Check vendor application status
     * Public endpoint - anyone can check with email
     */
    @GetMapping("/status/{email}")
    public ResponseEntity<Map<String, Object>> checkApplicationStatus(
            @PathVariable String email) {
        
        log.info("Checking vendor application status for: {}", email);
        
        try {
            VendorStatus status = vendorRegistrationService.checkApplicationStatus(email);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("email", email);
            response.put("status", status);
            response.put("message", getStatusMessage(status));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Failed to check status: {}", e.getMessage());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", e.getMessage());
            
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    private String getStatusMessage(VendorStatus status) {
        return switch (status) {
            case PENDING -> "Your application is under review. We'll notify you once it's processed.";
            case APPROVED -> "Your application has been approved! You can now login and start managing your restaurant.";
            case REJECTED -> "Your application was not approved. Please contact support for more information.";
            case SUSPENDED -> "Your account has been suspended. Please contact support.";
        };
    }
}
