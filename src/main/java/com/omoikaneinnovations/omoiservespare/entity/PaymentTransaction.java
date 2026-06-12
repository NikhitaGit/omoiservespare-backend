package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payment_transactions")
@Getter
@Setter
public class PaymentTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "transaction_id", unique = true)
    private String transactionId; // Razorpay Order ID (order_XXXXX)

    @Column(name = "payment_id", unique = true)
    private String paymentId; // Razorpay Payment ID (pay_XXXXX) - set after payment completion

    @Column(name = "gateway_name", nullable = false)
    private String gatewayName; // "razorpay", "phonepe", etc.

    @Column(name = "payment_method")
    private String paymentMethod; // "card", "upi", "wallet"

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(nullable = false)
    private String currency;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus status;

    // ============================================
    // 3D SECURE FIELDS
    // ============================================
    @Column(name = "three_d_secure_status")
    private String threeDSecureStatus; // "authenticated", "attempted", "not_enrolled", "failed"

    @Column(name = "three_d_secure_eci")
    private String threeDSecureEci; // Electronic Commerce Indicator (05, 06, 07)

    @Column(name = "three_d_secure_cavv")
    private String threeDSecureCavv; // Cardholder Authentication Verification Value

    // ============================================
    // GATEWAY RESPONSE (Full JSON)
    // ============================================
    @Column(name = "gateway_response", columnDefinition = "TEXT")
    private String gatewayResponse;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}