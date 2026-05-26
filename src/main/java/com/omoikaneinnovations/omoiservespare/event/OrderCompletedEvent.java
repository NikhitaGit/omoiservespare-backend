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
public class OrderCompletedEvent implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private String eventId;
    private Long orderId;
    private Long userId;
    private BigDecimal orderAmount;
    private BigDecimal walletAmountUsed;
    private String paymentMethod;
    private LocalDateTime completedAt;
    private String sessionId;
}
