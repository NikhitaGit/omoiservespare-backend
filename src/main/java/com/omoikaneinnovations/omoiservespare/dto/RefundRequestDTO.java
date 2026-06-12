package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * Request DTO for initiating a refund
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RefundRequestDTO {
    private Long canteenOrderId;
    private String reason;
    private String requestedBy; // CUSTOMER, VENDOR, SYSTEM
}