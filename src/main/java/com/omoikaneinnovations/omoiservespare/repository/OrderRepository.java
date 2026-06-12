package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.Order;
import com.omoikaneinnovations.omoiservespare.entity.OrderStatus;
import com.omoikaneinnovations.omoiservespare.entity.PaymentStatus;
import com.omoikaneinnovations.omoiservespare.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByOrderCode(String orderCode);

    // Sort by createdAt descending (most recent first)
    @Query("SELECT o FROM Order o WHERE o.customer = :customer ORDER BY o.createdAt DESC")
    List<Order> findByCustomer(@Param("customer") User customer);

    List<Order> findByCustomerAndStatus(User customer, OrderStatus status);

    // Find expired pending orders for cleanup
    List<Order> findByStatusAndPaymentStatusAndCreatedAtBefore(
            OrderStatus status,
            PaymentStatus paymentStatus,
            LocalDateTime createdBefore
    );

    // Find old completed orders for cleanup (older than specified date)
    @Query("SELECT o FROM Order o WHERE o.createdAt < :cutoffDate AND " +
           "(o.status = 'DELIVERED' OR o.status = 'CANCELLED' OR o.status = 'FAILED')")
    List<Order> findOldCompletedOrders(@Param("cutoffDate") LocalDateTime cutoffDate);
    
    // Delete old completed orders (more efficient)
    @Modifying
    @Query("DELETE FROM Order o WHERE o.createdAt < :cutoffDate AND " +
           "(o.status = 'DELIVERED' OR o.status = 'CANCELLED' OR o.status = 'FAILED')")
    int deleteOldCompletedOrders(@Param("cutoffDate") LocalDateTime cutoffDate);

    
    // ========================================
    // ADMIN DASHBOARD QUERIES
    // ========================================
    
    /**
     * Get total revenue for date range
     */
    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o " +
           "WHERE o.createdAt >= :start AND o.createdAt <= :end " +
           "AND o.paymentStatus = :status")
    BigDecimal getTotalRevenue(@Param("start") LocalDateTime start,
                                @Param("end") LocalDateTime end,
                                @Param("status") PaymentStatus status);
    
    /**
     * Count orders in date range
     */
    @Query("SELECT COUNT(o) FROM Order o " +
           "WHERE o.createdAt >= :start AND o.createdAt <= :end " +
           "AND o.paymentStatus = :status")
    Long countOrders(@Param("start") LocalDateTime start,
                     @Param("end") LocalDateTime end,
                     @Param("status") PaymentStatus status);
    
    /**
     * Count unique customers in date range
     */
    @Query("SELECT COUNT(DISTINCT o.customer.id) FROM Order o " +
           "WHERE o.createdAt >= :start AND o.createdAt <= :end " +
           "AND o.paymentStatus = :status")
    Long countUniqueCustomers(@Param("start") LocalDateTime start,
                               @Param("end") LocalDateTime end,
                               @Param("status") PaymentStatus status);
    
    /**
     * Get revenue time series (daily buckets)
     */
    @Query("SELECT DATE(o.createdAt) as date, " +
           "SUM(o.totalAmount) as sales, " +
           "COUNT(o) as orders " +
           "FROM Order o " +
           "WHERE o.createdAt >= :start AND o.createdAt <= :end " +
           "AND o.paymentStatus = :status " +
           "GROUP BY DATE(o.createdAt) " +
           "ORDER BY DATE(o.createdAt)")
    List<Object[]> getRevenueSeries(@Param("start") LocalDateTime start,
                                     @Param("end") LocalDateTime end,
                                     @Param("status") PaymentStatus status);
    
    /**
     * Count returning customers (customers with more than 1 order)
     */
    @Query("SELECT COUNT(DISTINCT o.customer.id) FROM Order o " +
           "WHERE o.createdAt >= :start AND o.createdAt <= :end " +
           "AND o.paymentStatus = :status " +
           "AND o.customer.id IN (" +
           "  SELECT o2.customer.id FROM Order o2 " +
           "  WHERE o2.paymentStatus = :status " +
           "  GROUP BY o2.customer.id " +
           "  HAVING COUNT(o2) > 1" +
           ")")
    Long countReturningCustomers(@Param("start") LocalDateTime start,
                                  @Param("end") LocalDateTime end,
                                  @Param("status") PaymentStatus status);
}