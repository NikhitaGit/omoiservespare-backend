package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "reward_rules")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RewardRule {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "rule_type", nullable = false, length = 50)
    private String ruleType; // WALLET_BALANCE, ORDER_COUNT, SPEND_AMOUNT, COMBO
    
    @Column(nullable = false)
    private String title;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(length = 100)
    private String highlight;
    
    @Column(name = "sub_text")
    private String subText;
    
    @Column(length = 50)
    private String tag;
    
    // Rule Criteria
    @Column(name = "min_wallet_balance", precision = 10, scale = 2)
    private BigDecimal minWalletBalance;
    
    @Column(name = "min_order_count")
    private Integer minOrderCount;
    
    @Column(name = "min_spend_amount", precision = 10, scale = 2)
    private BigDecimal minSpendAmount;
    
    @Column(name = "time_period_days")
    private Integer timePeriodDays = 30;
    
    // Reward Details
    @Column(name = "reward_type", nullable = false, length = 50)
    private String rewardType; // CASHBACK, COUPON, DISCOUNT
    
    @Column(name = "reward_amount", precision = 10, scale = 2)
    private BigDecimal rewardAmount;
    
    @Column(name = "reward_percentage", precision = 5, scale = 2)
    private BigDecimal rewardPercentage;
    
    @Column(name = "max_reward_amount", precision = 10, scale = 2)
    private BigDecimal maxRewardAmount;
    
    @Column(name = "coupon_code", length = 50)
    private String couponCode;
    
    // Status
    @Column(name = "is_active")
    private Boolean isActive = true;
    
    @Column(name = "priority")
    private Integer priority = 0;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
