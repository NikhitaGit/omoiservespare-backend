package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.UserRewardProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRewardProgressRepository extends JpaRepository<UserRewardProgress, Long> {
    
    List<UserRewardProgress> findByUserIdAndIsCompletedFalse(Long userId);
    
    @Query("SELECT urp FROM UserRewardProgress urp WHERE urp.userId = :userId AND urp.rewardRuleId = :ruleId AND urp.periodEndDate >= :now AND urp.isCompleted = false")
    Optional<UserRewardProgress> findActiveProgressForRule(@Param("userId") Long userId, @Param("ruleId") Long ruleId, @Param("now") LocalDateTime now);
    
    @Query("SELECT urp FROM UserRewardProgress urp WHERE urp.periodEndDate < :now AND urp.isCompleted = false")
    List<UserRewardProgress> findExpiredProgress(@Param("now") LocalDateTime now);
}
