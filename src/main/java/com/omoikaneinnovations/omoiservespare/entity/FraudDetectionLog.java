package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "fraud_detection_logs")
@Getter
@Setter
public class FraudDetectionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "payment_transaction_id")
    private PaymentTransaction paymentTransaction;

    @Column
    private BigDecimal riskScore; // 0-100 (0=safe, 100=fraud)

    @Enumerated(EnumType.STRING)
    @Column
    private RiskLevel riskLevel; // LOW, MEDIUM, HIGH, CRITICAL

    @Column(columnDefinition = "TEXT")
    private String fraudIndicators; // JSON with all fraud signals

    @Column
    private String actionTaken; // "APPROVED", "CHALLENGED", "BLOCKED"

    @Column
    private LocalDateTime createdAt;

    public enum RiskLevel {
        LOW,      // 0-25: Approve immediately
        MEDIUM,   // 25-50: Require 3D Secure
        HIGH,     // 50-75: Require OTP + 3D Secure
        CRITICAL  // 75-100: Block transaction
    }
}