package com.omoikaneinnovations.omoiservespare.scheduler;

import com.omoikaneinnovations.omoiservespare.service.ProductionRefundService;
import com.omoikaneinnovations.omoiservespare.service.RefundWebhookService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Scheduled jobs for refund system
 * - Retry failed refunds
 * - Retry unprocessed webhooks
 * - Cleanup old records
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RefundScheduler {

    private final ProductionRefundService refundService;
    private final RefundWebhookService webhookService;

    /**
     * Retry failed refunds every 10 minutes
     */
    @Scheduled(fixedDelay = 600000) // 10 minutes
    public void retryFailedRefunds() {
        try {
            log.info("⏰ Running scheduled job: Retry failed refunds");
            refundService.retryFailedRefunds();
        } catch (Exception e) {
            log.error("❌ Failed to retry refunds", e);
        }
    }

    /**
     * Retry unprocessed webhooks every 5 minutes
     */
    @Scheduled(fixedDelay = 300000) // 5 minutes
    public void retryUnprocessedWebhooks() {
        try {
            log.info("⏰ Running scheduled job: Retry unprocessed webhooks");
            webhookService.retryUnprocessedWebhooks();
        } catch (Exception e) {
            log.error("❌ Failed to retry webhooks", e);
        }
    }
}