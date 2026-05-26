-- ============================================
-- PAYMENT TRANSACTIONS TABLE
-- ============================================
CREATE TABLE payment_transactions (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    transaction_id VARCHAR(255) UNIQUE,
    gateway_name VARCHAR(50) NOT NULL,
    payment_method VARCHAR(100),
    amount NUMERIC(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    status VARCHAR(50) NOT NULL,
    three_d_secure_status VARCHAR(50),
    three_d_secure_eci VARCHAR(10),
    three_d_secure_cavv VARCHAR(255),
    gateway_response JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- ============================================
-- REFUND TRANSACTIONS TABLE
-- ============================================
CREATE TABLE refund_transactions (
    id BIGSERIAL PRIMARY KEY,
    payment_transaction_id BIGINT NOT NULL,
    canteen_order_id BIGINT NOT NULL,
    refund_amount NUMERIC(12,2) NOT NULL,
    refund_id VARCHAR(255) UNIQUE,
    status VARCHAR(50) NOT NULL,
    reason VARCHAR(500),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_refund_payment FOREIGN KEY (payment_transaction_id) REFERENCES payment_transactions(id),
    CONSTRAINT fk_refund_canteen_order FOREIGN KEY (canteen_order_id) REFERENCES canteen_orders(id)
);

-- ============================================
-- SAVED PAYMENT METHODS (Tokenization)
-- ============================================
CREATE TABLE saved_payment_methods (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    method_type VARCHAR(50) NOT NULL,
    token VARCHAR(500),
    last_four VARCHAR(4),
    expiry_date VARCHAR(10),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP,
    CONSTRAINT fk_saved_payment_customer FOREIGN KEY (customer_id) REFERENCES users(id)
);

-- ============================================
-- FRAUD DETECTION LOGS
-- ============================================
CREATE TABLE fraud_detection_logs (
    id BIGSERIAL PRIMARY KEY,
    payment_transaction_id BIGINT,
    risk_score NUMERIC(5,2),
    risk_level VARCHAR(50),
    fraud_indicators JSONB,
    action_taken VARCHAR(100),
    created_at TIMESTAMP,
    CONSTRAINT fk_fraud_payment FOREIGN KEY (payment_transaction_id) REFERENCES payment_transactions(id)
);

-- ============================================
-- WEBHOOK LOGS (For debugging & reconciliation)
-- ============================================
CREATE TABLE payment_webhook_logs (
    id BIGSERIAL PRIMARY KEY,
    gateway_name VARCHAR(50),
    event_type VARCHAR(100),
    transaction_id VARCHAR(255),
    payload JSONB,
    signature VARCHAR(500),
    signature_valid BOOLEAN,
    processed BOOLEAN DEFAULT FALSE,
    error_message VARCHAR(500),
    created_at TIMESTAMP
);

-- ============================================
-- DEVICE FINGERPRINTS (For fraud detection)
-- ============================================
CREATE TABLE device_fingerprints (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    is_trusted BOOLEAN DEFAULT FALSE,
    last_used TIMESTAMP,
    created_at TIMESTAMP,
    CONSTRAINT fk_device_customer FOREIGN KEY (customer_id) REFERENCES users(id)
);

-- ============================================
-- PAYMENT VELOCITY TRACKING (Fraud detection)
-- ============================================
CREATE TABLE payment_velocity (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    payment_count_1h INTEGER DEFAULT 0,
    payment_count_24h INTEGER DEFAULT 0,
    total_amount_1h NUMERIC(12,2) DEFAULT 0,
    total_amount_24h NUMERIC(12,2) DEFAULT 0,
    last_payment_time TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_velocity_customer FOREIGN KEY (customer_id) REFERENCES users(id)
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_payment_order_id ON payment_transactions(order_id);
CREATE INDEX idx_payment_transaction_id ON payment_transactions(transaction_id);
CREATE INDEX idx_payment_status ON payment_transactions(status);
CREATE INDEX idx_fraud_risk_level ON fraud_detection_logs(risk_level);
CREATE INDEX idx_webhook_transaction_id ON payment_webhook_logs(transaction_id);
CREATE INDEX idx_device_customer_id ON device_fingerprints(customer_id);
CREATE INDEX idx_velocity_customer_id ON payment_velocity(customer_id);