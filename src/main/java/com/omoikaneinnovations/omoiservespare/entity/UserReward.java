package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_rewards")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserReward {
    
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
    
    // Reward Details
    @Column(name = "reward_type", nullable = false, length = 50)
    private String rewardType;
    
    @Column(name = "reward_amount", precision = 10, scale = 2)
    private BigDecimal rewardAmount;
    
    @Column(name = "coupon_code", length = 50)
    private String couponCode;
    
    // Status
    @Column(name = "status", length = 50)
    private String status = "UNLOCKED"; // UNLOCKED, CLAIMED, EXPIRED, USED
    
    @Column(name = "unlocked_at")
    private LocalDateTime unlockedAt;
    
    @Column(name = "claimed_at")
    private LocalDateTime claimedAt;
    
    @Column(name = "used_at")
    private LocalDateTime usedAt;
    
    @Column(name = "expires_at")
    private LocalDateTime expiresAt;
    
    // Metadata
    @Column(name = "order_id")
    private Long orderId;
    
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (unlockedAt == null) {
            unlockedAt = LocalDateTime.now();
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
