package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.event.CouponEvent;
import com.omoikaneinnovations.omoiservespare.event.UserBehaviorEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class CouponAnalyticsService {
    
    @Autowired(required = false)
    private RedisTemplate<String, Object> redisTemplate;
    
    private static final String ANALYTICS_PREFIX = "analytics:";
    private static final String COUPON_VIEWS = ANALYTICS_PREFIX + "coupon:views:";
    private static final String COUPON_VALIDATIONS = ANALYTICS_PREFIX + "coupon:validations:";
    private static final String COUPON_APPLICATIONS = ANALYTICS_PREFIX + "coupon:applications:";
    private static final String USER_PROFILE = ANALYTICS_PREFIX + "user:profile:";
    private static final String DAILY_STATS = ANALYTICS_PREFIX + "daily:";
    
    /**
     * Track coupon view
     */
    public void trackCouponView(CouponEvent event) {
        if (redisTemplate == null) {
            log.debug("Redis not available, skipping analytics tracking");
            return;
        }
        
        try {
            String key = COUPON_VIEWS + event.getCouponCode() + ":" + LocalDate.now();
            redisTemplate.opsForValue().increment(key);
            redisTemplate.expire(key, 30, TimeUnit.DAYS);
            
            log.info("Tracked coupon view: {} by user: {}", event.getCouponCode(), event.getUserId());
        } catch (Exception e) {
            log.warn("Failed to track coupon view: {}", e.getMessage());
        }
    }
    
    /**
     * Track coupon validation attempt
     */
    public void trackCouponValidation(CouponEvent event) {
        if (redisTemplate == null) {
            log.debug("Redis not available, skipping analytics tracking");
            return;
        }
        
        try {
            String successKey = COUPON_VALIDATIONS + event.getCouponCode() + ":success:" + LocalDate.now();
            String failureKey = COUPON_VALIDATIONS + event.getCouponCode() + ":failure:" + LocalDate.now();
            
            if ("SUCCESS".equals(event.getStatus())) {
                redisTemplate.opsForValue().increment(successKey);
                redisTemplate.expire(successKey, 30, TimeUnit.DAYS);
            } else {
                redisTemplate.opsForValue().increment(failureKey);
                redisTemplate.expire(failureKey, 30, TimeUnit.DAYS);
                
                // Track failure reasons
                if (event.getFailureReason() != null) {
                    String reasonKey = COUPON_VALIDATIONS + event.getCouponCode() + ":reason:" + 
                        event.getFailureReason() + ":" + LocalDate.now();
                    redisTemplate.opsForValue().increment(reasonKey);
                    redisTemplate.expire(reasonKey, 30, TimeUnit.DAYS);
                }
            }
            
            log.info("Tracked coupon validation: {} | Status: {} | Reason: {}", 
                event.getCouponCode(), event.getStatus(), event.getFailureReason());
        } catch (Exception e) {
            log.warn("Failed to track coupon validation: {}", e.getMessage());
        }
    }
    
    /**
     * Track successful coupon application
     */
    public void trackCouponApplication(CouponEvent event) {
        if (redisTemplate == null) {
            log.debug("Redis not available, skipping analytics tracking");
            return;
        }
        
        try {
            String key = COUPON_APPLICATIONS + event.getCouponCode() + ":" + LocalDate.now();
            redisTemplate.opsForValue().increment(key);
            redisTemplate.expire(key, 30, TimeUnit.DAYS);
            
            // Track total discount given
            String discountKey = COUPON_APPLICATIONS + event.getCouponCode() + ":discount:" + LocalDate.now();
            redisTemplate.opsForValue().increment(discountKey, event.getDiscountAmount().doubleValue());
            redisTemplate.expire(discountKey, 30, TimeUnit.DAYS);
            
            // Track daily stats
            String dailyKey = DAILY_STATS + LocalDate.now() + ":coupons:applied";
            redisTemplate.opsForValue().increment(dailyKey);
            redisTemplate.expire(dailyKey, 90, TimeUnit.DAYS);
            
            log.info("Tracked coupon application: {} | Discount: {} | User: {}", 
                event.getCouponCode(), event.getDiscountAmount(), event.getUserId());
        } catch (Exception e) {
            log.warn("Failed to track coupon application: {}", e.getMessage());
        }
    }
    
    /**
     * Update user profile for personalization
     */
    public void updateUserProfile(CouponEvent event) {
        if (redisTemplate == null) {
            log.debug("Redis not available, skipping user profile update");
            return;
        }
        
        try {
            String profileKey = USER_PROFILE + event.getUserId();
            
            // Increment coupon usage count
            redisTemplate.opsForHash().increment(profileKey, "total_coupons_used", 1);
            
            // Track total savings
            redisTemplate.opsForHash().increment(profileKey, "total_savings", 
                event.getDiscountAmount().doubleValue());
            
            // Track last coupon used
            redisTemplate.opsForHash().put(profileKey, "last_coupon_code", event.getCouponCode());
            redisTemplate.opsForHash().put(profileKey, "last_coupon_date", event.getTimestamp().toString());
            
            // Track preferred discount type
            redisTemplate.opsForHash().increment(profileKey, "discount_type:" + event.getEventType(), 1);
            
            redisTemplate.expire(profileKey, 365, TimeUnit.DAYS);
            
            log.info("Updated user profile for userId: {}", event.getUserId());
        } catch (Exception e) {
            log.warn("Failed to update user profile: {}", e.getMessage());
        }
    }
    
    /**
     * Track user behavior
     */
    public void trackUserBehavior(UserBehaviorEvent event) {
        if (redisTemplate == null) {
            log.debug("Redis not available, skipping behavior tracking");
            return;
        }
        
        try {
            String behaviorKey = USER_PROFILE + event.getUserId() + ":behavior:" + event.getAction();
            redisTemplate.opsForValue().increment(behaviorKey);
            redisTemplate.expire(behaviorKey, 90, TimeUnit.DAYS);
            
            log.info("Tracked user behavior: userId={}, action={}", event.getUserId(), event.getAction());
        } catch (Exception e) {
            log.warn("Failed to track user behavior: {}", e.getMessage());
        }
    }
    
    /**
     * Get coupon performance metrics
     */
    public CouponMetrics getCouponMetrics(String couponCode, LocalDate date) {
        if (redisTemplate == null) {
            log.debug("Redis not available, returning empty metrics");
            return new CouponMetrics(couponCode, date, 0L, 0L, 0L, 0L, 0.0);
        }
        
        try {
            String viewsKey = COUPON_VIEWS + couponCode + ":" + date;
            String successKey = COUPON_VALIDATIONS + couponCode + ":success:" + date;
            String failureKey = COUPON_VALIDATIONS + couponCode + ":failure:" + date;
            String applicationsKey = COUPON_APPLICATIONS + couponCode + ":" + date;
            String discountKey = COUPON_APPLICATIONS + couponCode + ":discount:" + date;
            
            Long views = (Long) redisTemplate.opsForValue().get(viewsKey);
            Long successValidations = (Long) redisTemplate.opsForValue().get(successKey);
            Long failureValidations = (Long) redisTemplate.opsForValue().get(failureKey);
            Long applications = (Long) redisTemplate.opsForValue().get(applicationsKey);
            Double totalDiscount = (Double) redisTemplate.opsForValue().get(discountKey);
            
            return new CouponMetrics(
                couponCode,
                date,
                views != null ? views : 0L,
                successValidations != null ? successValidations : 0L,
                failureValidations != null ? failureValidations : 0L,
                applications != null ? applications : 0L,
                totalDiscount != null ? totalDiscount : 0.0
            );
        } catch (Exception e) {
            log.warn("Failed to get coupon metrics: {}", e.getMessage());
            return new CouponMetrics(couponCode, date, 0L, 0L, 0L, 0L, 0.0);
        }
    }
    
    /**
     * Inner class for coupon metrics
     */
    public record CouponMetrics(
        String couponCode,
        LocalDate date,
        Long views,
        Long successfulValidations,
        Long failedValidations,
        Long applications,
        Double totalDiscount
    ) {}
}
