package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Time-series data for revenue chart
 * Pre-formatted labels for UI
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RevenueSeriesDTO {
    
    private String label;        // "17 Apr" or "09:00" or "Jan"
    private BigDecimal sales;
    private Integer orders;
}
