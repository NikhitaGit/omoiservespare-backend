package com.omoikaneinnovations.omoiservespare.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserBehaviorEvent implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private String eventId;
    private Long userId;
    private String action; // BROWSE_COUPONS, VIEW_COUPON, APPLY_COUPON, CHECKOUT, etc.
    private LocalDateTime timestamp;
    private String sessionId;
    private Map<String, Object> metadata;
}
