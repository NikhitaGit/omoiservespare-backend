package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "saved_payment_methods")
@Getter
@Setter
public class SavedPaymentMethod {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @Column(nullable = false)
    private String methodType; // "card", "upi", "wallet"

    @Column
    private String token; // Razorpay token

    @Column
    private String lastFour; // Last 4 digits

    @Column
    private String expiryDate; // MM/YY

    @Column
    private Boolean isDefault;

    @Column
    private LocalDateTime createdAt;
}