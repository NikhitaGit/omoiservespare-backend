package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.AddressResponse;
import com.omoikaneinnovations.omoiservespare.dto.LocationRequest;
import com.omoikaneinnovations.omoiservespare.security.SecurityUtils;
import com.omoikaneinnovations.omoiservespare.service.LocationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 📍 Location Controller
 * Production-ready location API like Swiggy/Zomato
 */
@RestController
@RequestMapping("/api/location")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:5174"})
public class LocationController {

    @Autowired
    private LocationService locationService;

    /**
     * 📍 Save new location (current or manual)
     * POST /api/location
     */
    @PostMapping
    public ResponseEntity<?> saveLocation(@Valid @RequestBody LocationRequest request) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            AddressResponse response = locationService.saveLocation(userId, request);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Location saved successfully",
                "data", response
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    /**
     * 📋 Get all saved addresses
     * GET /api/location
     */
    @GetMapping
    public ResponseEntity<?> getUserAddresses() {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            List<AddressResponse> addresses = locationService.getUserAddresses(userId);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", addresses
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    /**
     * 🏠 Get default address
     * GET /api/location/default
     */
    @GetMapping("/default")
    public ResponseEntity<?> getDefaultAddress() {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            AddressResponse address = locationService.getDefaultAddress(userId);
            
            if (address == null) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "No default address found",
                    "data", (Object) null
                ));
            }
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", address
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    /**
     * ⭐ Set address as default
     * PUT /api/location/{id}/default
     */
    @PutMapping("/{id}/default")
    public ResponseEntity<?> setDefaultAddress(@PathVariable Long id) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            AddressResponse response = locationService.setDefaultAddress(userId, id);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Default address updated",
                "data", response
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    /**
     * ✏️ Update address
     * PUT /api/location/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateAddress(
            @PathVariable Long id,
            @Valid @RequestBody LocationRequest request) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            AddressResponse response = locationService.updateAddress(userId, id, request);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Address updated successfully",
                "data", response
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    /**
     * 🗑️ Delete address
     * DELETE /api/location/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAddress(@PathVariable Long id) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            locationService.deleteAddress(userId, id);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Address deleted successfully"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}
