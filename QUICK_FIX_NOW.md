# ⚡ QUICK FIX - DO THIS NOW

## The Problem
Your backend won't start because Flyway migration V12 failed. The `vendors` table already exists, but Flyway recorded it as a failed migration.

## The Solution (2 minutes)

### Step 1: Open pgAdmin
1. Open pgAdmin on your computer
2. Connect to your PostgreSQL server
3. Navigate to: Databases → omoiservespare_db → Schemas → public → Tables

### Step 2: Open Query Tool
1. Right-click on `omoiservespare_db`
2. Select "Query Tool"

### Step 3: Run This SQL
Copy and paste this into the Query Tool:

```sql
DELETE FROM flyway_schema_history WHERE version = '12';
```

Click the Execute button (▶️) or press F5.

You should see: `DELETE 1` (meaning 1 row was deleted)

### Step 4: Start Your Backend
Open PowerShell in your project folder and run:

```powershell
mvn spring-boot:run
```

## What This Does
- Removes the failed migration record from Flyway's history
- Allows Flyway to retry the migration
- The migration will succeed because it has `IF NOT EXISTS` clauses
- Your backend will start successfully

## After This Fix
✓ Backend runs on http://localhost:8080
✓ Login will work (password-based, not OTP)
✓ JWT tokens will be generated
✓ Frontend can connect to backend

## Why You're Not Getting OTP
Your system uses **PASSWORD authentication**, not OTP. When you try to login:
1. Enter email + password
2. Backend generates JWT token
3. Token is stored in browser
4. You're logged in

The "network error" you saw was because the backend wasn't running due to this Flyway error.

## Need Help?
If pgAdmin is not installed, download it from: https://www.pgadmin.org/download/

Or use the alternative file: `fix-flyway-direct.sql` - open it in any PostgreSQL client.
