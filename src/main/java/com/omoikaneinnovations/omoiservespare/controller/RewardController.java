package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.RewardDTO;
import com.omoikaneinnovations.omoiservespare.dto.UserRewardDTO;
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.security.JwtUtil;
import com.omoikaneinnovations.omoiservespare.security.RequireRole;
import com.omoikaneinnovations.omoiservespare.service.RewardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Rewards System REST API
 * 🎁 Like Swiggy/Zomato rewards
 * 🔒 USER ONLY endpoints
 */
@RestController
@RequestMapping("/api/rewards")
@RequiredArgsConstructor
@Slf4j
public class RewardController {
    
    private final RewardService rewardService;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    
    /**
     * Get all rewards for user (for rewards page)
     * Shows progress, unlocked rewards, and available rewards
     * 🔒 USER ONLY
     */
    @GetMapping
    @RequireRole(Role.USER)
    public ResponseEntity<Map<String, Object>> getUserRewards(
            @RequestHeader("Authorization") String token) {
        
        String email = jwtUtil.extractEmail(token.replace("Bearer ", ""));
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        log.info("Fetching rewards for user: {}", user.getId());
        
        List<RewardDTO> rewards = rewardService.getUserRewards(user.getId());
        
        Map<String, Object> response = new HashMap<>();
        response.put("rewards", rewards);
        response.put("totalRewards", rewards.size());
        response.put("unlockedCount", rewards.stream().filter(RewardDTO::getIsUnlocked).count());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get unlocked rewards only
     * 🔒 USER ONLY
     */
    @GetMapping("/unlocked")
    @RequireRole(Role.USER)
    public ResponseEntity<List<UserRewardDTO>> getUnlockedRewards(
            @RequestHeader("Authorization") String token) {
        
        String email = jwtUtil.extractEmail(token.replace("Bearer ", ""));
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        log.info("Fetching unlocked rewards for user: {}", user.getId());
        
        List<UserRewardDTO> rewards = rewardService.getUnlockedRewards(user.getId());
        
        return ResponseEntity.ok(rewards);
    }
    
    /**
     * Claim a reward
     * 🔒 USER ONLY
     */
    @PostMapping("/{rewardId}/claim")
    @RequireRole(Role.USER)
    public ResponseEntity<Map<String, String>> claimReward(
            @PathVariable Long rewardId,
            @RequestHeader("Authorization") String token) {
        
        String email = jwtUtil.extractEmail(token.replace("Bearer ", ""));
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        log.info("User {} claiming reward: {}", user.getId(), rewardId);
        
        try {
            rewardService.claimReward(user.getId(), rewardId);
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "Reward claimed successfully!");
            response.put("status", "success");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error claiming reward: {}", e.getMessage());
            
            Map<String, String> response = new HashMap<>();
            response.put("message", e.getMessage());
            response.put("status", "error");
            
            return ResponseEntity.badRequest().body(response);
        }
    }
}
