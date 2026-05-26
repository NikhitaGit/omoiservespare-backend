-- =====================================================
-- Fix Failed Migration V11 (PostgreSQL)
-- =====================================================
-- Run this script if the migration failed
-- This will clean up and allow the migration to run again

-- 1. Check current Flyway status
SELECT version, description, type, installed_on, success 
FROM flyway_schema_history 
ORDER BY installed_rank DESC 
LIMIT 5;

-- 2. Delete the failed V11 migration record
DELETE FROM flyway_schema_history WHERE version = '11';

-- 3. Drop vendors table if it was partially created
DROP TABLE IF EXISTS vendors CASCADE;

-- 4. Drop trigger function if it exists
DROP FUNCTION IF EXISTS update_vendors_updated_at() CASCADE;

-- 5. Verify cleanup
SELECT version, description, type, installed_on, success 
FROM flyway_schema_history 
ORDER BY installed_rank DESC 
LIMIT 5;

-- =====================================================
-- After running this script:
-- 1. Restart your application: mvn spring-boot:run
-- 2. The migration will run automatically
-- =====================================================
