package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.event.CouponEvent;
import com.omoikaneinnovations.omoiservespare.service.CouponEventProducer;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/kafka")
@RequiredArgsConstructor
@Slf4j
public class KafkaTestController {
    
    private final CouponEventProducer couponEventProducer;
    
    @GetMapping("/test")
    public ResponseEntity<Map<String, Object>> testKafkaConnection() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            log.info("Testing Kafka connection...");
            
            // Create a test event
            CouponEvent testEvent = new CouponEvent();
            testEvent.setUserId(999L);
            testEvent.setCouponCode("TEST-KAFKA");
            testEvent.setOrderAmount(new BigDecimal("100.00"));
            testEvent.setDiscountAmount(new BigDecimal("10.00"));
            testEvent.setStatus("SUCCESS");
            testEvent.setTimestamp(LocalDateTime.now());
            testEvent.setSessionId("test-session");
            testEvent.setDeviceType("test");
            testEvent.setIpAddress("127.0.0.1");
            
            // Send test event
            couponEventProducer.publishCouponViewed(testEvent);
            
            log.info("Test event sent successfully!");
            
            response.put("status", "success");
            response.put("message", "Kafka is connected and working!");
            response.put("testEvent", testEvent);
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Kafka connection test failed: {}", e.getMessage(), e);
            
            response.put("status", "error");
            response.put("message", "Kafka connection failed: " + e.getMessage());
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getKafkaStatus() {
        Map<String, Object> response = new HashMap<>();
        
        response.put("kafkaConfigured", true);
        response.put("bootstrapServers", "localhost:9092");
        response.put("topics", new String[]{
            "coupon-viewed-events",
            "coupon-applied-events",
            "coupon-validated-events",
            "user-behavior-events"
        });
        response.put("consumerGroup", "coupon-tracking-group");
        response.put("timestamp", LocalDateTime.now());
        
        return ResponseEntity.ok(response);
    }
}
