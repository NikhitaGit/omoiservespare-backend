-- ============================================
-- FIX GATEWAY_RESPONSE COLUMN TYPE
-- ============================================
-- Change gateway_response from JSONB to TEXT to allow direct string insertion
-- This maintains JSON storage capability while being compatible with Hibernate String mapping

ALTER TABLE payment_transactions 
ALTER COLUMN gateway_response TYPE TEXT;

-- Add comment for clarity
COMMENT ON COLUMN payment_transactions.gateway_response IS 'JSON string containing full gateway response data';

-- ============================================
-- FIX FRAUD_INDICATORS COLUMN TYPE
-- ============================================
-- Change fraud_indicators from JSONB to TEXT to allow direct string insertion
-- This maintains JSON storage capability while being compatible with Hibernate String mapping

ALTER TABLE fraud_detection_logs 
ALTER COLUMN fraud_indicators TYPE TEXT;

-- Add comment for clarity
COMMENT ON COLUMN fraud_detection_logs.fraud_indicators IS 'JSON string containing fraud detection indicators';