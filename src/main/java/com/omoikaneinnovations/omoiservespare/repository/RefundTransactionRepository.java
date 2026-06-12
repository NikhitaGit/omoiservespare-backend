package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.RefundTransaction;
import com.omoikaneinnovations.omoiservespare.entity.RefundStatus;
import com.omoikaneinnovations.omoiservespare.entity.VendorApprovalStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import jakarta.persistence.LockModeType;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface RefundTransactionRepository extends JpaRepository<RefundTransaction, Long> {

    // Find by identifiers
    Optional<RefundTransaction> findByRefundId(String refundId);
    Optional<RefundTransaction> findByInternalRefundCode(String internalRefundCode);
    Optional<RefundTransaction> findByIdempotencyKey(String idempotencyKey);
    
    // CRITICAL: Pessimistic lock for refund processing to prevent race conditions
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT r FROM RefundTransaction r WHERE r.id = :id")
    Optional<RefundTransaction> findByIdForUpdate(@Param("id") Long id);

    // Find by relationships
    List<RefundTransaction> findByPaymentTransactionId(Long paymentTransactionId);
    Optional<RefundTransaction> findByCanteenOrderId(Long canteenOrderId);
    List<RefundTransaction> findByOrderId(Long orderId);
    List<RefundTransaction> findByCustomerId(Long customerId);

    // Find by status
    List<RefundTransaction> findByStatus(RefundStatus status);
    List<RefundTransaction> findByVendorApprovalStatus(VendorApprovalStatus vendorApprovalStatus);
    
    // Find refunds by order IDs (for user refunds)
    @Query("SELECT r FROM RefundTransaction r WHERE r.order.id IN :orderIds ORDER BY r.createdAt DESC")
    List<RefundTransaction> findByPaymentTransactionOrderIdIn(@Param("orderIds") List<Long> orderIds);
    
    // Find refunds pending vendor approval
    @Query("SELECT r FROM RefundTransaction r WHERE r.vendorApprovalStatus = 'PENDING' AND r.canteenOrder.canteenId = :canteenId ORDER BY r.createdAt ASC")
    List<RefundTransaction> findPendingApprovalsByCanteen(@Param("canteenId") Long canteenId);
    
    // Find refunds eligible for retry
    @Query("SELECT r FROM RefundTransaction r WHERE r.status IN ('FAILED', 'QUEUED') AND r.retryCount < r.maxRetries AND (r.nextRetryAt IS NULL OR r.nextRetryAt <= :now)")
    List<RefundTransaction> findEligibleForRetry(@Param("now") LocalDateTime now);
    
    // Find refunds by customer and status
    @Query("SELECT r FROM RefundTransaction r WHERE r.customer.id = :customerId AND r.status = :status ORDER BY r.createdAt DESC")
    List<RefundTransaction> findByCustomerIdAndStatus(@Param("customerId") Long customerId, @Param("status") RefundStatus status);
    
    // Count refunds by status
    @Query("SELECT COUNT(r) FROM RefundTransaction r WHERE r.status = :status")
    Long countByStatus(@Param("status") RefundStatus status);
    
    // Find refunds created in date range
    @Query("SELECT r FROM RefundTransaction r WHERE r.createdAt BETWEEN :startDate AND :endDate ORDER BY r.createdAt DESC")
    List<RefundTransaction> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}