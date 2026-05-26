-- =====================================================
-- V11: Add Password Authentication
-- =====================================================
-- Adds password_hash column for unified authentication
-- Supports password-based login for all roles

-- Add password_hash column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email_active 
ON users(email, account_active);

-- Add comment
COMMENT ON COLUMN users.password_hash IS 'BCrypt hashed password for authentication';
