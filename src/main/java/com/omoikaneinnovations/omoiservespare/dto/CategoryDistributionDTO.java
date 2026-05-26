package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Category distribution for donut chart
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDistributionDTO {
    
    private String category;
    private Integer count;
    private Double percentage;
}
