package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.AdminCreationRequest;
import com.omoikaneinnovations.omoiservespare.dto.VendorApprovalRequest;
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.security.JwtUtil;
import com.omoikaneinnovations.omoiservespare.security.RequireRole;
import com.omoikaneinnovations.omoiservespare.service.AdminManagementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Admin Management Controller
 * 
 * Endpoints:
 * - POST /api/admin/create-first - Create first admin (secret key required)
 * - POST /api/admin/create - Create new admin (requires existing admin)
 * - GET /api/admin/vendors/pending - Get pending vendor applications
 * - GET /api/admin/vendors - Get all vendors
 * - POST /api/admin/vendors/{id}/process - Approve/reject vendor
 * - POST /api/admin/vendors/{id}/suspend - Suspend vendor
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AdminManagementController {
    
    private final AdminManagementService adminManagementService;
    private final JwtUtil jwtUtil;
    
    /**
     * Create first admin using secret key
     * No authentication required (but secret key needed)
     * Use this ONCE to create the first admin
     */
    @PostMapping("/create-first")
    public ResponseEntity<Map<String, Object>> createFirstAdmin(
            @RequestBody AdminCreationRequest request) {
        
        log.info("First admin creation request for: {}", request.getEmail());
        
        try {
            User admin = adminManagementService.createFirstAdmin(request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "First admin created successfully");
            response.put("email", admin.getEmail());
            response.put("role", admin.getRole());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Failed to create first admin: {}", e.getMessage());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", e.getMessage());
            
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Create new admin (requires existing admin)
     * 🔒 ADMIN ONLY
     */
    @PostMapping("/create")
    @RequireRole(Role.ADMIN)
    public ResponseEntity<Map<String, Object>> createAdmin(
            @RequestBody AdminCreationRequest request,
            @RequestHeader("Authorization") String token) {
        
        String creatorEmail = jwtUtil.extractEmail(token.replace("Bearer ", ""));
        log.info("Admin creation request by {} for: {}", creatorEmail, request.getEmail());
        
        try {
            User admin = adminManagementService.createAdminByAdmin(request, creatorEmail);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Admin created successfully");
            response.put("email", admin.getEmail());
            response.put("role", admin.getRole());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Failed to create admin: {}", e.getMessage());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", e.getMessage());
            
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Get all pending vendor applications
     * 🔒 ADMIN ONLY
     */
    @GetMapping("/vendors/pending")
    @RequireRole(Role.ADMIN)
    public ResponseEntity<List<User>> getPendingVendors() {
        log.info("Fetching pending vendor applications");
        List<User> vendors = adminManagementService.getPendingVendors();
        return ResponseEntity.ok(vendors);
    }
    
    /**
     * Get all vendors
     * 🔒 ADMIN ONLY
     */
    @GetMapping("/vendors")
    @RequireRole(Role.ADMIN)
    public ResponseEntity<List<User>> getAllVendors() {
        log.info("Fetching all vendors");
        List<User> vendors = adminManagementService.getAllVendors();
        return ResponseEntity.ok(vendors);
    }
    
    /**
     * Approve or reject vendor application
     * 🔒 ADMIN ONLY
     */
    @PostMapping("/vendors/{vendorId}/process")
    @RequireRole(Role.ADMIN)
    public ResponseEntity<Map<String, Object>> processVendorApplication(
            @PathVariable Long vendorId,
            @RequestBody VendorApprovalRequest request,
            @RequestHeader("Authorization") String token) {
        
        String adminEmail = jwtUtil.extractEmail(token.replace("Bearer ", ""));
        log.info("Processing vendor {} by admin {}: {}", vendorId, adminEmail, request.getAction());
        
        try {
            User vendor = adminManagementService.processVendorApplication(vendorId, request, adminEmail);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Vendor " + request.getAction().toLowerCase() + "d successfully");
            response.put("vendor", Map.of(
                "id", vendor.getId(),
                "email", vendor.getEmail(),
                "status", vendor.getVendorStatus()
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Failed to process vendor application: {}", e.getMessage());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", e.getMessage());
            
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Suspend vendor
     * 🔒 ADMIN ONLY
     */
    @PostMapping("/vendors/{vendorId}/suspend")
    @RequireRole(Role.ADMIN)
    public ResponseEntity<Map<String, Object>> suspendVendor(
            @PathVariable Long vendorId,
            @RequestParam String reason,
            @RequestHeader("Authorization") String token) {
        
        String adminEmail = jwtUtil.extractEmail(token.replace("Bearer ", ""));
        log.info("Suspending vendor {} by admin {}", vendorId, adminEmail);
        
        try {
            User vendor = adminManagementService.suspendVendor(vendorId, adminEmail, reason);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Vendor suspended successfully");
            response.put("vendor", Map.of(
                "id", vendor.getId(),
                "email", vendor.getEmail(),
                "status", vendor.getVendorStatus()
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Failed to suspend vendor: {}", e.getMessage());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", e.getMessage());
            
            return ResponseEntity.badRequest().body(response);
        }
    }
}
