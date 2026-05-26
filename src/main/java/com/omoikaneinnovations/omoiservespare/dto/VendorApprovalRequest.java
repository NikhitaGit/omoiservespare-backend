package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;

/**
 * Vendor Approval/Rejection Request
 * Used by admin to approve or reject vendor applications
 */
@Data
public class VendorApprovalRequest {
    private String action; // "APPROVE" or "REJECT"
    private String reason; // Optional reason for rejection
}
