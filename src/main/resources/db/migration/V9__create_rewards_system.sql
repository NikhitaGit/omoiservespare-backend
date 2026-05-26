-- ===============================
-- REWARDS SYSTEM TABLES
-- ===============================

-- Reward Rules (Admin-defined reward criteria)
CREATE TABLE reward_rules (
    id BIGSERIAL PRIMARY KEY,
    rule_type VARCHAR(50) NOT NULL, -- WALLET_BALANCE, ORDER_COUNT, SPEND_AMOUNT, COMBO
    title VARCHAR(255) NOT NULL,
    description TEXT,
    highlight VARCHAR(100),
    sub_text VARCHAR(255),
    tag VARCHAR(50),
    
    -- Rule Criteria
    min_wallet_balance DECIMAL(10,2),
    min_order_count INTEGER,
    min_spend_amount DECIMAL(10,2),
    time_period_days INTEGER DEFAULT 30, -- Period to track (e.g., monthly = 30 days)
    
    -- Reward Details
    reward_type VARCHAR(50) NOT NULL, -- CASHBACK, COUPON, DISCOUNT
    reward_amount DECIMAL(10,2),
    reward_percentage DECIMAL(5,2),
    max_reward_amount DECIMAL(10,2),
    coupon_code VARCHAR(50),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 0, -- Higher priority rules checked first
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Reward Progress (Track user progress towards rewards)
CREATE TABLE user_reward_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    reward_rule_id BIGINT NOT NULL REFERENCES reward_rules(id),
    
    -- Progress Tracking
    current_wallet_balance DECIMAL(10,2) DEFAULT 0,
    current_order_count INTEGER DEFAULT 0,
    current_spend_amount DECIMAL(10,2) DEFAULT 0,
    
    -- Period Tracking
    period_start_date TIMESTAMP NOT NULL,
    period_end_date TIMESTAMP NOT NULL,
    
    -- Status
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, reward_rule_id, period_start_date)
);

-- User Rewards (Earned/Unlocked rewards)
CREATE TABLE user_rewards (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    reward_rule_id BIGINT NOT NULL REFERENCES reward_rules(id),
    
    -- Reward Details
    reward_type VARCHAR(50) NOT NULL,
    reward_amount DECIMAL(10,2),
    coupon_code VARCHAR(50),
    
    -- Status
    status VARCHAR(50) DEFAULT 'UNLOCKED', -- UNLOCKED, CLAIMED, EXPIRED, USED
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    claimed_at TIMESTAMP,
    used_at TIMESTAMP,
    expires_at TIMESTAMP,
    
    -- Metadata
    order_id BIGINT, -- Order that triggered the reward
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reward Transactions (Audit trail)
CREATE TABLE reward_transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    reward_rule_id BIGINT REFERENCES reward_rules(id),
    user_reward_id BIGINT REFERENCES user_rewards(id),
    
    transaction_type VARCHAR(50) NOT NULL, -- PROGRESS_UPDATE, REWARD_UNLOCKED, REWARD_CLAIMED, REWARD_USED
    description TEXT,
    
    -- Before/After values for audit
    metadata JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_reward_rules_active ON reward_rules(is_active, priority);
CREATE INDEX idx_user_reward_progress_user ON user_reward_progress(user_id, is_completed);
CREATE INDEX idx_user_reward_progress_period ON user_reward_progress(period_start_date, period_end_date);
CREATE INDEX idx_user_rewards_user_status ON user_rewards(user_id, status);
CREATE INDEX idx_user_rewards_expires ON user_rewards(expires_at) WHERE status = 'UNLOCKED';
CREATE INDEX idx_reward_transactions_user ON reward_transactions(user_id, created_at);

-- Insert default reward rules
INSERT INTO reward_rules (
    rule_type, title, description, highlight, sub_text, tag,
    min_wallet_balance, time_period_days,
    reward_type, reward_amount, is_active, priority
) VALUES 
(
    'WALLET_BALANCE',
    'Guaranteed Monthly Cashback',
    'Maintain a minimum wallet balance of ₹1000 and get guaranteed cashback every month.',
    '₹75 Cashback',
    'Cashback range: ₹50–₹100',
    'Most Popular',
    1000.00,
    30,
    'CASHBACK',
    75.00,
    true,
    1
),
(
    'ORDER_COUNT',
    'Extra Wallet Cashback on Orders',
    'Earn extra cashback every time you pay using wallet balance.',
    '+5% Cashback',
    'Cashback capped per order',
    'Smart Savings',
    NULL,
    30,
    'CASHBACK',
    NULL,
    true,
    2
),
(
    'COMBO',
    'Spend & Maintain Combo',
    'Maintain ₹1000 wallet balance and place 3 orders in a month to unlock bonus cashback.',
    '₹150 Cashback',
    'Perfect for regular office orders',
    'High Value',
    1000.00,
    30,
    'CASHBACK',
    150.00,
    true,
    3
);

-- Set reward percentage for order-based cashback
UPDATE reward_rules 
SET reward_percentage = 5.00, max_reward_amount = 50.00 
WHERE rule_type = 'ORDER_COUNT';

-- Set combo rule criteria
UPDATE reward_rules 
SET min_order_count = 3 
WHERE rule_type = 'COMBO';
