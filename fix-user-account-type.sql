-- ============================================
-- Fix User Account Type for Feedback Access
-- ============================================

-- Step 1: Check current users and their account types
SELECT 
    id,
    email,
    account_type,
    company_name,
    created_at
FROM users
ORDER BY created_at DESC;

-- Step 2: Change specific user to PROFESSIONAL
-- Replace 'your@email.com' with your actual email
UPDATE users 
SET account_type = 'PROFESSIONAL' 
WHERE email = 'your@email.com';

-- Step 3: Verify the change
SELECT 
    email,
    account_type,
    company_name
FROM users 
WHERE email = 'your@email.com';

-- Step 4: Check if feedback exists
SELECT 
    f.id,
    f.rating,
    f.comments,
    f.status,
    f.company_name,
    f.created_at,
    u.email as user_email
FROM feedback f
JOIN users u ON f.user_id = u.id
ORDER BY f.created_at DESC
LIMIT 10;

-- Step 5: Count feedback by company
SELECT 
    company_name,
    COUNT(*) as feedback_count,
    AVG(rating) as avg_rating
FROM feedback
GROUP BY company_name;

-- ============================================
-- Optional: Create a test admin user
-- ============================================

-- First, signup a new user through the app with email: admin@test.com
-- Then run this to make them PROFESSIONAL:

-- UPDATE users 
-- SET account_type = 'PROFESSIONAL' 
-- WHERE email = 'admin@test.com';

-- ============================================
-- Troubleshooting Queries
-- ============================================

-- Check all feedback with user details
SELECT 
    f.id,
    u.email,
    u.account_type,
    f.company_name,
    f.rating,
    f.comments,
    f.status,
    f.created_at
FROM feedback f
JOIN users u ON f.user_id = u.id
ORDER BY f.created_at DESC;

-- Find users by account type
SELECT 
    account_type,
    COUNT(*) as user_count
FROM users
GROUP BY account_type;
