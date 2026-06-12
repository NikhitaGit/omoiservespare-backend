package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Response DTO for refund details
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RefundResponseDTO {
    // Identifiers
    private Long id;
    private String refundId; // Razorpay refund ID
    private String internalRefundCode; // Our tracking code
    
    // Amounts
    private BigDecimal refundAmount;
    private BigDecimal originalAmount;
    private BigDecimal cgstAmount;
    private BigDecimal sgstAmount;
    
    // Status
    private String status;
    private String razorpayStatus;
    private String settlementStatus;
    
    // Cancellation details
    private String cancellationReason;
    private String cancellationRequestedBy;
    
    // Vendor approval
    private String vendorApprovalStatus;
    private LocalDateTime vendorApprovalAt;
    private String vendorRemarks;
    
    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime refundInitiatedAt;
    private LocalDateTime refundProcessedAt;
    private LocalDateTime settlementDate;
    
    // Order details
    private String orderCode;
    private LocalDateTime orderDate;
    
    // Canteen order details
    private Long canteenOrderId;
    private Long canteenId;
    private String canteenName;
    
    // Payment details
    private String paymentMethod;
    private String refundMethod;
    private String refundMode;
    
    // Error details (if failed)
    private String errorCode;
    private String errorMessage;
    
    // Retry info
    private Integer retryCount;
    private Integer maxRetries;
    private Boolean canRetry;
}