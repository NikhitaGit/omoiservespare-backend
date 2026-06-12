-- Migration: Fix refund_id to be nullable
-- Reason: refund_id is only set AFTER Razorpay processes the refund
--         It should be NULL during initial refund request creation

-- Make refund_id column nullable
ALTER TABLE refund_transactions 
ALTER COLUMN refund_id DROP NOT NULL;

-- Add comment to column for documentation
COMMENT ON COLUMN refund_transactions.refund_id IS 'Razorpay refund ID - set after refund is processed, NULL before processing';