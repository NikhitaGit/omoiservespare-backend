package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class CanteenOrderDTO {

    private Long id;
    private Long canteenId;
    private String status;
    private BigDecimal subtotal;
    private LocalDateTime createdAt;
    
    // ✅ Refund information
    private boolean refunded;
    private String refundStatus;
    private LocalDateTime refundRequestedAt;
    private LocalDateTime refundCompletedAt;
    private String cancelReason;

    private List<OrderItemDTO> items;
}