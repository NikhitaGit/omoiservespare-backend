package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.service.GoogleMapsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 📊 Google Maps API Monitoring Controller
 * Provides usage statistics and health checks
 */
@RestController
@RequestMapping("/api/admin/google-maps")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:5174"})
public class GoogleMapsMonitoringController {

    @Autowired
    private GoogleMapsService googleMapsService;

    /**
     * 📊 Get API usage statistics
     * GET /api/admin/google-maps/stats
     */
    @GetMapping("/stats")
    public ResponseEntity<?> getUsageStats() {
        try {
            Map<String, Object> stats = googleMapsService.getUsageStats();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", stats
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    /**
     * ✅ Health check
     * GET /api/admin/google-maps/health
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        boolean configured = googleMapsService.isConfigured();
        return ResponseEntity.ok(Map.of(
            "success", true,
            "configured", configured,
            "status", configured ? "READY" : "NOT_CONFIGURED"
        ));
    }

    /**
     * 🗑️ Clear cache (admin only)
     * POST /api/admin/google-maps/clear-cache
     */
    @PostMapping("/clear-cache")
    public ResponseEntity<?> clearCache() {
        try {
            googleMapsService.clearCache();
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Cache cleared successfully"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}
