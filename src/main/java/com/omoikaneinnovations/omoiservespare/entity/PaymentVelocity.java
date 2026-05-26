package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payment_velocity")
@Getter
@Setter
public class PaymentVelocity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @Column(name = "payment_count_1h")
    private Integer paymentCount1h; // Payments in last 1 hour

    @Column(name = "payment_count_24h")
    private Integer paymentCount24h; // Payments in last 24 hours

    @Column(name = "total_amount_1h")
    private BigDecimal totalAmount1h; // Total amount in last 1 hour

    @Column(name = "total_amount_24h")
    private BigDecimal totalAmount24h; // Total amount in last 24 hours

    @Column
    private LocalDateTime lastPaymentTime;

    @Column
    private LocalDateTime updatedAt;
}