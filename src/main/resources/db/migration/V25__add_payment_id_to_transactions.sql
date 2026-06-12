-- Migration: Add payment_id column to payment_transactions table
-- This stores the Razorpay Payment ID (pay_XXXXX) which is required for refunds
-- The transaction_id field stores the Razorpay Order ID (order_XXXXX)

ALTER TABLE payment_transactions
ADD COLUMN payment_id VARCHAR(255) UNIQUE;

-- Add index for faster lookups
CREATE INDEX idx_payment_transactions_payment_id ON payment_transactions(payment_id);

-- Add comment to clarify the difference
COMMENT ON COLUMN payment_transactions.transaction_id IS 'Razorpay Order ID (order_XXXXX) - created during payment initiation';
COMMENT ON COLUMN payment_transactions.payment_id IS 'Razorpay Payment ID (pay_XXXXX) - set after successful payment completion, required for refunds';