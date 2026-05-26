package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "payment_webhook_logs")
@Getter
@Setter
public class PaymentWebhookLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String gatewayName;

    @Column
    private String eventType;

    @Column
    private String transactionId;

    @Column(columnDefinition = "TEXT")
    private String payload;

    @Column
    private String signature;

    @Column
    private Boolean signatureValid;

    @Column
    private Boolean processed;

    @Column
    private String errorMessage;

    @Column
    private LocalDateTime createdAt;
}