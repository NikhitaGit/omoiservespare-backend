-- =====================================================
-- Set Admin Password
-- =====================================================
-- Sets password for existing admin account
-- Password: admin123
-- Pre-hashed with BCrypt

UPDATE users
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'
WHERE email = 'admin@company.com';

-- Verify the update
SELECT 
    id,
    email,
    role,
    account_active,
    CASE 
        WHEN password_hash IS NOT NULL THEN 'Password Set ✓'
        ELSE 'No Password ✗'
    END as password_status
FROM users
WHERE email = 'admin@company.com';

-- =====================================================
-- To set a different password, use this format:
-- =====================================================
-- UPDATE users
-- SET password_hash = crypt('YOUR_PASSWORD_HERE', gen_salt('bf'))
-- WHERE email = 'admin@company.com';
