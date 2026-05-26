package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.RewardDTO;
import com.omoikaneinnovations.omoiservespare.dto.UserRewardDTO;
import com.omoikaneinnovations.omoiservespare.entity.*;
import com.omoikaneinnovations.omoiservespare.event.OrderCompletedEvent;
import com.omoikaneinnovations.omoiservespare.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class RewardService {
    
    private final RewardRuleRepository rewardRuleRepository;
    private final UserRewardProgressRepository progressRepository;
    private final UserRewardRepository userRewardRepository;
    private final UserRepository userRepository;
    
    /**
     * Process order completion and check for reward eligibility
     * Called via Kafka consumer for real-time processing
     */
    @Transactional
    public void processOrderCompletion(OrderCompletedEvent event) {
        log.info("Processing order completion for rewards: orderId={}, userId={}", 
            event.getOrderId(), event.getUserId());
        
        try {
            // Get all active reward rules
            List<RewardRule> activeRules = rewardRuleRepository.findByIsActiveTrueOrderByPriorityAsc();
            
            for (RewardRule rule : activeRules) {
                processRuleForOrder(rule, event);
            }
            
        } catch (Exception e) {
            log.error("Error processing rewards for order {}: {}", event.getOrderId(), e.getMessage(), e);
        }
    }
    
    /**
     * Process a specific rule for an order
     */
    private void processRuleForOrder(RewardRule rule, OrderCompletedEvent event) {
        // Get or create progress for this rule
        UserRewardProgress progress = getOrCreateProgress(event.getUserId(), rule);
        
        // Update progress based on rule type
        boolean progressUpdated = false;
        
        switch (rule.getRuleType()) {
            case "ORDER_COUNT":
                progress.setCurrentOrderCount(progress.getCurrentOrderCount() + 1);
                progressUpdated = true;
                
                // Instant reward for order-based cashback
                if (rule.getRewardPercentage() != null && event.getWalletAmountUsed() != null 
                    && event.getWalletAmountUsed().compareTo(BigDecimal.ZERO) > 0) {
                    unlockInstantCashback(event.getUserId(), rule, event);
                }
                break;
                
            case "SPEND_AMOUNT":
                BigDecimal newSpend = progress.getCurrentSpendAmount().add(event.getOrderAmount());
                progress.setCurrentSpendAmount(newSpend);
                progressUpdated = true;
                break;
                
            case "COMBO":
                progress.setCurrentOrderCount(progress.getCurrentOrderCount() + 1);
                progressUpdated = true;
                break;
        }
        
        if (progressUpdated) {
            progress.setUpdatedAt(LocalDateTime.now());
            progressRepository.save(progress);
            
            // Check if rule is satisfied
            checkAndUnlockReward(event.getUserId(), rule, progress, event.getOrderId());
        }
    }
    
    /**
     * Unlock instant cashback for order-based rewards
     */
    private void unlockInstantCashback(Long userId, RewardRule rule, OrderCompletedEvent event) {
        BigDecimal cashbackAmount = event.getWalletAmountUsed()
            .multiply(rule.getRewardPercentage())
            .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        
        // Cap at max reward amount
        if (rule.getMaxRewardAmount() != null && cashbackAmount.compareTo(rule.getMaxRewardAmount()) > 0) {
            cashbackAmount = rule.getMaxRewardAmount();
        }
        
        UserReward reward = new UserReward();
        reward.setUserId(userId);
        reward.setRewardRuleId(rule.getId());
        reward.setRewardType(rule.getRewardType());
        reward.setRewardAmount(cashbackAmount);
        reward.setStatus("UNLOCKED");
        reward.setOrderId(event.getOrderId());
        reward.setExpiresAt(LocalDateTime.now().plusDays(30));
        reward.setNotes("Earned from order #" + event.getOrderId());
        
        userRewardRepository.save(reward);
        
        log.info("Unlocked instant cashback: userId={}, amount={}, orderId={}", 
            userId, cashbackAmount, event.getOrderId());
    }
    
    /**
     * Check if reward criteria is met and unlock reward
     */
    private void checkAndUnlockReward(Long userId, RewardRule rule, UserRewardProgress progress, Long orderId) {
        if (progress.getIsCompleted()) {
            return; // Already completed
        }
        
        boolean criteriaMet = false;
        
        switch (rule.getRuleType()) {
            case "WALLET_BALANCE":
                // Check wallet balance separately (updated via wallet service)
                break;
                
            case "ORDER_COUNT":
                if (rule.getMinOrderCount() != null) {
                    criteriaMet = progress.getCurrentOrderCount() >= rule.getMinOrderCount();
                }
                break;
                
            case "SPEND_AMOUNT":
                if (rule.getMinSpendAmount() != null) {
                    criteriaMet = progress.getCurrentSpendAmount().compareTo(rule.getMinSpendAmount()) >= 0;
                }
                break;
                
            case "COMBO":
                // Check both wallet balance and order count
                criteriaMet = checkComboRuleCriteria(userId, rule, progress);
                break;
        }
        
        if (criteriaMet) {
            unlockReward(userId, rule, progress, orderId);
        }
    }
    
    /**
     * Check combo rule criteria (wallet balance + order count)
     */
    private boolean checkComboRuleCriteria(Long userId, RewardRule rule, UserRewardProgress progress) {
        // Check order count
        boolean orderCountMet = rule.getMinOrderCount() == null || 
            progress.getCurrentOrderCount() >= rule.getMinOrderCount();
        
        // Check wallet balance
        boolean walletBalanceMet = rule.getMinWalletBalance() == null || 
            progress.getCurrentWalletBalance().compareTo(rule.getMinWalletBalance()) >= 0;
        
        return orderCountMet && walletBalanceMet;
    }
    
    /**
     * Unlock reward for user
     */
    private void unlockReward(Long userId, RewardRule rule, UserRewardProgress progress, Long orderId) {
        // Check if already unlocked in this period
        Long existingRewards = userRewardRepository.countRewardsUnlockedInPeriod(
            userId, rule.getId(), progress.getPeriodStartDate()
        );
        
        if (existingRewards > 0) {
            log.info("Reward already unlocked for this period: userId={}, ruleId={}", userId, rule.getId());
            return;
        }
        
        UserReward reward = new UserReward();
        reward.setUserId(userId);
        reward.setRewardRuleId(rule.getId());
        reward.setRewardType(rule.getRewardType());
        reward.setRewardAmount(rule.getRewardAmount());
        reward.setCouponCode(rule.getCouponCode());
        reward.setStatus("UNLOCKED");
        reward.setOrderId(orderId);
        reward.setExpiresAt(LocalDateTime.now().plusDays(30));
        reward.setNotes("Unlocked by completing: " + rule.getTitle());
        
        userRewardRepository.save(reward);
        
        // Mark progress as completed
        progress.setIsCompleted(true);
        progress.setCompletedAt(LocalDateTime.now());
        progressRepository.save(progress);
        
        log.info("Reward unlocked: userId={}, ruleId={}, amount={}", 
            userId, rule.getId(), rule.getRewardAmount());
    }
    
    /**
     * Get or create progress for a rule
     */
    private UserRewardProgress getOrCreateProgress(Long userId, RewardRule rule) {
        LocalDateTime now = LocalDateTime.now();
        
        Optional<UserRewardProgress> existing = progressRepository.findActiveProgressForRule(
            userId, rule.getId(), now
        );
        
        if (existing.isPresent()) {
            return existing.get();
        }
        
        // Create new progress for current period
        UserRewardProgress progress = new UserRewardProgress();
        progress.setUserId(userId);
        progress.setRewardRuleId(rule.getId());
        progress.setPeriodStartDate(now);
        progress.setPeriodEndDate(now.plusDays(rule.getTimePeriodDays()));
        progress.setCurrentWalletBalance(BigDecimal.ZERO);
        progress.setCurrentOrderCount(0);
        progress.setCurrentSpendAmount(BigDecimal.ZERO);
        
        return progressRepository.save(progress);
    }
    
    /**
     * Update wallet balance for reward tracking
     */
    @Transactional
    public void updateWalletBalance(Long userId, BigDecimal newBalance) {
        List<RewardRule> walletRules = rewardRuleRepository
            .findByIsActiveTrueAndRuleTypeOrderByPriorityAsc("WALLET_BALANCE");
        
        for (RewardRule rule : walletRules) {
            UserRewardProgress progress = getOrCreateProgress(userId, rule);
            progress.setCurrentWalletBalance(newBalance);
            progressRepository.save(progress);
            
            // Check if wallet balance criteria is met
            if (rule.getMinWalletBalance() != null && 
                newBalance.compareTo(rule.getMinWalletBalance()) >= 0) {
                checkAndUnlockReward(userId, rule, progress, null);
            }
        }
    }
    
    /**
     * Get all rewards for user (for rewards page)
     */
    public List<RewardDTO> getUserRewards(Long userId) {
        List<RewardRule> allRules = rewardRuleRepository.findByIsActiveTrueOrderByPriorityAsc();
        List<UserRewardProgress> userProgress = progressRepository.findByUserIdAndIsCompletedFalse(userId);
        List<UserReward> unlockedRewards = userRewardRepository.findActiveRewardsByUserId(userId, LocalDateTime.now());
        
        return allRules.stream().map(rule -> {
            RewardDTO dto = new RewardDTO();
            dto.setId(rule.getId());
            dto.setTitle(rule.getTitle());
            dto.setHighlight(rule.getHighlight());
            dto.setDescription(rule.getDescription());
            dto.setSubText(rule.getSubText());
            dto.setTag(rule.getTag());
            dto.setRuleType(rule.getRuleType());
            dto.setRewardType(rule.getRewardType());
            dto.setRewardAmount(rule.getRewardAmount());
            dto.setRewardPercentage(rule.getRewardPercentage());
            dto.setCouponCode(rule.getCouponCode());
            
            // Set criteria
            dto.setMinWalletBalance(rule.getMinWalletBalance());
            dto.setMinOrderCount(rule.getMinOrderCount());
            dto.setMinSpendAmount(rule.getMinSpendAmount());
            
            // Find progress for this rule
            Optional<UserRewardProgress> progress = userProgress.stream()
                .filter(p -> p.getRewardRuleId().equals(rule.getId()))
                .findFirst();
            
            if (progress.isPresent()) {
                UserRewardProgress p = progress.get();
                dto.setCurrentWalletBalance(p.getCurrentWalletBalance());
                dto.setCurrentOrderCount(p.getCurrentOrderCount());
                dto.setCurrentSpendAmount(p.getCurrentSpendAmount());
                dto.setIsCompleted(p.getIsCompleted());
                
                // Calculate progress percentage
                dto.setProgressPercentage(calculateProgressPercentage(rule, p));
                dto.setProgressText(generateProgressText(rule, p));
            } else {
                dto.setCurrentWalletBalance(BigDecimal.ZERO);
                dto.setCurrentOrderCount(0);
                dto.setCurrentSpendAmount(BigDecimal.ZERO);
                dto.setIsCompleted(false);
                dto.setProgressPercentage(0);
                dto.setProgressText("Not started");
            }
            
            // Check if reward is unlocked
            Optional<UserReward> unlocked = unlockedRewards.stream()
                .filter(r -> r.getRewardRuleId().equals(rule.getId()))
                .findFirst();
            
            if (unlocked.isPresent()) {
                dto.setIsUnlocked(true);
                dto.setUserRewardId(unlocked.get().getId());
                dto.setRewardStatus(unlocked.get().getStatus());
            } else {
                dto.setIsUnlocked(false);
            }
            
            return dto;
        }).collect(Collectors.toList());
    }
    
    /**
     * Calculate progress percentage
     */
    private Integer calculateProgressPercentage(RewardRule rule, UserRewardProgress progress) {
        switch (rule.getRuleType()) {
            case "WALLET_BALANCE":
                if (rule.getMinWalletBalance() != null && rule.getMinWalletBalance().compareTo(BigDecimal.ZERO) > 0) {
                    return Math.min(100, progress.getCurrentWalletBalance()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(rule.getMinWalletBalance(), 0, RoundingMode.DOWN)
                        .intValue());
                }
                break;
            case "ORDER_COUNT":
                if (rule.getMinOrderCount() != null && rule.getMinOrderCount() > 0) {
                    return Math.min(100, (progress.getCurrentOrderCount() * 100) / rule.getMinOrderCount());
                }
                break;
            case "SPEND_AMOUNT":
                if (rule.getMinSpendAmount() != null && rule.getMinSpendAmount().compareTo(BigDecimal.ZERO) > 0) {
                    return Math.min(100, progress.getCurrentSpendAmount()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(rule.getMinSpendAmount(), 0, RoundingMode.DOWN)
                        .intValue());
                }
                break;
            case "COMBO":
                // Average of both criteria
                int walletProgress = 0;
                int orderProgress = 0;
                
                if (rule.getMinWalletBalance() != null && rule.getMinWalletBalance().compareTo(BigDecimal.ZERO) > 0) {
                    walletProgress = Math.min(100, progress.getCurrentWalletBalance()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(rule.getMinWalletBalance(), 0, RoundingMode.DOWN)
                        .intValue());
                }
                
                if (rule.getMinOrderCount() != null && rule.getMinOrderCount() > 0) {
                    orderProgress = Math.min(100, (progress.getCurrentOrderCount() * 100) / rule.getMinOrderCount());
                }
                
                return (walletProgress + orderProgress) / 2;
        }
        
        return 0;
    }
    
    /**
     * Generate progress text
     */
    private String generateProgressText(RewardRule rule, UserRewardProgress progress) {
        switch (rule.getRuleType()) {
            case "WALLET_BALANCE":
                return String.format("₹%s / ₹%s maintained", 
                    progress.getCurrentWalletBalance().intValue(),
                    rule.getMinWalletBalance().intValue());
            case "ORDER_COUNT":
                return String.format("%d / %d orders completed", 
                    progress.getCurrentOrderCount(),
                    rule.getMinOrderCount());
            case "SPEND_AMOUNT":
                return String.format("₹%s / ₹%s spent", 
                    progress.getCurrentSpendAmount().intValue(),
                    rule.getMinSpendAmount().intValue());
            case "COMBO":
                return String.format("%d orders, ₹%s balance", 
                    progress.getCurrentOrderCount(),
                    progress.getCurrentWalletBalance().intValue());
        }
        
        return "In progress";
    }
    
    /**
     * Get unlocked rewards for user
     */
    public List<UserRewardDTO> getUnlockedRewards(Long userId) {
        List<UserReward> rewards = userRewardRepository.findActiveRewardsByUserId(userId, LocalDateTime.now());
        
        return rewards.stream().map(reward -> {
            UserRewardDTO dto = new UserRewardDTO();
            dto.setId(reward.getId());
            dto.setTitle(reward.getRewardRule() != null ? reward.getRewardRule().getTitle() : "Reward");
            dto.setRewardType(reward.getRewardType());
            dto.setRewardAmount(reward.getRewardAmount());
            dto.setCouponCode(reward.getCouponCode());
            dto.setStatus(reward.getStatus());
            dto.setUnlockedAt(reward.getUnlockedAt());
            dto.setExpiresAt(reward.getExpiresAt());
            dto.setNotes(reward.getNotes());
            return dto;
        }).collect(Collectors.toList());
    }
    
    /**
     * Claim a reward
     */
    @Transactional
    public void claimReward(Long userId, Long rewardId) {
        UserReward reward = userRewardRepository.findById(rewardId)
            .orElseThrow(() -> new RuntimeException("Reward not found"));
        
        if (!reward.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized");
        }
        
        if (!"UNLOCKED".equals(reward.getStatus())) {
            throw new RuntimeException("Reward already claimed or expired");
        }
        
        reward.setStatus("CLAIMED");
        reward.setClaimedAt(LocalDateTime.now());
        userRewardRepository.save(reward);
        
        log.info("Reward claimed: userId={}, rewardId={}", userId, rewardId);
    }
}
