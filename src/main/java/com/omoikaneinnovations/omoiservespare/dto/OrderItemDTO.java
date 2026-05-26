package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
public class OrderItemDTO {

    private Long menuItemId;
    private String name;
    private BigDecimal price;
    private Integer quantity;
}