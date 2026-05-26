# 🔧 Signup Error Solution

**Error**: `POST http://localhost:8080/api/auth/signup 500 (Internal Server Error)`  
**Root Cause**: Redis connection issues + endpoint routing problems

---

## 🐛 Issues Identified

### 1. Redis Connection Failures
```
Cannot reconnect to [localhost/<unresolved>:6379]: Connection refused
```
**Cause**: Redis is not running or Docker is not started

### 2. Endpoint Not Found
```
No static resource api/auth/signup for request '/api/auth/signup'
```
**Cause**: Spring Security or routing issue preventing signup endpoint from being reached

---

## ✅ Solution Steps

### Step 1: Fix Redis Issue

**Option A: Start Redis (Recommended)**
```powershell
# Start Docker Desktop first, then:
docker run -d -p 6379:6379 --name redis --restart unless-stopped redis:latest

# Verify it's working
docker ps
docker exec redis redis-cli ping
# Should return: PONG
```

**Option B: Use Fix Script**
```powershell
.\fix-signup-error.ps1
```

**Option C: Temporarily Disable Redis**
```powershell
# Use the test configuration
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.config.location=classpath:/application-signup-test.properties
```

### Step 2: Restart Application Cleanly

```powershell
# Stop any running Java processes
taskkill /F /IM java.exe

# Clean build and start
mvn clean compile
mvn spring-boot:run
```

---

## 🧪 Test the Fix

### 1. Verify Services
```powershell
# Check Redis
docker exec redis redis-cli ping

# Check PostgreSQL
$env:PGPASSWORD="NikhitaMumbai123*"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c "SELECT 1;"
```

### 2. Test Signup API
```powershell
# Test with PowerShell
.\test-signup.ps1

# Or test with curl
curl -X POST http://localhost:8080/api/auth/signup `
  -H "Content-Type: application/json" `
  -d '{
    "companyName": "Test Company",
    "email": "test@example.com",
    "password": "password123",
    "confirmPassword": "password123",
    "accountType": "PROFESSIONAL"
  }'
```

### 3. Expected Success Response
```json
{
  "success": true,
  "message": "Account created successfully! You can now login.",
  "userId": 1
}
```

---

## 🔍 Debugging Steps

### Check Application Logs
Look for these success indicators:
```
Started OmoiservespareApplication in X seconds
Flyway successfully validated 5 migrations
```

### Check Endpoint Registration
The application should show:
```
Mapped "{[/api/auth/signup],methods=[POST]}" onto public ResponseEntity<SignupResponse> signup(SignupRequest)
```

### Check Security Configuration
Ensure `/api/auth/**` is permitted in SecurityConfig

---

## 🚨 Common Issues & Fixes

### Issue 1: "Docker not running"
**Fix**: Start Docker Desktop from Start menu, wait for it to fully load

### Issue 2: "Port 6379 already in use"
**Fix**: 
```powershell
# Find what's using the port
netstat -ano | findstr :6379

# Kill the process or use different port
docker run -d -p 6380:6379 --name redis redis:latest
```

### Issue 3: "Endpoint still not found"
**Fix**: 
```powershell
# Clean restart
taskkill /F /IM java.exe
mvn clean compile
mvn spring-boot:run
```

### Issue 4: "Database connection failed"
**Fix**: 
```powershell
# Check PostgreSQL service
Get-Service -Name postgresql*
Start-Service postgresql-x64-16
```

---

## 📋 Quick Fix Checklist

- [ ] Docker Desktop is running
- [ ] Redis container is running (`docker ps`)
- [ ] PostgreSQL service is running
- [ ] No Java processes from previous runs
- [ ] Clean compilation successful
- [ ] Application starts without Redis errors
- [ ] Signup endpoint responds

---

## 🎯 Recommended Fix Order

### 1. Use the Automated Fix
```powershell
.\fix-signup-error.ps1
```

### 2. Start Application
```powershell
mvn spring-boot:run
```

### 3. Test Signup
```powershell
.\test-signup.ps1
```

### 4. If Still Failing, Use Test Config
```powershell
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.config.location=classpath:/application-signup-test.properties
```

---

## 📊 Success Indicators

### Backend Console Should Show:
```
✅ No Redis connection errors
✅ "Started OmoiservespareApplication"
✅ "Flyway successfully validated 5 migrations"
✅ No "No static resource" errors
```

### Frontend Should Show:
```
✅ No 500 errors
✅ Success message: "Account created successfully! 🎉"
✅ Redirect to login page
```

### Database Should Have:
```sql
SELECT * FROM users WHERE email = 'your-test-email@example.com';
-- Should return the new user record
```

---

## 🔄 Alternative Approach

If the main approach fails, try this minimal test:

### 1. Stop Everything
```powershell
taskkill /F /IM java.exe
docker stop redis
```

### 2. Start Only Database
```powershell
# Ensure PostgreSQL is running
Get-Service -Name postgresql*
```

### 3. Use Test Configuration
```powershell
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.config.location=classpath:/application-signup-test.properties
```

### 4. Test Signup
```powershell
.\test-signup.ps1
```

---

## 📞 If Still Not Working

### Collect Debug Info:
```powershell
# 1. Check services
.\check-services.ps1 > debug-services.txt

# 2. Try startup with logs
mvn spring-boot:run > debug-startup.txt 2>&1

# 3. Test API
.\test-signup.ps1 > debug-api.txt 2>&1
```

### Look for:
- Redis connection errors
- Endpoint mapping issues
- Security configuration problems
- Database connection issues

---

**Status**: Ready to fix! Run `.\fix-signup-error.ps1` to start the automated fix process.