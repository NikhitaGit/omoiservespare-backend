# ⚡ Quick Start Guide

## Current Status
✅ Java 17 - Installed  
❌ PostgreSQL - **NEED TO INSTALL**  
❌ Redis - **NEED TO INSTALL**  
✅ Code - Compiles successfully  

---

## 🎯 What You Need to Do

### 1. Install PostgreSQL (5 minutes)
```powershell
# Download and install from:
https://www.postgresql.org/download/windows/

# During installation, set password: NikhitaMumbai123*
# (or change it in application.properties later)
```

### 2. Create Database (1 minute)
```powershell
# Open Command Prompt or PowerShell
psql -U postgres

# In psql prompt:
CREATE DATABASE omoiservespare_db;
\q
```

### 3. Install Redis (Choose ONE option)

#### Option A: Memurai (Easiest for Windows)
```powershell
# Download from: https://www.memurai.com/get-memurai
# Install and start the service
```

#### Option B: Docker (If you have Docker)
```powershell
docker run -d -p 6379:6379 --name redis redis:latest
```

#### Option C: Skip Redis (Temporary)
```properties
# Comment out Redis in application.properties:
# spring.redis.host=localhost
# spring.redis.port=6379
```

### 4. Run the Application
```powershell
cd omoiservespare
.\mvnw.cmd spring-boot:run
```

---

## 🧪 Test It Works

### Test 1: Check if server is running
```powershell
curl http://localhost:8080/api/canteens
```

### Test 2: Try login
```powershell
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"companyName\":\"Omoikane\",\"email\":\"user1@example.com\",\"phoneNumber\":\"9876543210\",\"accountType\":\"EMPLOYEE\"}'
```

---

## 🔧 Troubleshooting

### Problem: "Connection refused" to PostgreSQL
**Solution**: Make sure PostgreSQL service is running
```powershell
# Check service status
Get-Service -Name postgresql*

# Start service if stopped
Start-Service postgresql-x64-16  # (version may vary)
```

### Problem: "Unable to connect to Redis"
**Solution**: 
- Check if Memurai/Redis is running
- Or temporarily disable Redis (comment out in application.properties)

### Problem: "Port 8080 already in use"
**Solution**: Kill the process using port 8080
```powershell
# Find process
netstat -ano | findstr :8080

# Kill it (replace <PID> with actual number)
taskkill /PID <PID> /F
```

### Problem: Wrong PostgreSQL password
**Solution**: Update application.properties
```properties
# Line 18 in application.properties
spring.datasource.password=YOUR_ACTUAL_PASSWORD
```

---

## 📋 Verification Checklist

Run this script to check your setup:
```powershell
.\check-setup.ps1
```

All should show ✅:
- [ ] Java 17
- [ ] PostgreSQL installed
- [ ] Database created
- [ ] Redis running
- [ ] Port 8080 available
- [ ] Application starts without errors

---

## 🎉 Success Indicators

When everything works, you'll see:
```
Flyway successfully validated 5 migrations
Flyway successfully applied 5 migrations
Started OmoiservespareApplication in X.XXX seconds
```

And the API will respond:
```powershell
curl http://localhost:8080/api/canteens
# Returns JSON with canteen data
```

---

## 📚 More Help

- **Detailed Setup**: See `SETUP_GUIDE_WINDOWS.md`
- **Project Info**: See `README_FINAL.md`
- **API Docs**: See `README_FINAL.md` (API Endpoints section)

---

## 🚀 Installation Order

1. **PostgreSQL** (Required) - 5 min
2. **Create Database** (Required) - 1 min  
3. **Redis** (Optional for now) - 5 min
4. **Run App** - 1 min

**Total Time**: ~15 minutes

---

**Need help?** Check the error message and look in SETUP_GUIDE_WINDOWS.md for solutions.
