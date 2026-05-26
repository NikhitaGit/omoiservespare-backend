package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Trending item with growth metrics
 * Includes insights like "↑ 20% today"
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TrendingItemDTO {
    
    private Long itemId;
    private String name;
    private String imageUrl;
    private Integer quantitySold;
    private BigDecimal revenue;
    private Double growthPercent;  // % change from previous period
    private String category;
    
    // UI helpers
    private String insight;  // e.g., "Idli sales ↑ 20% today"
}
