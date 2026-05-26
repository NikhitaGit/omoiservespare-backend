package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.AdminDashboardDTO;
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.security.RequireRole;
import com.omoikaneinnovations.omoiservespare.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Admin Dashboard REST API
 * 
 * Endpoints:
 * - GET /api/admin/dashboard - Main dashboard data (ADMIN ONLY)
 * 
 * Features:
 * - Date range filtering
 * - Pre-calculated metrics
 * - UI-ready responses
 * - Fast response times (<200ms)
 * - RBAC protected
 */
@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AdminDashboardController {
    
    private final AdminDashboardService dashboardService;
    
    /**
     * Get complete dashboard data
     * 🔒 ADMIN & VENDOR ACCESS
     * 
     * @param range Range type: today, week, 15d, month, year
     * @param start Optional start date (overrides range)
     * @param end Optional end date (overrides range)
     * @return Complete dashboard data with all metrics
     */
    @GetMapping
    @RequireRole({Role.ADMIN, Role.VENDOR})
    public ResponseEntity<AdminDashboardDTO> getDashboard(
            @RequestParam(defaultValue = "week") String range,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        
        log.info("Dashboard request: range={}, start={}, end={}", range, start, end);
        
        // Calculate date range
        LocalDateTime startDateTime;
        LocalDateTime endDateTime = LocalDateTime.now();
        
        if (start != null && end != null) {
            // Use provided dates
            startDateTime = start.atStartOfDay();
            endDateTime = end.atTime(LocalTime.MAX);
        } else {
            // Calculate from range
            startDateTime = calculateStartDate(range);
        }
        
        AdminDashboardDTO dashboard = dashboardService.getDashboardData(range, startDateTime, endDateTime);
        
        return ResponseEntity.ok(dashboard);
    }
    
    /**
     * Health check endpoint (no auth required)
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Admin Dashboard API is running");
    }
    
    // ========================================
    // HELPER METHODS
    // ========================================
    
    private LocalDateTime calculateStartDate(String range) {
        LocalDateTime now = LocalDateTime.now();
        
        return switch (range) {
            case "today" -> LocalDate.now().atStartOfDay();
            case "week" -> now.minusDays(6).toLocalDate().atStartOfDay();
            case "15d" -> now.minusDays(14).toLocalDate().atStartOfDay();
            case "month" -> LocalDate.now().withDayOfMonth(1).atStartOfDay();
            case "year" -> LocalDate.now().withDayOfYear(1).atStartOfDay();
            default -> now.minusDays(6).toLocalDate().atStartOfDay();
        };
    }
}
