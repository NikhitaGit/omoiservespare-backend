# 🔧 Fix Migration Error - Quick Guide

## ✅ Issue Fixed!

The migration script has been updated for **PostgreSQL**. Now you need to clean up the failed migration and restart.

---

## 🚀 Quick Fix (3 Steps)

### Step 1: Clean Up Failed Migration

**Option A: Using SQL Script (Recommended)**
```bash
# Connect to your PostgreSQL database and run:
psql -U your_username -d your_database -f fix-migration-postgresql.sql
```

**Option B: Manual SQL Commands**
```sql
-- Delete the failed migration record
DELETE FROM flyway_schema_history WHERE version = '11';

-- Drop vendors table if partially created
DROP TABLE IF EXISTS vendors CASCADE;

-- Drop trigger function if exists
DROP FUNCTION IF EXISTS update_vendors_updated_at() CASCADE;
```

**Option C: Using Maven Flyway Repair**
```bash
mvn flyway:repair
```

---

### Step 2: Restart Application
```bash
mvn spring-boot:run
```

The migration will run automatically with the corrected PostgreSQL syntax.

---

### Step 3: Verify Success
```sql
-- Check if vendors table was created
\dt vendors

-- Check table structure
\d vendors

-- Verify migration succeeded
SELECT * FROM flyway_schema_history WHERE version = '11';
```

---

## 📋 What Was Fixed

### Before (MySQL Syntax - ❌ Failed)
```sql
CREATE TABLE vendors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ...
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### After (PostgreSQL Syntax - ✅ Works)
```sql
CREATE TABLE vendors (
    id BIGSERIAL PRIMARY KEY,
    ...
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for auto-updating updated_at
CREATE OR REPLACE FUNCTION update_vendors_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vendors_updated_at_trigger
BEFORE UPDATE ON vendors
FOR EACH ROW
EXECUTE FUNCTION update_vendors_updated_at();
```

---

## 🔍 Detailed Steps

### 1. Connect to PostgreSQL

**Using psql:**
```bash
psql -U your_username -d your_database
```

**Using pgAdmin:**
- Open pgAdmin
- Connect to your database
- Open Query Tool

---

### 2. Check Current Status
```sql
SELECT version, description, success 
FROM flyway_schema_history 
ORDER BY installed_rank DESC 
LIMIT 5;
```

You should see V11 with `success = false`.

---

### 3. Clean Up Failed Migration
```sql
-- Delete failed migration record
DELETE FROM flyway_schema_history WHERE version = '11';

-- Drop vendors table if exists
DROP TABLE IF EXISTS vendors CASCADE;

-- Drop trigger function if exists
DROP FUNCTION IF EXISTS update_vendors_updated_at() CASCADE;
```

---

### 4. Verify Cleanup
```sql
-- V11 should not appear
SELECT * FROM flyway_schema_history WHERE version = '11';

-- vendors table should not exist
\dt vendors
```

---

### 5. Restart Application
```bash
mvn spring-boot:run
```

Watch the logs for:
```
Migrating schema "public" to version "11 - create vendors table"
Successfully applied 1 migration to schema "public"
```

---

### 6. Verify Success
```sql
-- Check migration succeeded
SELECT version, description, success 
FROM flyway_schema_history 
WHERE version = '11';

-- Should show: success = true

-- Check table exists
\dt vendors

-- Check table structure
\d vendors

-- Should show:
-- id (bigserial)
-- user_id (bigint)
-- restaurant_name (varchar)
-- owner_name (varchar)
-- address (text)
-- business_license (varchar)
-- description (text)
-- created_at (timestamp)
-- updated_at (timestamp)
```

---

## 🧪 Test After Fix

Once migration succeeds:

```powershell
# Create first admin
.\create-first-admin.ps1

# Test vendor registration
.\test-production-signup.ps1
```

---

## 🆘 Troubleshooting

### Issue: "relation already exists"
```sql
-- Drop the table
DROP TABLE IF EXISTS vendors CASCADE;

-- Delete migration record
DELETE FROM flyway_schema_history WHERE version = '11';

-- Restart application
```

---

### Issue: "function already exists"
```sql
-- Drop the function
DROP FUNCTION IF EXISTS update_vendors_updated_at() CASCADE;

-- Restart application
```

---

### Issue: Flyway is locked
```sql
-- Check for locks
SELECT * FROM flyway_schema_history WHERE success = false;

-- Repair Flyway
mvn flyway:repair

-- Or manually delete lock
DELETE FROM flyway_schema_history WHERE version = '11';
```

---

### Issue: Migration still fails
```bash
# Check Flyway info
mvn flyway:info

# Repair Flyway
mvn flyway:repair

# Check application.properties
# Make sure you're using PostgreSQL driver
spring.datasource.driver-class-name=org.postgresql.Driver
```

---

## 📊 Quick Reference

### PostgreSQL Commands
```sql
-- List tables
\dt

-- Describe table
\d vendors

-- Check migrations
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC;

-- Delete failed migration
DELETE FROM flyway_schema_history WHERE version = '11';

-- Drop table
DROP TABLE IF EXISTS vendors CASCADE;
```

### Maven Commands
```bash
# Check Flyway status
mvn flyway:info

# Repair Flyway
mvn flyway:repair

# Clean database (WARNING: deletes all data)
mvn flyway:clean

# Run application
mvn spring-boot:run
```

---

## ✅ Success Checklist

- [ ] Failed migration record deleted
- [ ] Vendors table dropped (if exists)
- [ ] Trigger function dropped (if exists)
- [ ] Application restarted
- [ ] Migration V11 succeeded
- [ ] Vendors table created
- [ ] Trigger created
- [ ] First admin created
- [ ] System tested

---

## 📖 Documentation

For more details:
- **PostgreSQL Fix**: [POSTGRESQL_MIGRATION_FIXED.md](POSTGRESQL_MIGRATION_FIXED.md)
- **Quick Start**: [PRODUCTION_SIGNUP_QUICK_START.md](PRODUCTION_SIGNUP_QUICK_START.md)
- **Testing**: [READY_TO_TEST.md](READY_TO_TEST.md)

---

## 🎉 You're Almost There!

Just run these commands:

```bash
# 1. Clean up (in PostgreSQL)
psql -U your_username -d your_database -f fix-migration-postgresql.sql

# 2. Restart application
mvn spring-boot:run

# 3. Create first admin
.\create-first-admin.ps1
```

**Done! Your system will be ready to use.** 🚀
