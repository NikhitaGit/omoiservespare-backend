-- =====================================================
-- Cleanup Failed Migration V11
-- =====================================================
-- Run this in your PostgreSQL database before restarting

-- 1. Check current migration status
SELECT version, description, success, installed_on 
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
SELECT version, description, success 
FROM flyway_schema_history 
ORDER BY installed_rank DESC 
LIMIT 5;

-- =====================================================
-- After running this:
-- 1. Run: mvn spring-boot:run
-- 2. The migration will run with correct PostgreSQL syntax
-- =====================================================
