-- ===============================
-- 📍 USER ADDRESSES TABLE
-- Swiggy/Zomato-like location management
-- ===============================

CREATE TABLE IF NOT EXISTS user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    phone_number VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_user_addresses_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_user_addresses_default ON user_addresses(user_id, is_default);
CREATE INDEX idx_user_addresses_location ON user_addresses(latitude, longitude);

-- Comments
COMMENT ON TABLE user_addresses IS 'Stores user delivery addresses with geolocation data';
COMMENT ON COLUMN user_addresses.title IS 'Address label: Home, Work, Other';
COMMENT ON COLUMN user_addresses.latitude IS 'GPS latitude coordinate';
COMMENT ON COLUMN user_addresses.longitude IS 'GPS longitude coordinate';
COMMENT ON COLUMN user_addresses.is_default IS 'Default delivery address flag';
