package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentVerifyRequestDTO {
    private String orderCode;
    private String transactionId;
    private String razorpayPaymentId;
    private String razorpayOrderId;
    private String signature;
    private String cavv; // 3D Secure
    private String eci;  // 3D Secure
}