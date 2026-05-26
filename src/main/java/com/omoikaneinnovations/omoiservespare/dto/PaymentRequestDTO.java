package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRequestDTO {
    private String orderCode;
    private String gateway; // "razorpay", "phonepe", etc.
    private String paymentMethod; // "card", "upi", "wallet"
    private BigDecimal amount;
    private String currency;
    private String deviceId;
    private String customerEmail;
    private String customerPhone;

    // New fields for cart-based payment initiation
    private String note; // Restaurant note
    private boolean createOrderFromCart = false; // Flag to indicate if order should be created from cart
}
