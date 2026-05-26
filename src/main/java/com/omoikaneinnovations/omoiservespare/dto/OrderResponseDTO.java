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
public class OrderResponseDTO {

    private String orderCode;
    private BigDecimal totalAmount;
    private String status;
    private LocalDateTime createdAt;

    private List<CanteenOrderDTO> canteenOrders;
    private String paymentStatus;
    private String paymentMethod;
}
