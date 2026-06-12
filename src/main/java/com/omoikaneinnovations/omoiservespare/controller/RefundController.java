package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.RefundRequestDTO;
import com.omoikaneinnovations.omoiservespare.dto.RefundResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.VendorApprovalDTO;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.exception.PaymentException;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.service.ProductionRefundService;
import com.omoikaneinnovations.omoiservespare.service.RefundWebhookService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;
import java.util.Map;

/**
 * PRODUCTION-GRADE REFUND CONTROLLER
 * 
 * Endpoints:
 * - POST /api/refunds/request-cancellation - Customer/Vendor requests cancellation
 * - POST /api/refunds/vendor-approval - Vendor approves/rejects cancellation
 * - GET /api/refunds/my-refunds - Get all refunds for current user
 * - GET /api/refunds/{refundId} - Get refund details
 * - GET /api/refunds/pending-approvals/{canteenId} - Get pending approvals for vendor
 * - POST /api/refunds/webhook - Razorpay webhook endpoint
 */
@RestController
@RequestMapping("/api/refunds")
@RequiredArgsConstructor
@Slf4j
public class RefundController {

    private final ProductionRefundService refundService;
    private final RefundWebhookService webhookService;
    private final UserRepository userRepository;

    // ============================================
    // CUSTOMER/VENDOR ENDPOINTS
    // ============================================

    /**
     * Request cancellation (Customer or Vendor)
     * 
     * POST /api/refunds/request-cancellation
     * {
     *   "canteenOrderId": 123,
     *   "reason": "Customer changed mind",
     *   "requestedBy": "CUSTOMER"
     * }
     */
    @PostMapping("/request-cancellation")
    public ResponseEntity<?> requestCancellation(
            @RequestBody RefundRequestDTO request,
            HttpServletRequest httpRequest) {
        try {
            User user = getCurrentUser();
            
            RefundResponseDTO response = refundService.requestCancellation(request, user);
            
            log.info("✅ Cancellation requested - Refund Code: {}, User: {}", 
                response.getInternalRefundCode(), user.getEmail());
            
            return ResponseEntity.ok(response);
            
        } catch (PaymentException e) {
            log.error("❌ Cancellation request failed - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                "error", e.getErrorCode(),
                "message", e.getErrorMessage()
            ));
            
        } catch (Exception e) {
            log.error("❌ Cancellation request failed", e);
            return ResponseEntity.status(500).body(Map.of(
                "error", "INTERNAL_ERROR",
                "message", "Cancellation request failed: " + e.getMessage()
            ));
        }
    }

    /**
     * Vendor approves or rejects cancellation
     * 
     * POST /api/refunds/vendor-approval
     * {
     *   "canteenOrderId": 123,
     *   "action": "APPROVE",
     *   "remarks": "Order not yet started",
     *   "vendorId": 456
     * }
     */
    @PostMapping("/vendor-approval")
    public ResponseEntity<?> vendorApproval(
            @RequestBody VendorApprovalDTO approvalDTO,
            HttpServletRequest httpRequest) {
        try {
            User vendor = getCurrentUser();
            
            RefundResponseDTO response = refundService.vendorApproval(approvalDTO, vendor);
            
            log.info("✅ Vendor approval processed - Action: {}, Vendor: {}", 
                approvalDTO.getAction(), vendor.getEmail());
            
            return ResponseEntity.ok(response);
            
        } catch (PaymentException e) {
            log.error("❌ Vendor approval failed - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                "error", e.getErrorCode(),
                "message", e.getErrorMessage()
            ));
            
        } catch (Exception e) {
            log.error("❌ Vendor approval failed", e);
            return ResponseEntity.status(500).body(Map.of(
                "error", "INTERNAL_ERROR",
                "message", "Vendor approval failed: " + e.getMessage()
            ));
        }
    }

    /**
     * Get all refunds for the current user
     * 
     * GET /api/refunds/my-refunds
     */
    @GetMapping("/my-refunds")
    public ResponseEntity<?> getMyRefunds() {
        try {
            User user = getCurrentUser();
            
            List<RefundResponseDTO> refunds = refundService.getUserRefunds(user);
            
            log.info("✅ Fetched {} refunds for user: {}", refunds.size(), user.getEmail());
            
            return ResponseEntity.ok(refunds);
            
        } catch (Exception e) {
            log.error("❌ Failed to fetch user refunds", e);
            return ResponseEntity.status(500).body(Map.of(
                "error", "INTERNAL_ERROR",
                "message", "Failed to fetch refunds: " + e.getMessage()
            ));
        }
    }

    /**
     * Get refund details by refund ID
     * 
     * GET /api/refunds/{refundId}
     */
    @GetMapping("/{refundId}")
    public ResponseEntity<?> getRefundDetails(@PathVariable String refundId) {
        try {
            User user = getCurrentUser();
            
            RefundResponseDTO refund = refundService.getRefundDetails(refundId, user);
            
            log.info("✅ Fetched refund details - Refund ID: {}, User: {}", 
                refundId, user.getEmail());
            
            return ResponseEntity.ok(refund);
            
        } catch (PaymentException e) {
            log.error("❌ Failed to fetch refund details - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                "error", e.getErrorCode(),
                "message", e.getErrorMessage()
            ));
            
        } catch (Exception e) {
            log.error("❌ Failed to fetch refund details", e);
            return ResponseEntity.status(500).body(Map.of(
                "error", "INTERNAL_ERROR",
                "message", "Failed to fetch refund details: " + e.getMessage()
            ));
        }
    }

    /**
     * Get pending approvals for a canteen (Vendor only)
     * 
     * GET /api/refunds/pending-approvals/{canteenId}
     */
    @GetMapping("/pending-approvals/{canteenId}")
    public ResponseEntity<?> getPendingApprovals(@PathVariable Long canteenId) {
        try {
            // TODO: Verify vendor owns this canteen
            
            List<RefundResponseDTO> refunds = refundService.getPendingApprovals(canteenId);
            
            log.info("✅ Fetched {} pending approvals for canteen: {}", 
                refunds.size(), canteenId);
            
            return ResponseEntity.ok(refunds);
            
        } catch (Exception e) {
            log.error("❌ Failed to fetch pending approvals", e);
            return ResponseEntity.status(500).body(Map.of(
                "error", "INTERNAL_ERROR",
                "message", "Failed to fetch pending approvals: " + e.getMessage()
            ));
        }
    }

    /**
     * Manually sync refund status with Razorpay
     * 
     * POST /api/refunds/{refundId}/sync
     */
    @PostMapping("/{refundId}/sync")
    public ResponseEntity<?> syncRefundStatus(@PathVariable String refundId) {
        try {
            User user = getCurrentUser();
            
            RefundResponseDTO refund = refundService.syncRefundStatus(refundId, user);
            
            log.info("✅ Synced refund status - Refund ID: {}, Status: {}", 
                refundId, refund.getStatus());
            
            return ResponseEntity.ok(refund);
            
        } catch (PaymentException e) {
            log.error("❌ Failed to sync refund status - Error: {}", e.getErrorCode());
            return ResponseEntity.status(400).body(Map.of(
                "error", e.getErrorCode(),
                "message", e.getErrorMessage()
            ));
            
        } catch (Exception e) {
            log.error("❌ Failed to sync refund status", e);
            return ResponseEntity.status(500).body(Map.of(
                "error", "INTERNAL_ERROR",
                "message", "Failed to sync refund status: " + e.getMessage()
            ));
        }
    }

    // ============================================
    // WEBHOOK ENDPOINT
    // ============================================

    /**
     * Razorpay webhook endpoint for refund events
     * 
     * POST /api/refunds/webhook
     * 
     * Events:
     * - refund.processed
     * - refund.failed
     * - refund.speed_changed
     */
    @PostMapping("/webhook")
    public ResponseEntity<?> handleWebhook(
            @RequestBody String payload,
            @RequestHeader("X-Razorpay-Signature") String signature) {
        try {
            log.info("🔔 Received refund webhook");
            
            webhookService.processWebhook(payload, signature);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "Webhook processed"
            ));
            
        } catch (Exception e) {
            log.error("❌ Webhook processing failed", e);
            // Return 200 to prevent Razorpay from retrying
            return ResponseEntity.ok(Map.of(
                "status", "error",
                "message", "Webhook processing failed"
            ));
        }
    }

    // ============================================
    // HELPER METHODS
    // ============================================

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        
        if (auth == null || !auth.isAuthenticated()) {
            throw new RuntimeException("Unauthenticated");
        }
        
        String email = auth.getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}