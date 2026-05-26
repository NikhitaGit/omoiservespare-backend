package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class CartItemResponseDTO {

    private Long menuItemId;
    private String name;
    private Double price;
    private Integer quantity;
    private String imageUrl;

    private Long canteenId;
    private String canteenName;
}
