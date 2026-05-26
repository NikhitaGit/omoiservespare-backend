-- ============================================
-- FIX ALL REMAINING JSONB COLUMNS
-- ============================================
-- Change all remaining JSONB columns to TEXT to allow direct string insertion
-- This maintains JSON storage capability while being compatible with Hibernate String mapping

-- Fix payload column in payment_webhook_logs
ALTER TABLE payment_webhook_logs 
ALTER COLUMN payload TYPE TEXT;

-- Add comment for clarity
COMMENT ON COLUMN payment_webhook_logs.payload IS 'JSON string containing webhook payload data';