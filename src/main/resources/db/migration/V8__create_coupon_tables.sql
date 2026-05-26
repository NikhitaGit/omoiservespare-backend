-- Coupon System Tables
-- V7__create_coupon_tables.sql

-- Main Coupons Table
CREATE TABLE coupons (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('PERCENTAGE', 'FLAT', 'CASHBACK')),
    discount_value DECIMAL(10,2) NOT NULL,
    max_discount DECIMAL(10,2),
    min_order_value DECIMAL(10,2) DEFAULT 0,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    total_usage_limit INTEGER,
    per_user_limit INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    applicable_on VARCHAR(50) DEFAULT 'ALL' CHECK (applicable_on IN ('ALL', 'FIRST_ORDER', 'SPECIFIC_RESTAURANTS', 'SPECIFIC_CATEGORIES')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Coupon Usage Tracking
CREATE TABLE coupon_usage (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id BIGINT,
    discount_applied DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_coupon FOREIGN KEY (coupon_id) REFERENCES coupons(id),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Restaurant-Specific Coupons
CREATE TABLE coupon_restaurants (
    coupon_id BIGINT NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    restaurant_id BIGINT NOT NULL REFERENCES canteens(id) ON DELETE CASCADE,
    PRIMARY KEY (coupon_id, restaurant_id)
);

-- User-Specific Coupons (Targeted Marketing)
CREATE TABLE user_coupons (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    coupon_id BIGINT NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_used BOOLEAN DEFAULT false,
    UNIQUE(user_id, coupon_id)
);

-- Indexes for Performance
CREATE INDEX idx_coupon_code ON coupons(code);
CREATE INDEX idx_coupon_active ON coupons(is_active, start_date, end_date);
CREATE INDEX idx_coupon_usage_user ON coupon_usage(user_id, coupon_id);
CREATE INDEX idx_coupon_usage_coupon ON coupon_usage(coupon_id);
CREATE INDEX idx_user_coupons_user ON user_coupons(user_id);

-- Insert Sample Coupons
INSERT INTO coupons (code, description, discount_type, discount_value, max_discount, min_order_value, start_date, end_date, total_usage_limit, per_user_limit, is_active, applicable_on)
VALUES 
('WELCOME200', 'Flat ₹200 OFF on orders above ₹999', 'FLAT', 200.00, NULL, 999.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 1000, 1, true, 'FIRST_ORDER'),
('SAVE50', 'Get 50% OFF up to ₹150', 'PERCENTAGE', 50.00, 150.00, 500.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '60 days', 5000, 3, true, 'ALL'),
('FLAT100', 'Flat ₹100 OFF on orders above ₹499', 'FLAT', 100.00, NULL, 499.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '45 days', 2000, 2, true, 'ALL'),
('CASHBACK20', 'Get 20% Cashback up to ₹100', 'CASHBACK', 20.00, 100.00, 300.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '90 days', NULL, 5, true, 'ALL'),
('MEGA30', 'Get 30% OFF up to ₹200', 'PERCENTAGE', 30.00, 200.00, 600.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '15 days', 500, 1, true, 'ALL');
