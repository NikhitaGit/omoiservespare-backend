package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Complete dashboard response
 * All data pre-processed and UI-ready
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminDashboardDTO {
    
    // KPI Cards
    private DashboardKpiDTO kpis;
    
    // Charts
    private List<RevenueSeriesDTO> revenueSeries;
    
    // Trending Items (with images and growth)
    private List<TrendingItemDTO> trendingItems;
    
    // Today's performance
    private List<ItemSalesDTO> topSoldToday;
    private List<ItemSalesDTO> leastSoldToday;
    
    // Category breakdown
    private List<CategoryDistributionDTO> categoryDistribution;
    
    // Traffic
    private SessionMetricsDTO sessions;
    
    // Retention
    private CustomerRetentionDTO customerRate;
    
    // Insights (processed in backend)
    private List<String> insights;  // e.g., ["Idli sales ↑ 20%", "Peak orders at 1 PM"]
}
