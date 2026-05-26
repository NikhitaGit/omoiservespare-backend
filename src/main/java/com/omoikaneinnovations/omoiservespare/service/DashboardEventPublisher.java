package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.Order;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * Real-time dashboard updates via WebSocket
 * 
 * Flow:
 * 1. Order completed → OrderService
 * 2. Publish event → DashboardEventPublisher
 * 3. WebSocket broadcast → /topic/admin/dashboard
 * 4. Frontend receives → Updates UI
 * 
 * Like Swiggy/Zomato real-time dashboard
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardEventPublisher {
    
    private final SimpMessagingTemplate messagingTemplate;
    
    /**
     * Publish order completed event to admin dashboard
     * All connected admin dashboards will receive this update
     */
    public void publishOrderCompleted(Order order) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("type", "ORDER_COMPLETED");
            event.put("orderId", order.getId());
            event.put("orderCode", order.getOrderCode());
            event.put("amount", order.getTotalAmount());
            event.put("timestamp", order.getCreatedAt());
            event.put("customerId", order.getCustomer() != null ? order.getCustomer().getId() : null);
            
            // Broadcast to all admin dashboards
            messagingTemplate.convertAndSend("/topic/admin/dashboard", (Object) event);
            
            log.info("Published dashboard update: ORDER_COMPLETED for order {}", order.getOrderCode());
            
        } catch (Exception e) {
            log.error("Failed to publish dashboard update: {}", e.getMessage(), e);
            // Don't fail the order if WebSocket fails
        }
    }
    
    /**
     * Publish order cancelled event
     */
    public void publishOrderCancelled(Order order) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("type", "ORDER_CANCELLED");
            event.put("orderId", order.getId());
            event.put("orderCode", order.getOrderCode());
            event.put("amount", order.getTotalAmount());
            event.put("timestamp", order.getUpdatedAt());
            
            messagingTemplate.convertAndSend("/topic/admin/dashboard", (Object) event);
            
            log.info("Published dashboard update: ORDER_CANCELLED for order {}", order.getOrderCode());
            
        } catch (Exception e) {
            log.error("Failed to publish dashboard update: {}", e.getMessage(), e);
        }
    }
    
    /**
     * Publish generic metric update
     * Can be used for any real-time metric changes
     */
    public void publishMetricUpdate(String metricName, Object value) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("type", "METRIC_UPDATE");
            event.put("metric", metricName);
            event.put("value", value);
            event.put("timestamp", System.currentTimeMillis());
            
            messagingTemplate.convertAndSend("/topic/admin/dashboard", (Object) event);
            
            log.debug("Published metric update: {} = {}", metricName, value);
            
        } catch (Exception e) {
            log.error("Failed to publish metric update: {}", e.getMessage(), e);
        }
    }
}
