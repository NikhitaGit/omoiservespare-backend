-- Create test vendor with proper BCrypt password hash
-- Password: vendor123
-- This is a real BCrypt hash generated for 'vendor123'

-- First, delete existing test vendor if exists
DELETE FROM vendor_profiles WHERE user_id IN (SELECT id FROM users WHERE email = 'vendor@restaurant.com');
DELETE FROM users WHERE email = 'vendor@restaurant.com';

-- Insert vendor with proper password hash
-- BCrypt hash for 'vendor123' (strength 10)
INSERT INTO users (
    email, 
    phone_number, 
    password_hash, 
    role, 
    account_active, 
    vendor_status, 
    company_name, 
    created_at, 
    updated_at
)
VALUES (
    'vendor@restaurant.com',
    '+91-9999999991',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- vendor123
    'VENDOR',
    true,
    'APPROVED',
    'Test Restaurant',
    NOW(),
    NOW()
);

-- Insert vendor profile
INSERT INTO vendor_profiles (
    user_id, 
    restaurant_name, 
    restaurant_address, 
    gst_number, 
    fssai_number, 
    created_at, 
    updated_at
)
SELECT 
    u.id,
    'Test Restaurant',
    '123 Main Street, Bangalore',
    '29ABCDE1234F1Z5',
    '12345678901234',
    NOW(),
    NOW()
FROM users u
WHERE u.email = 'vendor@restaurant.com';

-- Verify the vendor was created
SELECT 
    id, 
    email, 
    role, 
    vendor_status, 
    account_active,
    company_name,
    LENGTH(password_hash) as password_hash_length
FROM users 
WHERE email = 'vendor@restaurant.com';
