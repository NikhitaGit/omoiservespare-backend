package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Session and traffic metrics
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SessionMetricsDTO {
    
    private Integer totalSessions;
    private Integer liveVisitors;
    private Integer pageViews;
}
