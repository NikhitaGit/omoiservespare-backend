package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.UserReward;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface UserRewardRepository extends JpaRepository<UserReward, Long> {
    
    List<UserReward> findByUserIdAndStatusOrderByUnlockedAtDesc(Long userId, String status);
    
    List<UserReward> findByUserIdOrderByUnlockedAtDesc(Long userId);
    
    @Query("SELECT ur FROM UserReward ur WHERE ur.userId = :userId AND ur.status = 'UNLOCKED' AND ur.expiresAt > :now")
    List<UserReward> findActiveRewardsByUserId(@Param("userId") Long userId, @Param("now") LocalDateTime now);
    
    @Query("SELECT COUNT(ur) FROM UserReward ur WHERE ur.userId = :userId AND ur.rewardRuleId = :ruleId AND ur.unlockedAt >= :startDate")
    Long countRewardsUnlockedInPeriod(@Param("userId") Long userId, @Param("ruleId") Long ruleId, @Param("startDate") LocalDateTime startDate);
}
