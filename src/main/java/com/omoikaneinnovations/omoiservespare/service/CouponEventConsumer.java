package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.event.CouponEvent;
import com.omoikaneinnovations.omoiservespare.event.UserBehaviorEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class CouponEventConsumer {
    
    private final CouponAnalyticsService analyticsService;
    
    /**
     * Listen to coupon viewed events
     */
    @KafkaListener(
        topics = "${kafka.topic.coupon-viewed}",
        groupId = "${spring.kafka.consumer.group-id}",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeCouponViewed(CouponEvent event) {
        log.info("Consumed COUPON_VIEWED event: userId={}, couponCode={}", 
            event.getUserId(), event.getCouponCode());
        
        try {
            // Track coupon view in analytics
            analyticsService.trackCouponView(event);
        } catch (Exception e) {
            log.error("Error processing COUPON_VIEWED event: {}", e.getMessage(), e);
        }
    }
    
    /**
     * Listen to coupon validated events
     */
    @KafkaListener(
        topics = "${kafka.topic.coupon-validated}",
        groupId = "${spring.kafka.consumer.group-id}",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeCouponValidated(CouponEvent event) {
        log.info("Consumed COUPON_VALIDATED event: userId={}, couponCode={}, status={}", 
            event.getUserId(), event.getCouponCode(), event.getStatus());
        
        try {
            // Track validation attempt
            analyticsService.trackCouponValidation(event);
        } catch (Exception e) {
            log.error("Error processing COUPON_VALIDATED event: {}", e.getMessage(), e);
        }
    }
    
    /**
     * Listen to coupon applied events
     */
    @KafkaListener(
        topics = "${kafka.topic.coupon-applied}",
        groupId = "${spring.kafka.consumer.group-id}",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeCouponApplied(CouponEvent event) {
        log.info("Consumed COUPON_APPLIED event: userId={}, couponCode={}, discount={}", 
            event.getUserId(), event.getCouponCode(), event.getDiscountAmount());
        
        try {
            // Track successful coupon application
            analyticsService.trackCouponApplication(event);
            
            // Update user profile for personalization
            analyticsService.updateUserProfile(event);
        } catch (Exception e) {
            log.error("Error processing COUPON_APPLIED event: {}", e.getMessage(), e);
        }
    }
    
    /**
     * Listen to user behavior events
     */
    @KafkaListener(
        topics = "${kafka.topic.user-behavior}",
        groupId = "${spring.kafka.consumer.group-id}",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeUserBehavior(UserBehaviorEvent event) {
        log.info("Consumed USER_BEHAVIOR event: userId={}, action={}", 
            event.getUserId(), event.getAction());
        
        try {
            // Track user behavior for personalization
            analyticsService.trackUserBehavior(event);
        } catch (Exception e) {
            log.error("Error processing USER_BEHAVIOR event: {}", e.getMessage(), e);
        }
    }
}
