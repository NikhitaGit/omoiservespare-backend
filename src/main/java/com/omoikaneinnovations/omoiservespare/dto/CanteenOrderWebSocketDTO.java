package com.omoikaneinnovations.omoiservespare.dto;

import com.omoikaneinnovations.omoiservespare.entity.OrderStatus;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class CanteenOrderWebSocketDTO {
    private Long id;
    private Long canteenId;
    private OrderStatus status;
    private BigDecimal subtotal;
    private LocalDateTime createdAt;
    private String cancelReason;
    private boolean refunded;
    
    // Parent order info (minimal to avoid circular references)
    private String orderCode;
    private String customerEmail;
    private BigDecimal totalAmount;
    
    // Items
    private List<OrderItemDTO> items;
    
    @Data
    public static class OrderItemDTO {
        private Long id;
        private Long menuItemId;
        private String name;
        private BigDecimal price;
        private Integer quantity;
    }
}