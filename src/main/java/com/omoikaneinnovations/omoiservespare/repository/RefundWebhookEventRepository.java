package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.RefundWebhookEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface RefundWebhookEventRepository extends JpaRepository<RefundWebhookEvent, Long> {

    Optional<RefundWebhookEvent> findByEventId(String eventId);
    
    List<RefundWebhookEvent> findByRefundId(String refundId);
    
    List<RefundWebhookEvent> findByProcessedFalseOrderByReceivedAtAsc();
    
    @Query("SELECT w FROM RefundWebhookEvent w WHERE w.processed = false AND w.retryCount < 3 ORDER BY w.receivedAt ASC")
    List<RefundWebhookEvent> findUnprocessedWithRetries();
    
    @Query("SELECT w FROM RefundWebhookEvent w WHERE w.receivedAt BETWEEN :startDate AND :endDate ORDER BY w.receivedAt DESC")
    List<RefundWebhookEvent> findByReceivedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}