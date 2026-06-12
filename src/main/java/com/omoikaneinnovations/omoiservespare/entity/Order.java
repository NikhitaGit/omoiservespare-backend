package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String orderCode;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus paymentStatus;

    @Column
    private String paymentMethod;

    @Column(nullable = false)
    private BigDecimal totalAmount;

    @OneToMany(mappedBy = "parentOrder", cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<CanteenOrder> canteenOrders;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

}