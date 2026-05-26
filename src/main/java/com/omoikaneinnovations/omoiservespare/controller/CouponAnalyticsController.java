package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.service.CouponAnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/coupons/analytics")
@RequiredArgsConstructor
public class CouponAnalyticsController {
    
    private final CouponAnalyticsService analyticsService;
    
    /**
     * Get coupon performance metrics
     */
    @GetMapping("/{couponCode}")
    public ResponseEntity<CouponAnalyticsService.CouponMetrics> getCouponMetrics(
            @PathVariable String couponCode,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        
        LocalDate targetDate = date != null ? date : LocalDate.now();
        CouponAnalyticsService.CouponMetrics metrics = 
            analyticsService.getCouponMetrics(couponCode, targetDate);
        
        return ResponseEntity.ok(metrics);
    }
}
