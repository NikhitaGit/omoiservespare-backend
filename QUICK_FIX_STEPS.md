# 🔧 Quick Fix - 3 Simple Steps

## The Problem

The migration file was updated, but Maven was using the **old cached version** from `target/classes`. Also, the failed migration is stuck in the database.

---

## ✅ Solution (3 Steps)

### Step 1: Clean Maven Cache ✅ DONE
```bash
mvn clean
```
**Status:** ✅ Already completed!

---

### Step 2: Clean Database

**Option A: Using psql (Recommended)**
```bash
psql -U your_username -d omoiservespare_db -f cleanup-failed-migration.sql
```

**Option B: Using pgAdmin**
1. Open pgAdmin
2. Connect to `omoiservespare_db`
3. Open Query Tool
4. Copy and paste this:

```sql
-- Delete failed migration
DELETE FROM flyway_schema_history WHERE version = '11';

-- Drop vendors table if exists
DROP TABLE IF EXISTS vendors CASCADE;

-- Drop trigger function if exists
DROP FUNCTION IF EXISTS update_vendors_updated_at() CASCADE;
```

5. Click Execute (F5)

**Option C: Manual psql commands**
```bash
# Connect to database
psql -U your_username -d omoiservespare_db

# Run these commands:
DELETE FROM flyway_schema_history WHERE version = '11';
DROP TABLE IF EXISTS vendors CASCADE;
DROP FUNCTION IF EXISTS update_vendors_updated_at() CASCADE;

# Exit
\q
```

---

### Step 3: Restart Application
```bash
mvn spring-boot:run
```

The migration will now run with the correct PostgreSQL syntax!

---

## 🎯 What Fixed It

1. **Maven clean** - Removed old cached files
2. **Database cleanup** - Removed failed migration record
3. **Restart** - Runs migration with new PostgreSQL syntax

---

## ✅ Verify Success

After restart, check the logs for:
```
Migrating schema "public" to version "11 - create vendors table"
Successfully applied 1 migration to schema "public"
```

Then verify in database:
```sql
-- Check migration succeeded
SELECT * FROM flyway_schema_history WHERE version = '11';

-- Check table exists
\dt vendors

-- Check table structure
\d vendors
```

---

## 🆘 If It Still Fails

### Check the migration file location
```bash
# Make sure this file has PostgreSQL syntax (BIGSERIAL, not AUTO_INCREMENT)
cat src/main/resources/db/migration/V11__create_vendors_table.sql
```

### Verify database connection
```bash
# Test connection
psql -U your_username -d omoiservespare_db -c "SELECT version();"
```

### Check application.properties
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/omoiservespare_db
spring.datasource.username=your_username
spring.datasource.password=your_password
```

---

## 📋 Quick Reference

### Your Database Info
- **Database**: `omoiservespare_db`
- **Host**: `localhost:5432`
- **Type**: PostgreSQL 16.12

### Commands
```bash
# Clean Maven
mvn clean

# Clean database
psql -U your_username -d omoiservespare_db -f cleanup-failed-migration.sql

# Restart
mvn spring-boot:run
```

---

## 🎉 After Success

Once the application starts successfully:

```powershell
# Create first admin
.\create-first-admin.ps1

# Test system
.\test-production-signup.ps1
```

---

**Ready? Run Step 2 (database cleanup) then Step 3 (restart)!** 🚀
