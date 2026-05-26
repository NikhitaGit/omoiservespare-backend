package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.*;
import com.omoikaneinnovations.omoiservespare.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class FraudDetectionService {

    private final FraudDetectionLogRepository fraudLogRepo;
    private final PaymentVelocityRepository velocityRepo;
    private final DeviceFingerprintRepository deviceRepo;
    private final ObjectMapper objectMapper;

    // ============================================
    // FRAUD DETECTION THRESHOLDS
    // ============================================
    private static final BigDecimal MAX_AMOUNT_1H = BigDecimal.valueOf(50000); // ₹50k per hour
    private static final BigDecimal MAX_AMOUNT_24H = BigDecimal.valueOf(200000); // ₹2L per day
    private static final int MAX_TRANSACTIONS_1H = 10;
    private static final int MAX_TRANSACTIONS_24H = 50;

    /**
     * Analyze payment for fraud risk
     * Returns: FraudDetectionLog with risk score and action
     */
    @Transactional
    public FraudDetectionLog analyzePayment(
            PaymentTransaction transaction,
            String deviceId,
            String ipAddress,
            String userAgent) {

        FraudDetectionLog fraudLog = new FraudDetectionLog();
        fraudLog.setPaymentTransaction(transaction);
        fraudLog.setCreatedAt(LocalDateTime.now());

        Map<String, Object> fraudIndicators = new HashMap<>();
        BigDecimal riskScore = BigDecimal.ZERO;

        // ============================================
        // 1. VELOCITY CHECK (Most common fraud signal)
        // ============================================
        VelocityCheckResult velocityResult = checkPaymentVelocity(transaction.getOrder().getCustomer());
        riskScore = riskScore.add(velocityResult.riskScore);
        fraudIndicators.put("velocity", velocityResult.indicators);

        // ============================================
        // 2. DEVICE CHECK (New/untrusted device)
        // ============================================
        DeviceCheckResult deviceResult = checkDevice(
                transaction.getOrder().getCustomer(),
                deviceId,
                ipAddress,
                userAgent);
        riskScore = riskScore.add(deviceResult.riskScore);
        fraudIndicators.put("device", deviceResult.indicators);

        // ============================================
        // 3. AMOUNT ANOMALY CHECK
        // ============================================
        AnomalyCheckResult anomalyResult = checkAmountAnomaly(transaction);
        riskScore = riskScore.add(anomalyResult.riskScore);
        fraudIndicators.put("amount_anomaly", anomalyResult.indicators);

        // ============================================
        // 4. GEOGRAPHIC CHECK (IP location)
        // ============================================
        GeoCheckResult geoResult = checkGeographic(ipAddress, transaction.getOrder().getCustomer());
        riskScore = riskScore.add(geoResult.riskScore);
        fraudIndicators.put("geographic", geoResult.indicators);

        // ============================================
        // 5. CARD PATTERN CHECK
        // ============================================
        CardPatternResult cardResult = checkCardPattern(transaction);
        riskScore = riskScore.add(cardResult.riskScore);
        fraudIndicators.put("card_pattern", cardResult.indicators);

        // ============================================
        // DETERMINE RISK LEVEL & ACTION
        // ============================================
        fraudLog.setRiskScore(riskScore);
        fraudLog.setFraudIndicators(toJson(fraudIndicators));

        if (riskScore.compareTo(BigDecimal.valueOf(75)) >= 0) {
            fraudLog.setRiskLevel(FraudDetectionLog.RiskLevel.CRITICAL);
            fraudLog.setActionTaken("BLOCKED");
            log.warn("CRITICAL FRAUD RISK: Transaction {} blocked. Risk Score: {}", 
                transaction.getId(), riskScore);
        } else if (riskScore.compareTo(BigDecimal.valueOf(50)) >= 0) {
            fraudLog.setRiskLevel(FraudDetectionLog.RiskLevel.HIGH);
            fraudLog.setActionTaken("CHALLENGED");
            log.warn("HIGH FRAUD RISK: Transaction {} requires 3D Secure + OTP. Risk Score: {}", 
                transaction.getId(), riskScore);
        } else if (riskScore.compareTo(BigDecimal.valueOf(25)) >= 0) {
            fraudLog.setRiskLevel(FraudDetectionLog.RiskLevel.MEDIUM);
            fraudLog.setActionTaken("CHALLENGED");
            log.info("MEDIUM FRAUD RISK: Transaction {} requires 3D Secure. Risk Score: {}", 
                transaction.getId(), riskScore);
        } else {
            fraudLog.setRiskLevel(FraudDetectionLog.RiskLevel.LOW);
            fraudLog.setActionTaken("APPROVED");
            log.info("LOW FRAUD RISK: Transaction {} approved. Risk Score: {}", 
                transaction.getId(), riskScore);
        }

        return fraudLogRepo.save(fraudLog);
    }

    // ============================================
    // VELOCITY CHECK
    // ============================================
    private VelocityCheckResult checkPaymentVelocity(User customer) {
        VelocityCheckResult result = new VelocityCheckResult();
        result.riskScore = BigDecimal.ZERO;
        result.indicators = new HashMap<>();

        PaymentVelocity velocity = velocityRepo.findByCustomerId(customer.getId())
                .orElse(null);

        if (velocity == null) {
            result.indicators.put("status", "new_customer");
            result.indicators.put("risk", "low");
            return result;
        }

        // Check 1-hour limit
        if (velocity.getPaymentCount1h() > MAX_TRANSACTIONS_1H) {
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(20));
            result.indicators.put("excessive_transactions_1h", velocity.getPaymentCount1h());
        }

        if (velocity.getTotalAmount1h().compareTo(MAX_AMOUNT_1H) > 0) {
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(25));
            result.indicators.put("excessive_amount_1h", velocity.getTotalAmount1h());
        }

        // Check 24-hour limit
        if (velocity.getPaymentCount24h() > MAX_TRANSACTIONS_24H) {
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(15));
            result.indicators.put("excessive_transactions_24h", velocity.getPaymentCount24h());
        }

        if (velocity.getTotalAmount24h().compareTo(MAX_AMOUNT_24H) > 0) {
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(20));
            result.indicators.put("excessive_amount_24h", velocity.getTotalAmount24h());
        }

        result.indicators.put("status", "existing_customer");
        return result;
    }

    // ============================================
    // DEVICE CHECK
    // ============================================
    private DeviceCheckResult checkDevice(User customer, String deviceId, String ipAddress, String userAgent) {
        DeviceCheckResult result = new DeviceCheckResult();
        result.riskScore = BigDecimal.ZERO;
        result.indicators = new HashMap<>();

        if (deviceId == null || deviceId.isEmpty()) {
            result.indicators.put("status", "device_id_missing");
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(10));
            return result;
        }

        Optional<DeviceFingerprint> existingDevice = deviceRepo.findByCustomerIdAndDeviceId(customer.getId(), deviceId);

        if (existingDevice.isEmpty()) {
            // New device
            result.indicators.put("status", "new_device");
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(15));
            result.indicators.put("device_id", deviceId);
            result.indicators.put("ip_address", ipAddress);
        } else {
            DeviceFingerprint device = existingDevice.get();
            Boolean isTrusted = device.getIsTrusted();
            if (Boolean.TRUE.equals(isTrusted)) {
                result.indicators.put("status", "trusted_device");
                result.indicators.put("risk", "low");
            } else {
                result.indicators.put("status", "known_but_untrusted_device");
                result.riskScore = result.riskScore.add(BigDecimal.valueOf(10));
            }

            // Check if IP changed significantly
            if (!device.getIpAddress().equals(ipAddress)) {
                result.indicators.put("ip_changed", true);
                result.riskScore = result.riskScore.add(BigDecimal.valueOf(5));
            }
        }

        return result;
    }

    // ============================================
    // AMOUNT ANOMALY CHECK
    // ============================================
    private AnomalyCheckResult checkAmountAnomaly(PaymentTransaction transaction) {
        AnomalyCheckResult result = new AnomalyCheckResult();
        result.riskScore = BigDecimal.ZERO;
        result.indicators = new HashMap<>();

        BigDecimal amount = transaction.getAmount();

        // Unusually high amount
        if (amount.compareTo(BigDecimal.valueOf(10000)) > 0) {
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(10));
            result.indicators.put("high_amount", amount);
        }

        // Very high amount
        if (amount.compareTo(BigDecimal.valueOf(50000)) > 0) {
            result.riskScore = result.riskScore.add(BigDecimal.valueOf(20));
            result.indicators.put("very_high_amount", amount);
        }

        result.indicators.put("amount", amount);
        return result;
    }

    // ============================================
    // GEOGRAPHIC CHECK
    // ============================================
    private GeoCheckResult checkGeographic(String ipAddress, User customer) {
        GeoCheckResult result = new GeoCheckResult();
        result.riskScore = BigDecimal.ZERO;
        result.indicators = new HashMap<>();

        // In production, use MaxMind GeoIP2 or similar service
        // For now, basic check
        result.indicators.put("ip_address", ipAddress);
        result.indicators.put("status", "geo_check_enabled");

        // TODO: Integrate with GeoIP service
        // if (isVpnDetected(ipAddress)) {
        //     result.riskScore = result.riskScore.add(BigDecimal.valueOf(15));
        //     result.indicators.put("vpn_detected", true);
        // }

        return result;
    }

    // ============================================
    // CARD PATTERN CHECK
    // ============================================
    private CardPatternResult checkCardPattern(PaymentTransaction transaction) {
        CardPatternResult result = new CardPatternResult();
        result.riskScore = BigDecimal.ZERO;
        result.indicators = new HashMap<>();

        // Check if payment method is card
        if ("card".equalsIgnoreCase(transaction.getPaymentMethod())) {
            // In production, check:
            // - Card BIN (Bank Identification Number)
            // - Card country vs customer location
            // - Card type (credit vs debit)
            result.indicators.put("payment_method", "card");
            result.indicators.put("status", "card_pattern_check_enabled");
        }

        return result;
    }

    // ============================================
    // HELPER METHODS
    // ============================================
    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            log.error("Error converting to JSON", e);
            return "{}";
        }
    }

    // ============================================
    // INNER CLASSES FOR RESULTS
    // ============================================
    public static class VelocityCheckResult {
        public BigDecimal riskScore;
        public Map<String, Object> indicators;
    }

    public static class DeviceCheckResult {
        public BigDecimal riskScore;
        public Map<String, Object> indicators;
    }

    public static class AnomalyCheckResult {
        public BigDecimal riskScore;
        public Map<String, Object> indicators;
    }

    public static class GeoCheckResult {
        public BigDecimal riskScore;
        public Map<String, Object> indicators;
    }

    public static class CardPatternResult {
        public BigDecimal riskScore;
        public Map<String, Object> indicators;
    }
}