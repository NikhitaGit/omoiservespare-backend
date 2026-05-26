package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.Order;
import com.omoikaneinnovations.omoiservespare.event.OrderCompletedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class RewardOrderEventPublisher {
    
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    /**
     * Publish order completed event to Kafka
     * Call this from OrderService after order is successfully completed
     */
    public void publishOrderCompleted(Order order) {
        try {
            OrderCompletedEvent event = new OrderCompletedEvent();
            event.setEventId(UUID.randomUUID().toString());
            event.setOrderId(order.getId());
            event.setUserId(order.getCustomer() != null ? order.getCustomer().getId() : null);
            event.setOrderAmount(order.getTotalAmount());
            
            // Calculate wallet amount used based on payment method
            BigDecimal walletAmount = BigDecimal.ZERO;
            if ("WALLET".equalsIgnoreCase(order.getPaymentMethod())) {
                walletAmount = order.getTotalAmount();
            }
            event.setWalletAmountUsed(walletAmount);
            
            event.setPaymentMethod(order.getPaymentMethod());
            event.setCompletedAt(LocalDateTime.now());
            event.setSessionId(UUID.randomUUID().toString());
            
            kafkaTemplate.send("order-completed-events", event);
            
            log.info("Published ORDER_COMPLETED event: orderId={}, userId={}", 
                order.getId(), event.getUserId());
                
        } catch (Exception e) {
            log.error("Failed to publish order completed event: {}", e.getMessage(), e);
            // Don't fail the order if event publishing fails
        }
    }
}
