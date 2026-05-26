# 🔐 How to Set Admin Password - Step by Step

## Method 1: Using pgAdmin (Easiest - GUI)

### Step 1: Open pgAdmin
1. Open pgAdmin 4 on your computer
2. Connect to your PostgreSQL server

### Step 2: Navigate to Query Tool
1. Expand Servers → PostgreSQL
2. Expand Databases → omoiservespare
3. Right-click on "omoiservespare" database
4. Select "Query Tool"

### Step 3: Run the SQL
Copy and paste this into the Query Tool:

```sql
UPDATE users
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'
WHERE email = 'admin@company.com';
```

### Step 4: Execute
1. Click the "Execute" button (▶️ icon) or press F5
2. You should see: "UPDATE 1" in the output

### Step 5: Verify
Run this query to verify:

```sql
SELECT email, role, 
  CASE WHEN password_hash IS NOT NULL THEN 'Password Set ✓' ELSE 'No Password ✗' END as status
FROM users 
WHERE email = 'admin@company.com';
```

**Done! Admin password is now: `admin123`**

---

## Method 2: Using Command Line (psql)

### Step 1: Open Command Prompt or PowerShell

### Step 2: Connect to PostgreSQL
```powershell
psql -U postgres -d omoiservespare
```

Enter your PostgreSQL password when prompted.

### Step 3: Run the SQL
```sql
UPDATE users
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'
WHERE email = 'admin@company.com';
```

### Step 4: Verify
```sql
SELECT email, role FROM users WHERE email = 'admin@company.com';
```

### Step 5: Exit
```
\q
```

**Done! Admin password is now: `admin123`**

---

## Method 3: Using SQL File (Automated)

### Step 1: Open PowerShell in your project directory

### Step 2: Run this command
```powershell
psql -U postgres -d omoiservespare -f set-admin-password.sql
```

Enter your PostgreSQL password when prompted.

**Done! Admin password is now: `admin123`**

---

## Method 4: Using PowerShell Script (One-Click)

### Create this script: `run-set-admin-password.ps1`

```powershell
# Set PostgreSQL password
$env:PGPASSWORD = "your_postgres_password"

# Run SQL file
psql -U postgres -d omoiservespare -f set-admin-password.sql

# Clear password from environment
Remove-Item Env:\PGPASSWORD

Write-Host "Admin password set successfully!" -ForegroundColor Green
```

### Run it:
```powershell
.\run-set-admin-password.ps1
```

---

## Test Admin Login

After setting the password, test it:

```powershell
.\test-admin-login.ps1
```

Or manually test:

```powershell
$login = @{
    email = "admin@company.com"
    password = "admin123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/v2/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $login
```

---

## Troubleshooting

### "relation 'users' does not exist"
→ Run your Spring Boot app first to create tables

### "no rows updated"
→ Admin doesn't exist yet, run: `.\create-first-admin.ps1`

### "password authentication failed"
→ Check your PostgreSQL password

### "database 'omoiservespare' does not exist"
→ Create the database first or check application.properties

---

## Change Password to Something Else

If you want a different password, use this format:

```sql
-- For password: mypassword123
-- You need to generate BCrypt hash first

-- Option 1: Use online BCrypt generator
-- Go to: https://bcrypt-generator.com/
-- Enter your password
-- Copy the hash
-- Use in SQL:

UPDATE users
SET password_hash = 'YOUR_BCRYPT_HASH_HERE'
WHERE email = 'admin@company.com';
```

Or use this PowerShell script to generate hash:

```powershell
# Install BCrypt module (one time)
Install-Module -Name BCrypt

# Generate hash
$password = "mypassword123"
$hash = ConvertTo-BCryptHash -Password $password
Write-Host "Hash: $hash"

# Use this hash in SQL
```

---

## Quick Reference

**Default Admin Credentials:**
- Email: `admin@company.com`
- Password: `admin123`

**Pre-hashed Password:**
```
$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W
```

**SQL Command:**
```sql
UPDATE users SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W' WHERE email = 'admin@company.com';
```

---

**Recommended: Use Method 1 (pgAdmin) - It's the easiest!** 🎯
