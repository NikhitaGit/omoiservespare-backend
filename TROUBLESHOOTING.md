# 🔧 Troubleshooting Guide

## Common Startup Errors & Solutions

---

## Error 1: Redis Connection Failed

### Symptoms:
```
Unable to connect to Redis at localhost:6379
Connection refused
```

### Solution A: Start Redis
```cmd
docker run -d -p 6379:6379 --name redis redis:latest
```

### Solution B: Start Docker Desktop
1. Open Docker Desktop from Start menu
2. Wait for it to fully start
3. Then run the Redis command above

### Solution C: Temporarily Disable Redis
```cmd
# Use the no-redis profile
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.config.location=classpath:/application-no-redis.properties
```

---

## Error 2: Database Connection Failed

### Symptoms:
```
Connection to localhost:5432 refused
org.postgresql.util.PSQLException
```

### Solution:
1. Check if PostgreSQL is running:
   ```powershell
   Get-Service -Name postgresql*
   ```

2. If stopped, start it:
   ```powershell
   Start-Service postgresql-x64-16
   ```

3. Verify database exists:
   ```powershell
   $env:PGPASSWORD="NikhitaMumbai123*"
   & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -l
   ```

4. If database doesn't exist:
   ```powershell
   $env:PGPASSWORD="NikhitaMumbai123*"
   & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE omoiservespare_db;"
   ```

---

## Error 3: Port 8080 Already in Use

### Symptoms:
```
Port 8080 is already in use
Web server failed to start
```

### Solution:
```powershell
# Find what's using port 8080
netstat -ano | findstr :8080

# Kill the process (replace <PID> with actual number)
taskkill /PID <PID> /F

# Or change the port in application.properties
server.port=8081
```

---

## Error 4: Flyway Migration Failed

### Symptoms:
```
FlywayException: Validate failed
Migration checksum mismatch
```

### Solution:
```sql
-- Connect to database
psql -U postgres -d omoiservespare_db

-- Drop and recreate
DROP DATABASE omoiservespare_db;
CREATE DATABASE omoiservespare_db;
\q
```

Then restart the application.

---

## Error 5: Class Not Found / Compilation Error

### Symptoms:
```
ClassNotFoundException
NoClassDefFoundError
```

### Solution:
```cmd
# Clean and rebuild
mvn clean install

# Or
.\mvnw.cmd clean install
```

---

## Error 6: SendGrid/Twilio API Error

### Symptoms:
```
Failed to send OTP email
Twilio authentication failed
```

### Solution:
This is OK! The application will still work. OTP will be printed to console:
```
🔐 OTP GENERATED FOR: user@example.com
📧 OTP CODE: 1234
```

Just use the OTP from console.

---

## Error 7: Async Method Not Working

### Symptoms:
```
@Async method running synchronously
Login still slow
```

### Solution:
Verify `@EnableAsync` is present in `OmoiservespareApplication.java`:
```java
@SpringBootApplication
@EnableScheduling
@EnableAsync  // ← This must be present
public class OmoiservespareApplication {
```

---

## Error 8: Docker Not Running

### Symptoms:
```
Cannot connect to Docker daemon
Is the docker daemon running?
```

### Solution:
1. Open Docker Desktop from Start menu
2. Wait for whale icon in system tray
3. Check status: `docker ps`

---

## Error 9: Maven Build Failed

### Symptoms:
```
BUILD FAILURE
Compilation error
```

### Solution:
```cmd
# Check Java version
java -version
# Should be 17

# Clean and compile
mvn clean compile

# Check for errors in output
```

---

## Error 10: Application Starts But Crashes

### Symptoms:
Application starts then immediately stops

### Solution:
Check logs for:
1. Database connection
2. Redis connection
3. Port conflicts
4. Missing dependencies

---

## 🔍 Diagnostic Commands

### Check All Services
```powershell
.\check-services.ps1
```

### Check Compilation
```cmd
mvn clean compile
```

### Check Database
```powershell
$env:PGPASSWORD="NikhitaMumbai123*"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c "SELECT 1;"
```

### Check Redis
```cmd
docker exec redis redis-cli ping
```

### Check Port
```cmd
netstat -ano | findstr :8080
```

---

## 🚀 Quick Fixes

### If Nothing Works:

1. **Stop everything:**
   ```cmd
   # Stop any running Java processes
   taskkill /F /IM java.exe
   
   # Stop Redis
   docker stop redis
   ```

2. **Start fresh:**
   ```cmd
   # Start Docker Desktop
   # Wait for it to be ready
   
   # Start Redis
   docker start redis
   # Or create new: docker run -d -p 6379:6379 --name redis redis:latest
   
   # Start application
   .\start-with-logs.cmd
   ```

3. **Check logs carefully** for the actual error

---

## 📋 Pre-Flight Checklist

Before running `mvn spring-boot:run`:

- [ ] Docker Desktop is running
- [ ] Redis container is running (`docker ps`)
- [ ] PostgreSQL service is running
- [ ] Database `omoiservespare_db` exists
- [ ] Port 8080 is free
- [ ] No compilation errors (`mvn compile`)

---

## 🆘 Still Having Issues?

### Collect This Information:

1. **Error message** (full stack trace)
2. **Service status:**
   ```powershell
   .\check-services.ps1
   ```
3. **Java version:**
   ```cmd
   java -version
   ```
4. **Maven version:**
   ```cmd
   mvn -version
   ```
5. **Application logs** (last 50 lines)

---

## 📞 Common Error Patterns

| Error Message | Likely Cause | Quick Fix |
|---------------|--------------|-----------|
| "Connection refused" | Service not running | Start the service |
| "Port already in use" | Another app using port | Kill process or change port |
| "Authentication failed" | Wrong password | Check application.properties |
| "Database does not exist" | DB not created | Create database |
| "ClassNotFoundException" | Build issue | `mvn clean install` |
| "Timeout" | Service too slow | Check Redis/DB connection |

---

## 🎯 Most Common Issue

**Redis not running** is the #1 cause of startup failures.

**Quick fix:**
```cmd
docker run -d -p 6379:6379 --name redis redis:latest
```

---

## 📝 Logging Tips

### Enable More Logging:
Add to `application.properties`:
```properties
logging.level.root=INFO
logging.level.com.omoikaneinnovations=DEBUG
logging.level.org.springframework=DEBUG
```

### View Logs:
Logs appear in the terminal where you ran `mvn spring-boot:run`

---

**Need more help?** Run `.\check-services.ps1` and share the output.
