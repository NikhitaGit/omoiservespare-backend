package com.omoikaneinnovations.omoiservespare.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CouponEvent implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private String eventId;
    private String eventType; // VIEWED, VALIDATED, APPLIED, FAILED
    private Long userId;
    private String couponCode;
    private BigDecimal orderAmount;
    private BigDecimal discountAmount;
    private String status; // SUCCESS, FAILED
    private String failureReason;
    private LocalDateTime timestamp;
    private String sessionId;
    private String deviceType;
    private String ipAddress;
    
    // Additional tracking fields
    private String restaurantId;
    private String categoryId;
    private Integer itemCount;
}
