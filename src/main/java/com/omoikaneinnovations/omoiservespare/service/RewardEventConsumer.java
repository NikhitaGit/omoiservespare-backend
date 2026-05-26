package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.event.OrderCompletedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class RewardEventConsumer {
    
    private final RewardService rewardService;
    
    /**
     * Listen to order completed events and process rewards in real-time
     */
    @KafkaListener(
        topics = "order-completed-events",
        groupId = "${spring.kafka.consumer.group-id}",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeOrderCompleted(OrderCompletedEvent event) {
        log.info("Received ORDER_COMPLETED event: orderId={}, userId={}, amount={}", 
            event.getOrderId(), event.getUserId(), event.getOrderAmount());
        
        try {
            // Process rewards in real-time
            rewardService.processOrderCompletion(event);
            
            log.info("Rewards processed successfully for order: {}", event.getOrderId());
        } catch (Exception e) {
            log.error("Error processing rewards for order {}: {}", event.getOrderId(), e.getMessage(), e);
            // In production, you might want to send to a dead letter queue
        }
    }
}
