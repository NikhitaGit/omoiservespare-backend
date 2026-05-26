-- =====================================================
-- Add Password Column and Set Admin Password
-- =====================================================

-- Step 1: Add password_hash column
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- Step 2: Set admin password (password: admin123)
UPDATE users
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'
WHERE email = 'admin@company.com';

-- Step 3: Verify
SELECT 
    email, 
    role, 
    CASE 
        WHEN password_hash IS NOT NULL THEN 'Password Set ✓' 
        ELSE 'No Password ✗' 
    END as password_status
FROM users 
WHERE email = 'admin@company.com';

-- =====================================================
-- Result: Admin password is now set to: admin123
-- =====================================================
