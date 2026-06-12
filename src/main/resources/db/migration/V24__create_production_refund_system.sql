-- ============================================
-- PRODUCTION-GRADE REFUND SYSTEM (PostgreSQL)
-- ============================================

-- Drop existing refund_transactions table if exists
DROP TABLE IF EXISTS refund_transactions CASCADE;

-- Create refund_transactions table with production-grade fields
CREATE TABLE refund_transactions (
    id BIGSERIAL PRIMARY KEY,
    
    -- Identifiers
    refund_id VARCHAR(100) UNIQUE NOT NULL,
    internal_refund_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Relationships
    payment_transaction_id BIGINT NOT NULL,
    canteen_order_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    
    -- Amounts (in rupees, 2 decimal precision)
    original_amount DECIMAL(10, 2) NOT NULL,
    refund_amount DECIMAL(10, 2) NOT NULL,
    cgst_amount DECIMAL(10, 2) DEFAULT 0.00,
    sgst_amount DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Status tracking
    status VARCHAR(50) NOT NULL,
    razorpay_status VARCHAR(50),
    
    -- Cancellation workflow
    cancellation_requested_by VARCHAR(50),
    cancellation_reason TEXT,
    vendor_approval_status VARCHAR(50) DEFAULT 'PENDING',
    vendor_approval_at TIMESTAMP,
    vendor_id BIGINT,
    vendor_remarks TEXT,
    
    -- Refund processing
    refund_initiated_at TIMESTAMP,
    refund_processed_at TIMESTAMP,
    refund_failed_at TIMESTAMP,
    
    -- Gateway details
    gateway_name VARCHAR(50) DEFAULT 'razorpay',
    gateway_response TEXT,
    gateway_error_code VARCHAR(100),
    gateway_error_message TEXT,
    
    -- Refund method
    refund_method VARCHAR(50),
    refund_mode VARCHAR(50) DEFAULT 'AUTO',
    
    -- Settlement tracking
    settlement_status VARCHAR(50) DEFAULT 'PENDING',
    settlement_date TIMESTAMP,
    settlement_utr VARCHAR(100),
    
    -- Retry mechanism
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    next_retry_at TIMESTAMP,
    
    -- Idempotency
    idempotency_key VARCHAR(100) UNIQUE,
    
    -- Audit trail
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    
    -- Metadata
    metadata JSONB,
    notes TEXT,
    
    -- Foreign keys
    CONSTRAINT fk_refund_payment FOREIGN KEY (payment_transaction_id) 
        REFERENCES payment_transactions(id) ON DELETE RESTRICT,
    CONSTRAINT fk_refund_canteen_order FOREIGN KEY (canteen_order_id) 
        REFERENCES canteen_orders(id) ON DELETE RESTRICT,
    CONSTRAINT fk_refund_order FOREIGN KEY (order_id) 
        REFERENCES orders(id) ON DELETE RESTRICT,
    CONSTRAINT fk_refund_customer FOREIGN KEY (customer_id) 
        REFERENCES users(id) ON DELETE RESTRICT
);

-- Indexes for performance
CREATE INDEX idx_refund_id ON refund_transactions(refund_id);
CREATE INDEX idx_internal_code ON refund_transactions(internal_refund_code);
CREATE INDEX idx_payment_transaction ON refund_transactions(payment_transaction_id);
CREATE INDEX idx_canteen_order ON refund_transactions(canteen_order_id);
CREATE INDEX idx_order ON refund_transactions(order_id);
CREATE INDEX idx_customer ON refund_transactions(customer_id);
CREATE INDEX idx_status ON refund_transactions(status);
CREATE INDEX idx_vendor_approval ON refund_transactions(vendor_approval_status);
CREATE INDEX idx_created_at ON refund_transactions(created_at);
CREATE INDEX idx_idempotency ON refund_transactions(idempotency_key);

-- Comments for documentation
COMMENT ON TABLE refund_transactions IS 'Production-grade refund transaction tracking';
COMMENT ON COLUMN refund_transactions.refund_id IS 'Razorpay refund ID';
COMMENT ON COLUMN refund_transactions.internal_refund_code IS 'Internal tracking code';
COMMENT ON COLUMN refund_transactions.order_id IS 'Parent order for quick lookup';
COMMENT ON COLUMN refund_transactions.customer_id IS 'Customer for quick lookup';

-- ============================================
-- REFUND AUDIT LOG TABLE
-- ============================================
DROP TABLE IF EXISTS refund_audit_logs CASCADE;

CREATE TABLE refund_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    refund_transaction_id BIGINT NOT NULL,
    
    -- Event details
    event_type VARCHAR(50) NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    
    -- Actor details
    actor_type VARCHAR(50),
    actor_id BIGINT,
    actor_email VARCHAR(255),
    
    -- Change details
    changes JSONB,
    remarks TEXT,
    
    -- Request details
    ip_address VARCHAR(50),
    user_agent TEXT,
    
    -- Timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_audit_refund FOREIGN KEY (refund_transaction_id) 
        REFERENCES refund_transactions(id) ON DELETE CASCADE
);

CREATE INDEX idx_refund_transaction ON refund_audit_logs(refund_transaction_id);
CREATE INDEX idx_event_type ON refund_audit_logs(event_type);
CREATE INDEX idx_created_at_audit ON refund_audit_logs(created_at);

-- ============================================
-- REFUND WEBHOOK EVENTS TABLE
-- ============================================
DROP TABLE IF EXISTS refund_webhook_events CASCADE;

CREATE TABLE refund_webhook_events (
    id BIGSERIAL PRIMARY KEY,
    
    -- Webhook details
    event_id VARCHAR(100) UNIQUE NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    
    -- Refund reference
    refund_id VARCHAR(100),
    refund_transaction_id BIGINT,
    
    -- Payload
    payload JSONB NOT NULL,
    signature VARCHAR(500),
    
    -- Processing status
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP,
    processing_error TEXT,
    
    -- Retry
    retry_count INT DEFAULT 0,
    
    -- Timestamp
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_event_id ON refund_webhook_events(event_id);
CREATE INDEX idx_refund_id_webhook ON refund_webhook_events(refund_id);
CREATE INDEX idx_processed ON refund_webhook_events(processed);
CREATE INDEX idx_received_at ON refund_webhook_events(received_at);

-- ============================================
-- ADD REFUND TRACKING TO CANTEEN_ORDERS
-- ============================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='canteen_orders' AND column_name='refund_status') THEN
        ALTER TABLE canteen_orders 
        ADD COLUMN refund_status VARCHAR(50) DEFAULT 'NOT_APPLICABLE';
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='canteen_orders' AND column_name='refund_requested_at') THEN
        ALTER TABLE canteen_orders 
        ADD COLUMN refund_requested_at TIMESTAMP;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='canteen_orders' AND column_name='refund_completed_at') THEN
        ALTER TABLE canteen_orders 
        ADD COLUMN refund_completed_at TIMESTAMP;
    END IF;
END $$;

-- ============================================
-- CREATE REFUND SEQUENCE TABLE
-- ============================================
DROP TABLE IF EXISTS refund_sequence CASCADE;

CREATE TABLE refund_sequence (
    id VARCHAR(50) PRIMARY KEY,
    sequence_value BIGINT NOT NULL DEFAULT 0
);

-- Initialize refund sequence
INSERT INTO refund_sequence (id, sequence_value) 
VALUES ('REFUND', 0);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_canteen_orders_refund_status') THEN
        CREATE INDEX idx_canteen_orders_refund_status ON canteen_orders(refund_status);
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_canteen_orders_refund_requested') THEN
        CREATE INDEX idx_canteen_orders_refund_requested ON canteen_orders(refund_requested_at);
    END IF;
END $$;

-- ============================================
-- TRIGGER FOR UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION update_refund_transactions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_refund_transactions_updated_at
    BEFORE UPDATE ON refund_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_refund_transactions_updated_at();