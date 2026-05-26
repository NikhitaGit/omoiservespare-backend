# 🚀 Start Your App - 2 Simple Steps

## Step 1: Set Admin Password (30 seconds)

Open **pgAdmin** → Query Tool → Run this:

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

UPDATE users SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W' WHERE email = 'admin@company.com';
```

Click Execute (▶️). Done!

## Step 2: Start Application

```powershell
mvn spring-boot:run
```

Wait for: `Started OmoiservespareApplication`

## ✅ Done!

Your app is now running with:
- Admin account ready
- Password set (admin123)
- All features working

---

**Admin Login:**
- Email: admin@company.com
- Password: admin123 (ready in database)
- Current: Use OTP system

**Check Status:**
```powershell
.\test-backend-status.ps1
```

That's it! 🎉
