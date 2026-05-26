package com.omoikaneinnovations.omoiservespare.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRewardDTO {
    private Long id;
    private String title;
    private String rewardType;
    private BigDecimal rewardAmount;
    private String couponCode;
    private String status;
    private LocalDateTime unlockedAt;
    private LocalDateTime expiresAt;
    private String notes;
}
