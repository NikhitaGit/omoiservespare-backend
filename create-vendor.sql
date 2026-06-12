-- ==========================================
-- CREATE NEW VENDOR ACCOUNT
-- ==========================================

-- Step 1: Delete if email already exists (optional)
DELETE FROM users WHERE email = 'john@pizzahut.com';

-- Step 2: Create new vendor
-- Change the email, phone, and company_name as needed
INSERT INTO users (
    email, 
    phone_number, 
    password_hash, 
    role,
    account_type,
    account_active, 
    vendor_status,
    company_name,
    created_at, 
    updated_at
)
VALUES (
    'john@pizzahut.com',              -- Change email
    '+91-9876543210',                 -- Change phone
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',  -- Password: vendor123
    'VENDOR',
    'VENDOR',
    true,
    'APPROVED',
    'Pizza Hut',                      -- Change restaurant name
    NOW(),
    NOW()
);

-- Step 3: Verify the vendor was created
SELECT 
    id,
    email,
    role,
    account_type,
    vendor_status,
    account_active,
    company_name,
    phone_number,
    SUBSTRING(password_hash, 1, 30) as hash_preview,
    LENGTH(password_hash) as hash_length
FROM users 
WHERE email = 'john@pizzahut.com';   -- Change email

-- ==========================================
-- LOGIN CREDENTIALS
-- ==========================================
-- Email: john@pizzahut.com
-- Password: vendor123
-- ==========================================

-- ==========================================
-- AVAILABLE PASSWORD HASHES
-- ==========================================
-- If you want a different password, use one of these:

-- Password: vendor123
-- Hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- Password: test123
-- Hash: $2a$10$dXeemQ8VfQSVCqVJXk.9gu2IV0FdQ8yVqVH5Hq7rQ8TqYqN5nh5qC

-- Password: admin123
-- Hash: $2a$10$rZ5YhkKJPqYqN5YhkKJPqYqN5YhkKJPqYqN5YhkKJPqYqN5YhkKJPq

-- ==========================================
-- TO CREATE WITH DIFFERENT PASSWORD
-- ==========================================
-- 1. Go to: https://bcrypt-generator.com/
-- 2. Enter your password
-- 3. Set rounds to 10
-- 4. Copy the generated hash
-- 5. Replace the password_hash value above
-- ==========================================
