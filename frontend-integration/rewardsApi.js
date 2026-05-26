import api from "./axiosInstance";

/**
 * Rewards API
 * Connects to Spring Boot backend
 */

/**
 * Get all rewards for current user
 * Shows progress, unlocked rewards, and available rewards
 * @returns {Promise} Rewards data
 */
export const getUserRewards = async () => {
  const res = await api.get("/api/rewards");
  return res.data;
};

/**
 * Get only unlocked rewards
 * @returns {Promise} Array of unlocked rewards
 */
export const getUnlockedRewards = async () => {
  const res = await api.get("/api/rewards/unlocked");
  return res.data;
};

/**
 * Claim a reward
 * @param {number} rewardId - Reward ID to claim
 * @returns {Promise} Claim result
 */
export const claimReward = async (rewardId) => {
  const res = await api.post(`/api/rewards/${rewardId}/claim`);
  return res.data;
};
