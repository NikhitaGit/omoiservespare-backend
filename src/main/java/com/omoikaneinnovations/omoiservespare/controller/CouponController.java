package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.CouponDTO;
import com.omoikaneinnovations.omoiservespare.dto.CouponValidationRequest;
import com.omoikaneinnovations.omoiservespare.dto.CouponValidationResponse;
import com.omoikaneinnovations.omoiservespare.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/coupons")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CouponController {
    
    private final CouponService couponService;
    
    /**
     * Get all active coupons (for coupons page)
     */
    @GetMapping
    public ResponseEntity<List<CouponDTO>> getAllCoupons() {
        List<CouponDTO> coupons = couponService.getAllActiveCoupons();
        return ResponseEntity.ok(coupons);
    }
    
    /**
     * Get available coupons for current cart
     */
    @GetMapping("/available")
    public ResponseEntity<List<CouponDTO>> getAvailableCoupons(
            @RequestParam BigDecimal orderValue,
            @RequestParam(required = false) Long restaurantId,
            Authentication authentication) {
        
        Long userId = getUserId(authentication);
        List<CouponDTO> coupons = couponService.getAvailableCoupons(userId, orderValue, restaurantId);
        return ResponseEntity.ok(coupons);
    }
    
    /**
     * Validate coupon before applying
     */
    @PostMapping("/validate")
    public ResponseEntity<CouponValidationResponse> validateCoupon(
            @RequestBody CouponValidationRequest request,
            Authentication authentication) {
        
        Long userId = getUserId(authentication);
        CouponValidationResponse response = couponService.validateCoupon(
            request.getCouponCode(),
            userId,
            request.getOrderValue(),
            request.getRestaurantId()
        );
        return ResponseEntity.ok(response);
    }
    
    /**
     * Helper method to extract user ID from authentication
     */
    private Long getUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof org.springframework.security.core.userdetails.User) {
            String username = authentication.getName();
            // You might need to fetch user ID from username
            // For now, returning a default value
            return 1L; // Replace with actual user ID extraction logic
        }
        return 1L;
    }
}
