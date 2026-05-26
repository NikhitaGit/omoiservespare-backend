package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Simple item sales data for top/least sold tables
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ItemSalesDTO {
    
    private Long itemId;
    private String name;
    private Integer qty;
    private String category;
}
