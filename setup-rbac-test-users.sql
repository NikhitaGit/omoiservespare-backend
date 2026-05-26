-- ============================================
-- RBAC Test Users Setup
-- ============================================
-- Creates test users with different roles for testing RBAC

-- 1. Create ADMIN user
UPDATE users 
SET role = 'ADMIN', 
    account_active = true 
WHERE email = 'admin@test.com';

-- If admin user doesn't exist, you'll need to create one first through signup
-- Then run the UPDATE above

-- 2. Create regular USER
UPDATE users 
SET role = 'USER', 
    account_active = true 
WHERE email = 'user@test.com';

-- 3. Create VENDOR user (if you have vendors)
UPDATE users 
SET role = 'VENDOR', 
    account_active = true,
    vendor_status = 'APPROVED'
WHERE email = 'vendor@test.com';

-- 4. Verify the changes
SELECT 
    id,
    email,
    role,
    account_active,
    vendor_status,
    created_at
FROM users
WHERE email IN ('admin@test.com', 'user@test.com', 'vendor@test.com')
ORDER BY role;

-- Expected output:
-- admin@test.com  -> ADMIN role
-- user@test.com   -> USER role
-- vendor@test.com -> VENDOR role (if applicable)
