package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@Table(name = "canteen_orders")
public class CanteenOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    private Order parentOrder;

    @Column(nullable = false)
    private Long canteenId;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    @Column(nullable = false)
    private BigDecimal subtotal;

    @OneToMany(mappedBy = "canteenOrder", cascade = CascadeType.ALL)
    private List<OrderItem> items;

    private LocalDateTime createdAt;

    @Column
    private String cancelReason;

    @Column(nullable = false)
    private boolean refunded = false;
}
