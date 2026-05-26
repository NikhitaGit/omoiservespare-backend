package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * KPI metrics for dashboard cards
 * UI-ready format - no raw data
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardKpiDTO {
    
    private BigDecimal todayRevenue;
    private BigDecimal totalRevenue;
    private Integer totalOrders;
    private Integer customers;
    private BigDecimal avgOrderValue;
    
    // Trend indicators (for UI)
    private Double todayRevenueGrowth;  // % change from yesterday
    private Double ordersGrowth;         // % change
    private Double customersGrowth;      // % change
}
