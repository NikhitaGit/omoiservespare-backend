package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.CouponDTO;
import com.omoikaneinnovations.omoiservespare.dto.CouponValidationResponse;
import com.omoikaneinnovations.omoiservespare.entity.Coupon;
import com.omoikaneinnovations.omoiservespare.entity.CouponUsage;
import com.omoikaneinnovations.omoiservespare.event.CouponEvent;
import com.omoikaneinnovations.omoiservespare.exception.InvalidCouponException;
import com.omoikaneinnovations.omoiservespare.repository.CouponRepository;
import com.omoikaneinnovations.omoiservespare.repository.CouponUsageRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
@Slf4j
public class CouponService {
    
    private final CouponRepository couponRepository;
    private final CouponUsageRepository usageRepository;
    private final CouponEventProducer eventProducer;
    
    @Autowired(required = false)
    private RedisTemplate<String, Object> redisTemplate;
    
    public CouponService(CouponRepository couponRepository, 
                        CouponUsageRepository usageRepository,
                        CouponEventProducer eventProducer) {
        this.couponRepository = couponRepository;
        this.usageRepository = usageRepository;
        this.eventProducer = eventProducer;
    }
    
    /**
     * Validate coupon in real-time
     */
    public CouponValidationResponse validateCoupon(String couponCode, Long userId, 
                                                    BigDecimal orderValue, Long restaurantId) {
        CouponEvent event = new CouponEvent();
        event.setUserId(userId);
        event.setCouponCode(couponCode);
        event.setOrderAmount(orderValue);
        event.setTimestamp(LocalDateTime.now());
        
        try {
            Coupon coupon = couponRepository.findActiveByCode(couponCode, LocalDateTime.now())
                .orElseThrow(() -> new InvalidCouponException("Invalid or expired coupon code"));
            
            // Validate all rules
            validateCouponRules(coupon, userId, orderValue, restaurantId);
            
            // Calculate discount
            BigDecimal discount = calculateDiscount(coupon, orderValue);
            
            // Publish successful validation event
            event.setStatus("SUCCESS");
            event.setDiscountAmount(discount);
            eventProducer.publishCouponValidated(event);
            
            return new CouponValidationResponse(
                true, 
                discount, 
                "Coupon applied successfully! You saved ₹" + discount,
                couponCode
            );
            
        } catch (InvalidCouponException e) {
            log.warn("Coupon validation failed: {}", e.getMessage());
            
            // Publish failed validation event
            event.setStatus("FAILED");
            event.setFailureReason(e.getMessage());
            event.setDiscountAmount(BigDecimal.ZERO);
            eventProducer.publishCouponValidated(event);
            
            return new CouponValidationResponse(false, BigDecimal.ZERO, e.getMessage(), couponCode);
        }
    }
    
    /**
     * Validate all coupon rules
     */
    private void validateCouponRules(Coupon coupon, Long userId, 
                                     BigDecimal orderValue, Long restaurantId) {
        
        // 1. Check if coupon is active
        if (!coupon.getIsActive()) {
            throw new InvalidCouponException("This coupon is no longer active");
        }
        
        // 2. Check date validity
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(coupon.getStartDate())) {
            throw new InvalidCouponException("This coupon is not yet valid");
        }
        if (now.isAfter(coupon.getEndDate())) {
            throw new InvalidCouponException("This coupon has expired");
        }
        
        // 3. Check minimum order value
        if (orderValue.compareTo(coupon.getMinOrderValue()) < 0) {
            throw new InvalidCouponException(
                "Minimum order value of ₹" + coupon.getMinOrderValue() + " required"
            );
        }
        
        // 4. Check total usage limit
        if (coupon.getTotalUsageLimit() != null) {
            long totalUsage = usageRepository.countByCouponId(coupon.getId());
            if (totalUsage >= coupon.getTotalUsageLimit()) {
                throw new InvalidCouponException("Coupon usage limit reached");
            }
        }
        
        // 5. Check per-user limit
        long userUsage = usageRepository.countByCouponIdAndUserId(coupon.getId(), userId);
        if (userUsage >= coupon.getPerUserLimit()) {
            throw new InvalidCouponException("You have already used this coupon");
        }
        
        // 6. Check first order condition
        if (Coupon.ApplicableOn.FIRST_ORDER.equals(coupon.getApplicableOn())) {
            // You can add order count check here if needed
            // For now, we'll allow it
        }
    }
    
    /**
     * Calculate discount based on coupon type
     */
    public BigDecimal calculateDiscount(Coupon coupon, BigDecimal orderValue) {
        BigDecimal discount = BigDecimal.ZERO;
        
        switch (coupon.getDiscountType()) {
            case PERCENTAGE:
                discount = orderValue.multiply(coupon.getDiscountValue())
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
                
                // Apply max discount cap
                if (coupon.getMaxDiscount() != null && 
                    discount.compareTo(coupon.getMaxDiscount()) > 0) {
                    discount = coupon.getMaxDiscount();
                }
                break;
                
            case FLAT:
                discount = coupon.getDiscountValue();
                // Discount cannot exceed order value
                if (discount.compareTo(orderValue) > 0) {
                    discount = orderValue;
                }
                break;
                
            case CASHBACK:
                // Cashback is credited after order completion
                discount = BigDecimal.ZERO;
                break;
        }
        
        return discount.setScale(2, RoundingMode.HALF_UP);
    }
    
    /**
     * Apply coupon to order (called during order placement)
     */
    @Transactional
    public BigDecimal applyCoupon(Long orderId, String couponCode, Long userId, BigDecimal orderValue) {
        try {
            Coupon coupon = couponRepository.findActiveByCode(couponCode, LocalDateTime.now())
                .orElseThrow(() -> new InvalidCouponException("Invalid coupon"));
            
            // Re-validate before applying
            validateCouponRules(coupon, userId, orderValue, null);
            
            // Calculate discount
            BigDecimal discount = calculateDiscount(coupon, orderValue);
            
            // Record usage
            CouponUsage usage = new CouponUsage();
            usage.setCouponId(coupon.getId());
            usage.setUserId(userId);
            usage.setOrderId(orderId);
            usage.setDiscountApplied(discount);
            usageRepository.save(usage);
            
            // Publish coupon applied event
            CouponEvent event = new CouponEvent();
            event.setUserId(userId);
            event.setCouponCode(couponCode);
            event.setOrderAmount(orderValue);
            event.setDiscountAmount(discount);
            event.setStatus("SUCCESS");
            event.setTimestamp(LocalDateTime.now());
            eventProducer.publishCouponApplied(event);
            
            log.info("Coupon {} applied successfully for user {} on order {}", 
                     couponCode, userId, orderId);
            
            return discount;
            
        } catch (Exception e) {
            log.error("Failed to apply coupon: {}", e.getMessage());
            throw e;
        }
    }
    
    /**
     * Get all available coupons for user
     */
    public List<CouponDTO> getAvailableCoupons(Long userId, BigDecimal orderValue, Long restaurantId) {
        List<Coupon> allCoupons = couponRepository.findActiveCoupons(LocalDateTime.now());
        
        // Publish coupon viewed events for each coupon
        allCoupons.forEach(coupon -> {
            CouponEvent event = new CouponEvent();
            event.setUserId(userId);
            event.setCouponCode(coupon.getCode());
            event.setOrderAmount(orderValue);
            event.setTimestamp(LocalDateTime.now());
            eventProducer.publishCouponViewed(event);
        });
        
        return allCoupons.stream()
            .map(coupon -> convertToDTO(coupon, userId, orderValue, restaurantId))
            .collect(Collectors.toList());
    }
    
    /**
     * Convert Coupon entity to DTO with applicability check
     */
    private CouponDTO convertToDTO(Coupon coupon, Long userId, BigDecimal orderValue, Long restaurantId) {
        CouponDTO dto = new CouponDTO();
        dto.setId(coupon.getId());
        dto.setCode(coupon.getCode());
        dto.setDescription(coupon.getDescription());
        dto.setDiscountType(coupon.getDiscountType().name());
        dto.setDiscountValue(coupon.getDiscountValue());
        dto.setMaxDiscount(coupon.getMaxDiscount());
        dto.setMinOrderValue(coupon.getMinOrderValue());
        dto.setStartDate(coupon.getStartDate());
        dto.setEndDate(coupon.getEndDate());
        dto.setPerUserLimit(coupon.getPerUserLimit());
        dto.setApplicableOn(coupon.getApplicableOn().name());
        
        // Check if applicable
        try {
            validateCouponRules(coupon, userId, orderValue, restaurantId);
            BigDecimal discount = calculateDiscount(coupon, orderValue);
            dto.setIsApplicable(true);
            dto.setCalculatedDiscount(discount);
            dto.setNotApplicableReason(null);
        } catch (InvalidCouponException e) {
            dto.setIsApplicable(false);
            dto.setCalculatedDiscount(BigDecimal.ZERO);
            dto.setNotApplicableReason(e.getMessage());
        }
        
        return dto;
    }
    
    /**
     * Get all coupons (for display on coupons page)
     */
    public List<CouponDTO> getAllActiveCoupons() {
        List<Coupon> coupons = couponRepository.findActiveCoupons(LocalDateTime.now());
        return coupons.stream()
            .map(this::convertToDTOSimple)
            .collect(Collectors.toList());
    }
    
    private CouponDTO convertToDTOSimple(Coupon coupon) {
        CouponDTO dto = new CouponDTO();
        dto.setId(coupon.getId());
        dto.setCode(coupon.getCode());
        dto.setDescription(coupon.getDescription());
        dto.setDiscountType(coupon.getDiscountType().name());
        dto.setDiscountValue(coupon.getDiscountValue());
        dto.setMaxDiscount(coupon.getMaxDiscount());
        dto.setMinOrderValue(coupon.getMinOrderValue());
        dto.setStartDate(coupon.getStartDate());
        dto.setEndDate(coupon.getEndDate());
        dto.setApplicableOn(coupon.getApplicableOn().name());
        return dto;
    }
}
