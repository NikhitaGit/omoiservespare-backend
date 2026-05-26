package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.RefundTransaction;
import com.omoikaneinnovations.omoiservespare.entity.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RefundTransactionRepository extends JpaRepository<RefundTransaction, Long> {

    Optional<RefundTransaction> findByRefundId(String refundId);

    List<RefundTransaction> findByPaymentTransactionId(Long paymentTransactionId);

    List<RefundTransaction> findByStatus(PaymentStatus status);
}