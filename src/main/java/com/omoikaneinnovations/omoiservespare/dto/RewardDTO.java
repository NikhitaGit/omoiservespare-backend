package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RewardDTO {
    private Long id;
    private String title;
    private String highlight;
    private String description;
    private String subText;
    private String tag;
    private String ruleType;
    
    // Progress
    private Integer progressPercentage;
    private String progressText;
    private Boolean isUnlocked;
    private Boolean isCompleted;
    
    // Criteria
    private BigDecimal minWalletBalance;
    private Integer minOrderCount;
    private BigDecimal minSpendAmount;
    
    // Current Progress
    private BigDecimal currentWalletBalance;
    private Integer currentOrderCount;
    private BigDecimal currentSpendAmount;
    
    // Reward Details
    private String rewardType;
    private BigDecimal rewardAmount;
    private BigDecimal rewardPercentage;
    private String couponCode;
    
    // Unlocked Reward
    private Long userRewardId;
    private String rewardStatus;
}
