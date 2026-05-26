package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.event.CouponEvent;
import com.omoikaneinnovations.omoiservespare.event.UserBehaviorEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@Service
@RequiredArgsConstructor
@Slf4j
public class CouponEventProducer {
    
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    @Value("${kafka.topic.coupon-viewed}")
    private String couponViewedTopic;
    
    @Value("${kafka.topic.coupon-applied}")
    private String couponAppliedTopic;
    
    @Value("${kafka.topic.coupon-validated}")
    private String couponValidatedTopic;
    
    @Value("${kafka.topic.user-behavior}")
    private String userBehaviorTopic;
    
    /**
     * Publish coupon viewed event
     */
    public void publishCouponViewed(CouponEvent event) {
        event.setEventId(UUID.randomUUID().toString());
        event.setEventType("VIEWED");
        publishEvent(couponViewedTopic, event);
    }
    
    /**
     * Publish coupon validated event
     */
    public void publishCouponValidated(CouponEvent event) {
        event.setEventId(UUID.randomUUID().toString());
        event.setEventType("VALIDATED");
        publishEvent(couponValidatedTopic, event);
    }
    
    /**
     * Publish coupon applied event
     */
    public void publishCouponApplied(CouponEvent event) {
        event.setEventId(UUID.randomUUID().toString());
        event.setEventType("APPLIED");
        publishEvent(couponAppliedTopic, event);
    }
    
    /**
     * Publish user behavior event
     */
    public void publishUserBehavior(UserBehaviorEvent event) {
        event.setEventId(UUID.randomUUID().toString());
        publishEvent(userBehaviorTopic, event);
    }
    
    /**
     * Generic method to publish events to Kafka
     */
    private void publishEvent(String topic, Object event) {
        try {
            CompletableFuture<SendResult<String, Object>> future = 
                kafkaTemplate.send(topic, event);
            
            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    log.info("Event published successfully to topic: {} | Partition: {} | Offset: {}", 
                        topic, 
                        result.getRecordMetadata().partition(),
                        result.getRecordMetadata().offset());
                } else {
                    log.error("Failed to publish event to topic: {} | Error: {}", 
                        topic, ex.getMessage());
                }
            });
        } catch (Exception e) {
            log.error("Exception while publishing event to topic: {} | Error: {}", 
                topic, e.getMessage(), e);
        }
    }
}
