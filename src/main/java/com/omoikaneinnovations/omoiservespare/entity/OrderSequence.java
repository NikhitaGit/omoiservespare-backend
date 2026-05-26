package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "order_sequences")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderSequence {
    
    @Id
    @Column(name = "payment_method", length = 20)
    private String paymentMethod; // "ONLINE", "WALLET", "CASH"
    
    @Column(name = "current_sequence", nullable = false)
    private Long currentSequence = 0L;
    
    @Version
    private Long version; // For optimistic locking to handle concurrent access
}