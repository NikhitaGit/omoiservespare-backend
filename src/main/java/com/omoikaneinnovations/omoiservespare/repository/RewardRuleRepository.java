package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.RewardRule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RewardRuleRepository extends JpaRepository<RewardRule, Long> {
    
    List<RewardRule> findByIsActiveTrueOrderByPriorityAsc();
    
    List<RewardRule> findByIsActiveTrueAndRuleTypeOrderByPriorityAsc(String ruleType);
}
