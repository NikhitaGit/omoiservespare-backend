import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { getUserRewards, claimReward } from "../api/rewardsApi";
import "../styles/rewards.css";

const Rewards = () => {
  const navigate = useNavigate();
  const [rewards, setRewards] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [claiming, setClaiming] = useState(null);

  // Fetch rewards from backend
  useEffect(() => {
    const fetchRewards = async () => {
      setLoading(true);
      setError(null);
      
      try {
        const data = await getUserRewards();
        setRewards(data.rewards || []);
        console.log('✅ Rewards loaded:', data);
      } catch (err) {
        console.error('❌ Failed to load rewards:', err);
        setError('Failed to load rewards. Please try again.');
        
        if (err.response?.status === 401) {
          setError('Please login to view rewards.');
        }
      } finally {
        setLoading(false);
      }
    };
    
    fetchRewards();
  }, []);

  // Handle claim reward
  const handleClaim = async (rewardId) => {
    setClaiming(rewardId);
    
    try {
      const result = await claimReward(rewardId);
      console.log('✅ Reward claimed:', result);
      
      // Refresh rewards list
      const data = await getUserRewards();
      setRewards(data.rewards || []);
      
      alert('Reward claimed successfully! Amount added to your wallet.');
    } catch (err) {
      console.error('❌ Failed to claim reward:', err);
      alert(err.response?.data?.message || 'Failed to claim reward');
    } finally {
      setClaiming(null);
    }
  };

  // Loading state
  if (loading) {
    return (
      <div className="rewards-page">
        <header className="rewards-header">
          <h1>Wallet Rewards</h1>
        </header>
        <div style={{ textAlign: 'center', padding: '50px' }}>
          <h2>Loading rewards...</h2>
        </div>
      </div>
    );
  }

  // Error state
  if (error) {
    return (
      <div className="rewards-page">
        <header className="rewards-header">
          <h1>Wallet Rewards</h1>
        </header>
        <div style={{ textAlign: 'center', padding: '50px', color: 'red' }}>
          <h2>Error</h2>
          <p>{error}</p>
          <button onClick={() => window.location.reload()}>Retry</button>
        </div>
      </div>
    );
  }

  return (
    <div className="rewards-page">
      <header className="rewards-header">
        <h1>Wallet Rewards</h1>
        <p style={{ fontSize: '14px', opacity: 0.8, marginTop: '8px' }}>
          {rewards.filter(r => r.isUnlocked).length} of {rewards.length} rewards unlocked
        </p>
      </header>
      
      <div className="rewards-grid">
        {rewards.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '50px', gridColumn: '1 / -1' }}>
            <h2>No rewards available</h2>
            <p>Start placing orders to unlock rewards!</p>
          </div>
        ) : (
          rewards.map((reward) => (
            <div 
              className={`reward-card ${reward.isUnlocked ? 'unlocked' : 'locked'}`} 
              key={reward.ruleId}
            >
              {/* Status badge */}
              {reward.isUnlocked ? (
                <span className="reward-tag unlocked">✓ Unlocked</span>
              ) : (
                <span className="reward-tag locked">🔒 Locked</span>
              )}
              
              <h2>{reward.name}</h2>
              
              <div className="reward-highlight">
                ₹{reward.rewardAmount} Cashback
              </div>
              
              <p className="reward-desc">{reward.description}</p>
              
              {/* Progress bar */}
              {!reward.isUnlocked && (
                <div style={{ marginTop: '12px' }}>
                  <div style={{ 
                    display: 'flex', 
                    justifyContent: 'space-between', 
                    fontSize: '12px',
                    marginBottom: '4px'
                  }}>
                    <span>Progress</span>
                    <span>{reward.currentProgress} / {reward.targetValue}</span>
                  </div>
                  <div style={{
                    width: '100%',
                    height: '8px',
                    background: 'rgba(0,0,0,0.1)',
                    borderRadius: '4px',
                    overflow: 'hidden'
                  }}>
                    <div style={{
                      width: `${reward.progressPercent}%`,
                      height: '100%',
                      background: 'linear-gradient(90deg, #4ade80, #22c55e)',
                      transition: 'width 0.3s ease'
                    }} />
                  </div>
                </div>
              )}
              
              {/* Action button */}
              {reward.isUnlocked ? (
                reward.isClaimed ? (
                  <button className="reward-btn claimed" disabled>
                    ✓ Claimed
                  </button>
                ) : (
                  <button 
                    className="reward-btn"
                    onClick={() => handleClaim(reward.ruleId)}
                    disabled={claiming === reward.ruleId}
                  >
                    {claiming === reward.ruleId ? 'Claiming...' : 'Claim Reward'}
                  </button>
                )
              ) : (
                <button 
                  className="reward-btn locked" 
                  onClick={() => navigate("/wallet")}
                >
                  Use Wallet
                </button>
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Rewards;
