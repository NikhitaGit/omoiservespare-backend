package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * DTO for vendor approval/rejection of cancellation
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VendorApprovalDTO {
    private Long canteenOrderId;
    private String action; // APPROVE or REJECT
    private String remarks;
    private Long vendorId;
}