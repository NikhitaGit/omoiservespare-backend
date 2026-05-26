package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "refund_transactions")
@Getter
@Setter
public class RefundTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "payment_transaction_id", nullable = false)
    private PaymentTransaction paymentTransaction;

    @ManyToOne
    @JoinColumn(name = "canteen_order_id", nullable = false)
    private CanteenOrder canteenOrder;

    @Column(nullable = false)
    private BigDecimal refundAmount;

    @Column(unique = true)
    private String refundId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus status;

    @Column
    private String reason;

    @Column
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime updatedAt;
}