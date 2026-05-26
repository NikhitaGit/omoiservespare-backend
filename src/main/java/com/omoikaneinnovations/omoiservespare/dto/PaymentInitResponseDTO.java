package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentInitResponseDTO {
    private String transactionId;
    private String status;
    private String riskLevel;
    private boolean requires3DS;
    private String authenticationUrl;
    private String message;
    private String razorpayOrderId; // For Razorpay integration
    private String orderCode; // Order code for verification
}