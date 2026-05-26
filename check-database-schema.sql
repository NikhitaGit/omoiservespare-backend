-- Check if password_hash column exists
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- Check Flyway migration history
SELECT version, description, installed_on, success
FROM flyway_schema_history
ORDER BY installed_rank;
