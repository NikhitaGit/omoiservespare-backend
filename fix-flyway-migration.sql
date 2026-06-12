-- Remove the failed migration from Flyway schema history
DELETE FROM flyway_schema_history WHERE version = '24';

-- Drop any partially created tables from the failed migration
DROP TABLE IF EXISTS refund_audit_logs CASCADE;
DROP TABLE IF EXISTS refund_webhook_events CASCADE;
DROP TABLE IF EXISTS refund_sequence CASCADE;
