-- V10: Add Role-Based Access Control (RBAC) System
-- Adds role and vendor_status columns for production-grade security

-- Step 1: Add role column to users table
ALTER TABLE users 
ADD COLUMN role VARCHAR(20) DEFAULT 'USER';

-- Step 2: Add vendor_status column for vendor management
ALTER TABLE users 
ADD COLUMN vendor_status VARCHAR(20) DEFAULT NULL;

-- Step 3: Add account_active flag
ALTER TABLE users 
ADD COLUMN account_active BOOLEAN DEFAULT TRUE;

-- Step 4: Add created_at and updated_at timestamps
ALTER TABLE users 
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Step 5: Create index on role for faster queries
CREATE INDEX idx_users_role ON users(role);

-- Step 6: Create index on vendor_status
CREATE INDEX idx_users_vendor_status ON users(vendor_status);

-- Step 7: Update existing users (set appropriate roles)
-- All existing users become regular users by default
UPDATE users SET role = 'USER' WHERE role IS NULL;

-- Step 8: Create admin user (change email/password as needed)
-- Note: You should create admin through your application with proper password hashing
-- This is just a placeholder
INSERT INTO users (company_name, email, role, account_active, created_at, updated_at)
VALUES ('System Admin', 'admin@omoiservespare.com', 'ADMIN', TRUE, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

-- Step 9: Add constraint to ensure role is valid
ALTER TABLE users 
ADD CONSTRAINT chk_role CHECK (role IN ('USER', 'VENDOR', 'ADMIN'));

-- Step 10: Add constraint for vendor_status
ALTER TABLE users 
ADD CONSTRAINT chk_vendor_status CHECK (
    vendor_status IS NULL OR 
    vendor_status IN ('PENDING', 'APPROVED', 'SUSPENDED', 'REJECTED')
);

-- Step 11: Add constraint: only vendors can have vendor_status
-- This ensures data integrity
ALTER TABLE users 
ADD CONSTRAINT chk_vendor_status_role CHECK (
    (role = 'VENDOR' AND vendor_status IS NOT NULL) OR
    (role != 'VENDOR' AND vendor_status IS NULL)
);

-- Done! RBAC system is now ready
