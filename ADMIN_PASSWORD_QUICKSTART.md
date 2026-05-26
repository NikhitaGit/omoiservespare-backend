# ⚡ Admin Password - Quick Start (30 seconds)

## 🎯 Easiest Way: Use pgAdmin

### 1️⃣ Open pgAdmin
Double-click pgAdmin icon on your desktop

### 2️⃣ Open Query Tool
- Find your database: `omoiservespare`
- Right-click → "Query Tool"

### 3️⃣ Copy & Paste This
```sql
UPDATE users
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'
WHERE email = 'admin@company.com';
```

### 4️⃣ Click Execute (▶️)
Should see: "UPDATE 1"

### ✅ Done!
**Admin Login:**
- Email: `admin@company.com`
- Password: `admin123`

---

## 🚀 Alternative: One Command

Open PowerShell in your project folder:

```powershell
.\run-set-admin-password.ps1
```

Enter your PostgreSQL password when asked.

---

## 🧪 Test It

```powershell
.\test-admin-login.ps1
```

Should see: "SUCCESS! Admin logged in"

---

## ❓ Problems?

### "No admin found"
First create admin:
```powershell
.\create-first-admin.ps1
```

### "Can't connect to database"
Make sure PostgreSQL is running and Spring Boot created the tables.

### "Wrong password for postgres"
Check your PostgreSQL installation password.

---

## 📸 Visual Guide

```
pgAdmin Window
┌─────────────────────────────────────────┐
│ File  Edit  View  Tools  Help           │
├─────────────────────────────────────────┤
│ Servers                                  │
│  └─ PostgreSQL 16                        │
│      └─ Databases                        │
│          └─ omoiservespare  ← Right-click│
│              └─ Query Tool   ← Click this│
└─────────────────────────────────────────┘

Query Tool Window
┌─────────────────────────────────────────┐
│ ▶️ Execute  💾 Save  📋 Copy            │
├─────────────────────────────────────────┤
│ UPDATE users                             │
│ SET password_hash = '$2a$10$N9qo...'    │
│ WHERE email = 'admin@company.com';       │
│                                          │
│ ← Paste SQL here                        │
│ ← Click Execute (▶️)                    │
├─────────────────────────────────────────┤
│ Messages:                                │
│ UPDATE 1  ← Success!                    │
└─────────────────────────────────────────┘
```

---

**That's it! Takes 30 seconds.** ⏱️

Now test: `.\test-admin-login.ps1`
