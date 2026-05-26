-- =====================================================
-- Fix Flyway Migration for Vendors Table
-- =====================================================
-- Run this SQL script directly in PostgreSQL to fix the migration issue

-- Step 1: Delete the failed migration record from Flyway history
DELETE FROM flyway_schema_history WHERE version = '12';

-- Step 2: Verify the vendors table exists (it should)
-- If it doesn't exist, the migration will create it
-- If it exists, the migration will skip it due to IF NOT EXISTS

-- Step 3: Check current state
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'vendors'
ORDER BY ordinal_position;

-- Step 4: Check if trigger exists
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'vendors';

-- =====================================================
-- After running this script, restart your Spring Boot app
-- The migration V12 will run successfully
-- =====================================================
