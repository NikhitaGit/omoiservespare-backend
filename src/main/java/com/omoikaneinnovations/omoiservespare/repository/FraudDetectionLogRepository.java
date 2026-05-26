package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.FraudDetectionLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface FraudDetectionLogRepository extends JpaRepository<FraudDetectionLog, Long> {

    List<FraudDetectionLog> findByPaymentTransactionId(Long paymentTransactionId);

    @Query("SELECT fdl FROM FraudDetectionLog fdl WHERE fdl.riskLevel IN ('HIGH', 'CRITICAL') ORDER BY fdl.createdAt DESC")
    List<FraudDetectionLog> findHighRiskTransactions();
}