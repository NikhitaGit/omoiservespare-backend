package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_reward_progress")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRewardProgress {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Column(name = "reward_rule_id", nullable = false)
    private Long rewardRuleId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reward_rule_id", insertable = false, updatable = false)
    private RewardRule rewardRule;
    
    // Progress Tracking
    @Column(name = "current_wallet_balance", precision = 10, scale = 2)
    private BigDecimal currentWalletBalance = BigDecimal.ZERO;
    
    @Column(name = "current_order_count")
    private Integer currentOrderCount = 0;
    
    @Column(name = "current_spend_amount", precision = 10, scale = 2)
    private BigDecimal currentSpendAmount = BigDecimal.ZERO;
    
    // Period Tracking
    @Column(name = "period_start_date", nullable = false)
    private LocalDateTime periodStartDate;
    
    @Column(name = "period_end_date", nullable = false)
    private LocalDateTime periodEndDate;
    
    // Status
    @Column(name = "is_completed")
    private Boolean isCompleted = false;
    
    @Column(name = "completed_at")
    private LocalDateTime completedAt;
    
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
