package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.Order;
import com.omoikaneinnovations.omoiservespare.entity.OrderStatus;
import com.omoikaneinnovations.omoiservespare.entity.PaymentStatus;
import com.omoikaneinnovations.omoiservespare.entity.PaymentVelocity;
import com.omoikaneinnovations.omoiservespare.repository.OrderRepository;
import com.omoikaneinnovations.omoiservespare.repository.PaymentVelocityRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentSchedulerService {

    private final PaymentVelocityRepository velocityRepo;
    private final OrderRepository orderRepository;

    @Value("${order.pending.expiry-minutes:30}")
    private int pendingOrderExpiryMinutes;

    @Value("${order.cleanup.enabled:true}")
    private boolean cleanupEnabled;

    /**
     * Cleanup expired pending orders
     * Runs every 10 minutes to check for orders that have been pending too long
     * 
     * This prevents:
     * - Inventory being held indefinitely
     * - Database clutter
     * - Confusion for users and vendors
     */
    @Scheduled(fixedDelayString = "${order.cleanup.interval-ms:600000}") // Every 10 minutes
    @Transactional
    public void cleanupExpiredPendingOrders() {
        if (!cleanupEnabled) {
            log.debug("Order cleanup is disabled");
            return;
        }

        try {
            log.info("Starting cleanup of expired pending orders...");

            LocalDateTime expiryTime = LocalDateTime.now().minusMinutes(pendingOrderExpiryMinutes);

            // Find all pending orders older than expiry time
            List<Order> expiredOrders = orderRepository.findByStatusAndPaymentStatusAndCreatedAtBefore(
                    OrderStatus.PENDING,
                    PaymentStatus.PENDING,
                    expiryTime
            );

            if (expiredOrders.isEmpty()) {
                log.info("No expired pending orders found");
                return;
            }

            int cancelledCount = 0;
            for (Order order : expiredOrders) {
                try {
                    // Update order status to CANCELLED
                    order.setStatus(OrderStatus.CANCELLED);
                    order.setPaymentStatus(PaymentStatus.FAILED);
                    order.setUpdatedAt(LocalDateTime.now());

                    // Also cancel all associated canteen orders
                    if (order.getCanteenOrders() != null) {
                        for (var canteenOrder : order.getCanteenOrders()) {
                            canteenOrder.setStatus(OrderStatus.CANCELLED);
                        }
                    }
                    
                    orderRepository.save(order);
                    cancelledCount++;
                    
                    log.info("Cancelled expired order: {} (created at: {}, age: {} minutes)",
                            order.getOrderCode(),
                            order.getCreatedAt(),
                            java.time.Duration.between(order.getCreatedAt(), LocalDateTime.now()).toMinutes());
                    
                } catch (Exception e) {
                    log.error("Error cancelling order {}: {}", order.getOrderCode(), e.getMessage());
                }
            }

            log.info("Expired pending orders cleanup completed - {} orders cancelled out of {} found",
                    cancelledCount, expiredOrders.size());

        } catch (Exception e) {
            log.error("Error during expired pending orders cleanup", e);
        }
    }

    /**
     * Reset 1-hour payment velocity counters
     * Runs every hour at the top of the hour
     */
    @Scheduled(cron = "0 0 * * * *") // Every hour at :00
    @Transactional
    public void reset1HourVelocity() {
        try {
            log.info("Starting 1-hour velocity reset...");

            List<PaymentVelocity> velocities = velocityRepo.findAll();

            for (PaymentVelocity velocity : velocities) {
                // Check if last payment was more than 1 hour ago
                if (velocity.getLastPaymentTime() != null) {
                    LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);
                    if (velocity.getLastPaymentTime().isBefore(oneHourAgo)) {
                        velocity.setPaymentCount1h(0);
                        velocity.setTotalAmount1h(BigDecimal.ZERO);
                    }
                }
            }

            velocityRepo.saveAll(velocities);
            log.info("1-hour velocity reset completed - {} records updated", velocities.size());

        } catch (Exception e) {
            log.error("Error resetting 1-hour velocity", e);
        }
    }

    /**
     * Reset 24-hour payment velocity counters
     * Runs daily at midnight
     */
    @Scheduled(cron = "0 0 0 * * *") // Every day at 00:00
    @Transactional
    public void reset24HourVelocity() {
        try {
            log.info("Starting 24-hour velocity reset...");

            List<PaymentVelocity> velocities = velocityRepo.findAll();

            for (PaymentVelocity velocity : velocities) {
                // Check if last payment was more than 24 hours ago
                if (velocity.getLastPaymentTime() != null) {
                    LocalDateTime oneDayAgo = LocalDateTime.now().minusDays(1);
                    if (velocity.getLastPaymentTime().isBefore(oneDayAgo)) {
                        velocity.setPaymentCount24h(0);
                        velocity.setTotalAmount24h(BigDecimal.ZERO);
                    }
                }
            }

            velocityRepo.saveAll(velocities);
            log.info("24-hour velocity reset completed - {} records updated", velocities.size());

        } catch (Exception e) {
            log.error("Error resetting 24-hour velocity", e);
        }
    }

    /**
     * Cleanup old fraud detection logs
     * Runs daily at 2 AM (keep last 90 days)
     */
    @Scheduled(cron = "0 0 2 * * *") // Every day at 02:00
    @Transactional
    public void cleanupOldFraudLogs() {
        try {
            log.info("Starting fraud detection logs cleanup...");

            // TODO: Implement cleanup logic
            // Delete fraud logs older than 90 days

            log.info("Fraud detection logs cleanup completed");

        } catch (Exception e) {
            log.error("Error cleaning up fraud logs", e);
        }
    }

    /**
     * Reconcile payments with Razorpay
     * Runs every 6 hours to ensure data consistency
     */
    @Scheduled(cron = "0 0 */6 * * *") // Every 6 hours
    @Transactional
    public void reconcilePayments() {
        try {
            log.info("Starting payment reconciliation with Razorpay...");

            // TODO: Implement reconciliation logic
            // Compare local payment records with Razorpay dashboard
            // Flag any discrepancies

            log.info("Payment reconciliation completed");

        } catch (Exception e) {
            log.error("Error reconciling payments", e);
        }
    }
}