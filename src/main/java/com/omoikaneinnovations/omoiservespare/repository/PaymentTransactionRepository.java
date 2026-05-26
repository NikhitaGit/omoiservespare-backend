package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.PaymentTransaction;
import com.omoikaneinnovations.omoiservespare.entity.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, Long> {

    Optional<PaymentTransaction> findByTransactionId(String transactionId);

    Optional<PaymentTransaction> findByOrderId(Long orderId);

    List<PaymentTransaction> findByStatus(PaymentStatus status);

    @Query("SELECT pt FROM PaymentTransaction pt WHERE pt.order.customer.id = :customerId ORDER BY pt.createdAt DESC")
    List<PaymentTransaction> findByCustomerId(Long customerId);

    @Query("SELECT pt FROM PaymentTransaction pt WHERE pt.status = :status AND pt.createdAt BETWEEN :startTime AND :endTime")
    List<PaymentTransaction> findByStatusAndDateRange(PaymentStatus status, LocalDateTime startTime, LocalDateTime endTime);
}