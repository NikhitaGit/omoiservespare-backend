package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Customer retention metrics
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerRetentionDTO {
    
    private Double returningPercent;
    private Double firstTimePercent;
    private Integer totalCustomers;
    private Integer returningCustomers;
    private Integer newCustomers;
}
