package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.CanteenOrder;
import com.omoikaneinnovations.omoiservespare.entity.Order;
import com.omoikaneinnovations.omoiservespare.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

/**
 * WebSocket publisher for real-time order updates
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OrderEventPublisher {
    
    private final SimpMessagingTemplate messagingTemplate;
    
    /**
     * Send order update to specific customer
     */
    public void toCustomer(User customer, Object payload) {
        try {
            String destination = "/topic/customer/" + customer.getId();
            messagingTemplate.convertAndSend(destination, payload);
            log.debug("Sent order update to customer: {}", customer.getId());
        } catch (Exception e) {
            log.error("Failed to send order update to customer: {}", e.getMessage());
        }
    }
    
    /**
     * Send order update to specific order channel
     */
    public void toOrder(String orderCode, Object payload) {
        try {
            String destination = "/topic/order/" + orderCode;
            messagingTemplate.convertAndSend(destination, payload);
            log.debug("Sent order update to order: {}", orderCode);
        } catch (Exception e) {
            log.error("Failed to send order update to order: {}", e.getMessage());
        }
    }
    
    /**
     * Send order update to specific canteen
     */
    public void toCanteen(String canteenId, Object payload) {
        try {
            String destination = "/topic/canteen/" + canteenId;
            messagingTemplate.convertAndSend(destination, payload);
            log.debug("Sent order update to canteen: {}", canteenId);
        } catch (Exception e) {
            log.error("Failed to send order update to canteen: {}", e.getMessage());
        }
    }
}
