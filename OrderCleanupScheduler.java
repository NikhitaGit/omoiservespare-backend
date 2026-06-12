package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.Order;
import com.omoikaneinnovations.omoiservespare.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Automatic cleanup of old orders
 * Deletes orders older than 1 year (past orders only)
 * 
 * Features:
 * - Runs daily at 2:00 AM
 * - Only deletes DELIVERED, CANCELLED, or FAILED orders
 * - Preserves active orders (ORDER_RECEIVED, PREPARING, READY_FOR_PICKUP, etc.)
 * - Logs all deletions for audit trail
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class OrderCleanupScheduler {

    private final OrderRepository orderRepository;

    /**
     * Runs every day at 2:00 AM
     * Deletes orders that are:
     * - Older than 1 year from order date
     * - Status: DELIVERED, CANCELLED, or FAILED
     */
    @Scheduled(cron = "0 0 2 * * *") // Every day at 2:00 AM
    @Transactional
    public void cleanupOldOrders() {
        log.info("🧹 Starting cleanup of orders older than 1 year...");

        try {
            // Calculate cutoff date (1 year ago)
            LocalDateTime oneYearAgo = LocalDateTime.now().minusYears(1);
            
            // Find old completed orders using efficient query
            List<Order> oldOrders = orderRepository.findOldCompletedOrders(oneYearAgo);
            
            if (oldOrders.isEmpty()) {
                log.info("✅ No old orders to delete");
                return;
            }
            
            log.info("📦 Found {} orders older than 1 year", oldOrders.size());
            
            // Log orders before deletion (for audit)
            for (Order order : oldOrders) {
                log.info("🗑️ Deleting order: {} | Date: {} | Status: {} | Amount: ₹{}", 
                    order.getOrderCode(), 
                    order.getCreatedAt(), 
                    order.getStatus(),
                    order.getTotalAmount());
            }
            
            // Delete using efficient bulk delete query
            int deletedCount = orderRepository.deleteOldCompletedOrders(oneYearAgo);
            
            log.info("✅ Cleanup completed - Deleted {} orders", deletedCount);
            
        } catch (Exception e) {
            log.error("❌ Order cleanup failed", e);
        }
    }
    
    /**
     * Manual cleanup method (can be called via admin endpoint if needed)
     * @param years Number of years to keep (deletes orders older than this)
     * @return Number of orders deleted
     */
    @Transactional
    public int cleanupOrdersOlderThan(int years) {
        log.info("🧹 Manual cleanup: Deleting orders older than {} years", years);
        
        LocalDateTime cutoffDate = LocalDateTime.now().minusYears(years);
        
        // Find orders to be deleted (for logging)
        List<Order> oldOrders = orderRepository.findOldCompletedOrders(cutoffDate);
        
        log.info("📦 Found {} orders to delete", oldOrders.size());
        
        // Delete orders
        int deletedCount = orderRepository.deleteOldCompletedOrders(cutoffDate);
        
        log.info("✅ Manual cleanup completed - Deleted {} orders", deletedCount);
        return deletedCount;
    }
    
    /**
     * Get count of orders that will be deleted
     * Useful for admin dashboard
     */
    public int getOldOrdersCount(int years) {
        LocalDateTime cutoffDate = LocalDateTime.now().minusYears(years);
        List<Order> oldOrders = orderRepository.findOldCompletedOrders(cutoffDate);
        return oldOrders.size();
    }
}