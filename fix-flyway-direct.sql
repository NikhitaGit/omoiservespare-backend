-- =====================================================
-- DIRECT FIX FOR FLYWAY MIGRATION ERROR
-- =====================================================
-- Database: omoiservespare_db
-- Run this in pgAdmin or any PostgreSQL client

-- Step 1: Check current Flyway status
SELECT version, description, type, installed_on, success 
FROM flyway_schema_history 
ORDER BY installed_rank DESC 
LIMIT 5;

-- Step 2: Delete the failed V12 migration record
DELETE FROM flyway_schema_history WHERE version = '12';

-- Step 3: Verify deletion
SELECT version, description, type, installed_on, success 
FROM flyway_schema_history 
ORDER BY installed_rank DESC 
LIMIT 5;

-- Step 4: Check if vendors table exists (it should)
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'vendors';

-- =====================================================
-- After running this SQL:
-- 1. Close this SQL window
-- 2. Run: mvn spring-boot:run
-- 3. The application will start successfully
-- =====================================================
