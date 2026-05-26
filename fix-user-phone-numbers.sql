-- Fix User Phone Numbers for Ticket System
-- This script checks and updates phone numbers for users

-- Step 1: Check current phone numbers
SELECT 
    id,
    company_name,
    email,
    phone_number,
    account_type
FROM users
ORDER BY id;

-- Step 2: Find users without phone numbers
SELECT 
    id,
    company_name,
    email,
    'Missing phone number' as issue
FROM users
WHERE phone_number IS NULL OR phone_number = '';

-- Step 3: Update specific user's phone number (replace with actual email)
-- UPDATE users 
-- SET phone_number = '+1234567890' 
-- WHERE email = 'nikita.a@omoikaneinnovations.com';

-- Step 4: Update all users without phone numbers (use with caution)
-- UPDATE users 
-- SET phone_number = '+1234567890' 
-- WHERE phone_number IS NULL OR phone_number = '';

-- Step 5: Verify the update
-- SELECT 
--     id,
--     company_name,
--     email,
--     phone_number
-- FROM users
-- WHERE email = 'nikita.a@omoikaneinnovations.com';

-- Example: Update multiple users with different phone numbers
-- UPDATE users SET phone_number = '+1234567890' WHERE email = 'user1@example.com';
-- UPDATE users SET phone_number = '+0987654321' WHERE email = 'user2@example.com';

-- Note: Uncomment the UPDATE statements above to actually make changes
-- Always backup your database before running UPDATE statements!
