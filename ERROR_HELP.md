# 🆘 Getting Errors? Start Here

## 🔍 Step 1: Run Diagnostics

```powershell
.\diagnose-error.ps1
```

This will automatically check:
- PostgreSQL status
- Redis status  
- Port availability
- Code compilation
- Configuration files
- Attempt startup and capture errors

---

## 🚨 Most Common Errors

### 1. Redis Not Running (90% of issues)

**Error:**
```
Unable to connect to Redis
Connection refused: localhost:6379
```

**Fix:**
```cmd
docker run -d -p 6379:6379 --name redis redis:latest
```

**Or if Docker isn't running:**
1. Start Docker Desktop from Start menu
2. Wait for it to fully start
3. Then run the Redis command above

---

### 2. Database Connection Failed

**Error:**
```
Connection to localhost:5432 refused
PSQLException
```

**Fix:**
```powershell
# Check if PostgreSQL is running
Get-Service -Name postgresql*

# If stopped, start it
Start-Service postgresql-x64-16

# Verify database exists
$env:PGPASSWORD="NikhitaMumbai123*"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -l
```

---

### 3. Port 8080 In Use

**Error:**
```
Port 8080 is already in use
```

**Fix:**
```powershell
# Find what's using it
netstat -ano | findstr :8080

# Kill the process (replace <PID>)
taskkill /PID <PID> /F
```

---

## 📋 Quick Checklist

Before running the application:

```powershell
# 1. Check Docker
docker ps

# 2. Check Redis
docker ps --filter "name=redis"

# 3. Check PostgreSQL
Get-Service -Name postgresql*

# 4. Check Port
netstat -ano | findstr :8080
```

All should show positive results.

---

## 🔧 Diagnostic Tools

| Tool | Purpose | Command |
|------|---------|---------|
| **diagnose-error.ps1** | Full diagnostic | `.\diagnose-error.ps1` |
| **check-services.ps1** | Check services only | `.\check-services.ps1` |
| **start-with-logs.cmd** | Start with detailed logs | `.\start-with-logs.cmd` |
| **test-login.ps1** | Test login API | `.\test-login.ps1` |

---

## 📖 Documentation

| File | When to Read |
|------|--------------|
| **TROUBLESHOOTING.md** | Detailed error solutions |
| **ERROR_HELP.md** | This file - quick reference |
| **FIX_SUMMARY.md** | What was fixed |
| **LOGIN_FIX_APPLIED.md** | Login-specific fixes |

---

## 🎯 Quick Start (If Everything Works)

```cmd
# Option 1: Automated
start-all.cmd

# Option 2: Manual
docker start redis
mvn spring-boot:run
```

---

## 💡 Pro Tips

### Tip 1: Check Logs First
The error message usually tells you exactly what's wrong:
- "Redis" → Start Redis
- "PostgreSQL" → Start PostgreSQL  
- "Port" → Kill process using port
- "Flyway" → Database issue

### Tip 2: Start Services in Order
1. Docker Desktop
2. Redis (in Docker)
3. PostgreSQL (should auto-start)
4. Application

### Tip 3: Use Diagnostic Scripts
Don't guess - run `.\diagnose-error.ps1` to see exactly what's wrong.

---

## 🆘 Still Stuck?

### Collect This Info:

1. **Run diagnostics:**
   ```powershell
   .\diagnose-error.ps1 > diagnosis.txt
   ```

2. **Get full error:**
   ```cmd
   mvn spring-boot:run > error-log.txt 2>&1
   ```

3. **Check services:**
   ```powershell
   .\check-services.ps1 > services.txt
   ```

Then review these files for the actual error message.

---

## 📞 Error Message Decoder

| You See | It Means | Fix |
|---------|----------|-----|
| "Connection refused" | Service not running | Start the service |
| "Port already in use" | Another app on port | Kill process |
| "Authentication failed" | Wrong password | Check config |
| "Database does not exist" | DB not created | Create database |
| "Timeout" | Service too slow | Check connections |
| "ClassNotFoundException" | Build issue | `mvn clean install` |

---

## 🎬 Step-by-Step Recovery

If nothing works:

```powershell
# 1. Stop everything
taskkill /F /IM java.exe
docker stop redis

# 2. Start Docker Desktop
# (manually from Start menu)

# 3. Wait 30 seconds

# 4. Start Redis
docker start redis
# Or: docker run -d -p 6379:6379 --name redis redis:latest

# 5. Check PostgreSQL
Get-Service -Name postgresql*

# 6. Run diagnostics
.\diagnose-error.ps1

# 7. If all OK, start app
mvn spring-boot:run
```

---

## ✅ Success Looks Like

When starting, you should see:
```
Flyway successfully validated 5 migrations
Started OmoiservespareApplication in 15.234 seconds
Tomcat started on port 8080
```

No errors about:
- Redis connection
- Database connection
- Port conflicts

---

**Remember:** 90% of startup issues are Redis not running!

**Quick fix:** `docker run -d -p 6379:6379 --name redis redis:latest`
