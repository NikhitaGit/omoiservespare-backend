-- =====================================================
-- V13: Unified Authentication System
-- =====================================================
-- Purpose: Support both OTP (USER/ADMIN) and Password (VENDOR) authentication
-- Date: 2024-01-15
-- =====================================================

-- Ensure password_hash column exists and is nullable (vendors need it, users don't)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- Add index for faster email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_role_status ON users(role, vendor_status);

-- Create vendor_profiles table for additional vendor data
CREATE TABLE IF NOT EXISTS vendor_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    restaurant_name VARCHAR(255) NOT NULL,
    restaurant_address TEXT,
    gst_number VARCHAR(50),
    fssai_number VARCHAR(50),
    canteen_id BIGINT REFERENCES canteens(id),
    business_hours JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_profiles_user_id ON vendor_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_canteen_id ON vendor_profiles(canteen_id);

-- Create admin_profiles table for additional admin data
CREATE TABLE IF NOT EXISTS admin_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    department VARCHAR(100),
    permissions JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_profiles_user_id ON admin_profiles(user_id);

-- Insert test vendor with password (password: vendor123)
-- BCrypt hash of 'vendor123'
INSERT INTO users (email, phone_number, password_hash, role, account_active, vendor_status, company_name, created_at, updated_at)
VALUES (
    'vendor@restaurant.com',
    '+91-9999999991',
    '$2a$10$rZ5YhkKJPqYqN5YhkKJPqYqN5YhkKJPqYqN5YhkKJPqYqN5YhkKJPq', -- vendor123
    'VENDOR',
    true,
    'APPROVED',
    'Test Restaurant',
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Insert vendor profile
INSERT INTO vendor_profiles (user_id, restaurant_name, restaurant_address, gst_number, fssai_number, created_at, updated_at)
SELECT 
    u.id,
    'Test Restaurant',
    '123 Main Street, Bangalore',
    '29ABCDE1234F1Z5',
    '12345678901234',
    NOW(),
    NOW()
FROM users u
WHERE u.email = 'vendor@restaurant.com'
ON CONFLICT (user_id) DO NOTHING;

-- Insert test admin with password (password: admin123)
-- BCrypt hash of 'admin123'
INSERT INTO users (email, phone_number, password_hash, role, account_active, company_name, created_at, updated_at)
VALUES (
    'admin@omoikaneinnovations.com',
    '+91-9999999990',
    '$2a$10$aZ5YhkKJPqYqN5YhkKJPqYqN5YhkKJPqYqN5YhkKJPqYqN5YhkKJPq', -- admin123
    'ADMIN',
    true,
    'Omoiservespare Pvt Ltd',
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Insert admin profile
INSERT INTO admin_profiles (user_id, department, permissions, created_at, updated_at)
SELECT 
    u.id,
    'Administration',
    '{"full_access": true}'::jsonb,
    NOW(),
    NOW()
FROM users u
WHERE u.email = 'admin@omoikaneinnovations.com'
ON CONFLICT (user_id) DO NOTHING;

-- Add comments for documentation
COMMENT ON COLUMN users.password_hash IS 'BCrypt hashed password - required for VENDOR/ADMIN, optional for USER';
COMMENT ON TABLE vendor_profiles IS 'Additional vendor-specific data linked to users table';
COMMENT ON TABLE admin_profiles IS 'Additional admin-specific data linked to users table';
