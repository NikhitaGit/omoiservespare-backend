package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "device_fingerprints")
@Getter
@Setter
public class DeviceFingerprint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @Column
    private String deviceId; // Unique device identifier

    @Column
    private String deviceName; // "iPhone 14", "Samsung Galaxy S23"

    @Column
    private String ipAddress;

    @Column
    private String userAgent;

    @Column
    private Boolean isTrusted; // User marked as trusted device

    @Column
    private LocalDateTime lastUsed;

    @Column
    private LocalDateTime createdAt;
}