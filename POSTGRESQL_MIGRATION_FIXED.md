# ✅ PostgreSQL Migration Fixed

## Issue Resolved

The migration script was using **MySQL syntax** (`AUTO_INCREMENT`), but your database is **PostgreSQL**.

### Error
```
ERROR: syntax error at or near "AUTO_INCREMENT"
```

### Fix Applied
Changed the migration script to use **PostgreSQL syntax**:

---

## Changes Made

### 1. Auto-Increment Column
**Before (MySQL):**
```sql
id BIGINT AUTO_INCREMENT PRIMARY KEY
```

**After (PostgreSQL):**
```sql
id BIGSERIAL PRIMARY KEY
```

### 2. Updated Timestamp
**Before (MySQL):**
```sql
updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
```

**After (PostgreSQL):**
```sql
updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

-- With trigger for auto-update
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

## Updated Migration Script

The file `V11__create_vendors_table.sql` now contains:

```sql
-- PostgreSQL-compatible syntax
CREATE TABLE vendors (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    restaurant_name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    address TEXT,
    business_license VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_vendor_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_vendor_user_id ON vendors(user_id);

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

## How to Apply

### Option 1: Clean Start (Recommended)

If you haven't created any important data yet:

```sql
-- Drop the failed migration record
DELETE FROM flyway_schema_history WHERE version = '11';

-- Restart application
mvn spring-boot:run
```

### Option 2: Manual Migration

If Flyway is stuck:

```sql
-- 1. Check Flyway status
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC;

-- 2. If V11 shows as failed, delete it
DELETE FROM flyway_schema_history WHERE version = '11';

-- 3. Restart application
```

### Option 3: Repair Flyway

```bash
# Run Flyway repair
mvn flyway:repair

# Then restart
mvn spring-boot:run
```

---

## Verify the Fix

After restarting, check if the table was created:

```sql
-- Check if vendors table exists
\dt vendors

-- Describe the table structure
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

## Test the System

Once the migration succeeds:

```powershell
# Create first admin
.\create-first-admin.ps1

# Test complete system
.\test-production-signup.ps1
```

---

## PostgreSQL vs MySQL Differences

| Feature | MySQL | PostgreSQL |
|---------|-------|------------|
| **Auto-increment** | `AUTO_INCREMENT` | `SERIAL` or `BIGSERIAL` |
| **Auto-update timestamp** | `ON UPDATE CURRENT_TIMESTAMP` | Trigger function |
| **String type** | `VARCHAR(n)` | `VARCHAR(n)` ✅ Same |
| **Text type** | `TEXT` | `TEXT` ✅ Same |
| **Foreign keys** | `FOREIGN KEY` | `FOREIGN KEY` ✅ Same |

---

## Future Migrations

For any future migrations, remember to use **PostgreSQL syntax**:

### Auto-increment columns
```sql
-- Use SERIAL or BIGSERIAL
id BIGSERIAL PRIMARY KEY
```

### Auto-update timestamps
```sql
-- Create trigger function
CREATE OR REPLACE FUNCTION update_table_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER table_updated_at_trigger
BEFORE UPDATE ON your_table
FOR EACH ROW
EXECUTE FUNCTION update_table_updated_at();
```

---

## Troubleshooting

### Migration still fails
```bash
# Check Flyway status
mvn flyway:info

# Repair Flyway
mvn flyway:repair

# Clean and restart (WARNING: drops all data)
mvn flyway:clean
mvn spring-boot:run
```

### Table already exists
```sql
-- Drop the table if it exists
DROP TABLE IF EXISTS vendors CASCADE;

-- Delete migration record
DELETE FROM flyway_schema_history WHERE version = '11';

-- Restart application
```

### Check PostgreSQL version
```sql
SELECT version();
```

---

## ✅ Summary

- ✅ Migration script updated for PostgreSQL
- ✅ Uses `BIGSERIAL` instead of `AUTO_INCREMENT`
- ✅ Uses trigger for auto-updating `updated_at`
- ✅ All other syntax remains compatible

**Now restart your application:**
```bash
mvn spring-boot:run
```

The migration should succeed! 🎉
