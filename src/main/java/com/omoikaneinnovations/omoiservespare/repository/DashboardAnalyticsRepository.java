package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Custom queries for admin dashboard analytics
 * Optimized for performance with proper indexes
 */
public interface DashboardAnalyticsRepository extends JpaRepository<OrderItem, Long> {
    
    /**
     * Get trending items (most sold) in date range
     * Returns: menuItemId, name, totalQty, totalRevenue
     */
    @Query("SELECT oi.menuItemId, oi.name, " +
           "SUM(oi.quantity) as totalQty, " +
           "SUM(oi.quantity * oi.price) as totalRevenue " +
           "FROM OrderItem oi " +
           "JOIN oi.canteenOrder co " +
           "JOIN co.parentOrder o " +
           "WHERE o.createdAt >= :start AND o.createdAt <= :end " +
           "AND o.paymentStatus = 'SUCCESS' " +
           "GROUP BY oi.menuItemId, oi.name " +
           "ORDER BY totalQty DESC")
    List<Object[]> findTrendingItems(@Param("start") LocalDateTime start,
                                      @Param("end") LocalDateTime end);
    
    /**
     * Get top sold items for a specific date
     */
    @Query("SELECT oi.menuItemId, oi.name, SUM(oi.quantity) as totalQty " +
           "FROM OrderItem oi " +
           "JOIN oi.canteenOrder co " +
           "JOIN co.parentOrder o " +
           "WHERE DATE(o.createdAt) = DATE(:date) " +
           "AND o.paymentStatus = 'SUCCESS' " +
           "GROUP BY oi.menuItemId, oi.name " +
           "ORDER BY totalQty DESC")
    List<Object[]> findTopSoldToday(@Param("date") LocalDateTime date);
    
    /**
     * Get all items with their sales count for a date (includes 0 sales)
     * This helps identify least sold items
     */
    @Query("SELECT oi.menuItemId, oi.name, COALESCE(SUM(oi.quantity), 0) as totalQty " +
           "FROM OrderItem oi " +
           "JOIN oi.canteenOrder co " +
           "JOIN co.parentOrder o " +
           "WHERE DATE(o.createdAt) = DATE(:date) " +
           "AND o.paymentStatus = 'SUCCESS' " +
           "GROUP BY oi.menuItemId, oi.name " +
           "ORDER BY totalQty ASC")
    List<Object[]> findLeastSoldToday(@Param("date") LocalDateTime date);
    
    /**
     * Get item sales for previous period (for growth calculation)
     */
    @Query("SELECT oi.menuItemId, SUM(oi.quantity) as totalQty " +
           "FROM OrderItem oi " +
           "JOIN oi.canteenOrder co " +
           "JOIN co.parentOrder o " +
           "WHERE o.createdAt >= :start AND o.createdAt <= :end " +
           "AND o.paymentStatus = 'SUCCESS' " +
           "GROUP BY oi.menuItemId")
    List<Object[]> findItemSalesForPeriod(@Param("start") LocalDateTime start,
                                           @Param("end") LocalDateTime end);
}
