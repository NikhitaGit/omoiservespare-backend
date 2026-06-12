package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.service.OrderCleanupScheduler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Admin endpoint for order cleanup operations
 * 
 * Endpoints:
 * - GET  /api/admin/orders/cleanup/status - Check how many orders would be deleted
 * - POST /api/admin/orders/cleanup/run    - Manually trigger cleanup
 * - POST /api/admin/orders/cleanup/custom - Delete orders older than X years
 */
@RestController
@RequestMapping("/api/admin/orders/cleanup")
@RequiredArgsConstructor
@Slf4j
public class AdminOrderCleanupController {

    private final OrderCleanupScheduler orderCleanupScheduler;

    /**
     * Check cleanup status
     * GET /api/admin/orders/cleanup/status?years=1
     */
    @GetMapping("/status")
    public ResponseEntity<?> getCleanupStatus(
            @RequestParam(defaultValue = "1") int years) {
        try {
            int oldOrdersCount = orderCleanupScheduler.getOldOrdersCount(years);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Found " + oldOrdersCount + " orders older than " + years + " year(s)",
                "ordersToDelete", oldOrdersCount,
                "yearsThreshold", years
            ));
            
        } catch (Exception e) {
            log.error("Failed to get cleanup status", e);
            return ResponseEntity.status(500).body(Map.of(
                "success", false,
                "message", "Failed to get cleanup status: " + e.getMessage()
            ));
        }
    }

    /**
     * Manually trigger cleanup (1 year threshold)
     * POST /api/admin/orders/cleanup/run
     */
    @PostMapping("/run")
    public ResponseEntity<?> runCleanup() {
        try {
            log.info("🔧 Admin triggered order cleanup");
            
            orderCleanupScheduler.cleanupOldOrders();
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Cleanup completed successfully"
            ));
            
        } catch (Exception e) {
            log.error("Failed to run cleanup", e);
            return ResponseEntity.status(500).body(Map.of(
                "success", false,
                "message", "Cleanup failed: " + e.getMessage()
            ));
        }
    }

    /**
     * Delete orders older than custom threshold
     * POST /api/admin/orders/cleanup/custom?years=2
     */
    @PostMapping("/custom")
    public ResponseEntity<?> runCustomCleanup(
            @RequestParam int years) {
        try {
            if (years < 1) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Years must be at least 1"
                ));
            }
            
            log.info("🔧 Admin triggered custom cleanup - {} years", years);
            
            int deletedCount = orderCleanupScheduler.cleanupOrdersOlderThan(years);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Deleted " + deletedCount + " orders older than " + years + " year(s)",
                "deletedCount", deletedCount,
                "yearsThreshold", years
            ));
            
        } catch (Exception e) {
            log.error("Failed to run custom cleanup", e);
            return ResponseEntity.status(500).body(Map.of(
                "success", false,
                "message", "Cleanup failed: " + e.getMessage()
            ));
        }
    }
}