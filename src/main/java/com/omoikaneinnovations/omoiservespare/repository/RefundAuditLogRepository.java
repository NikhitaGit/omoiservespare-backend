package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.RefundAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface RefundAuditLogRepository extends JpaRepository<RefundAuditLog, Long> {

    List<RefundAuditLog> findByRefundTransactionIdOrderByCreatedAtDesc(Long refundTransactionId);
    
    List<RefundAuditLog> findByEventType(String eventType);
    
    @Query("SELECT r FROM RefundAuditLog r WHERE r.refundTransaction.id = :refundTransactionId AND r.eventType = :eventType ORDER BY r.createdAt DESC")
    List<RefundAuditLog> findByRefundTransactionIdAndEventType(@Param("refundTransactionId") Long refundTransactionId, @Param("eventType") String eventType);
    
    @Query("SELECT r FROM RefundAuditLog r WHERE r.createdAt BETWEEN :startDate AND :endDate ORDER BY r.createdAt DESC")
    List<RefundAuditLog> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}