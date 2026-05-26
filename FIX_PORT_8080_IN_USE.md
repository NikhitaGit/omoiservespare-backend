# Fix "Port 8080 Already in Use" Error

## The Error

```
Web server failed to start. Port 8080 was already in use.
```

## Quick Fix (Choose One)

### Option 1: Use the Kill Script (Easiest)
```powershell
.\kill-port-8080.ps1
```

Then start backend:
```powershell
.\mvnw spring-boot:run
```

### Option 2: Manual Kill
```powershell
# Step 1: Find process using port 8080
netstat -ano | findstr :8080

# Step 2: Kill the process (replace PID with actual number)
taskkill /F /PID <PID>

# Step 3: Start backend
.\mvnw spring-boot:run
```

### Option 3: One Command
```powershell
# Kill and start in one go
netstat -ano | findstr :8080 | ForEach-Object { $pid = ($_ -split '\s+')[-1]; taskkill /F /PID $pid }; .\mvnw spring-boot:run
```

## Step-by-Step Instructions

### Step 1: Find the Process
```powershell
PS C:\...\omoiservespare> netstat -ano | findstr :8080

# Output example:
# TCP    0.0.0.0:8080           0.0.0.0:0              LISTENING       12345
# TCP    [::]:8080              [::]:0                 LISTENING       12345
```

The last number (12345) is the Process ID (PID).

### Step 2: Kill the Process
```powershell
PS C:\...\omoiservespare> taskkill /F /PID 12345

# Output:
# SUCCESS: The process with PID 12345 has been terminated.
```

### Step 3: Verify Port is Free
```powershell
PS C:\...\omoiservespare> netstat -ano | findstr :8080

# Should return nothing (port is free)
```

### Step 4: Start Backend
```powershell
PS C:\...\omoiservespare> .\mvnw spring-boot:run
```

## Why This Happens

1. **Previous instance still running** - You started the backend before and it's still running
2. **Another application using port 8080** - Tomcat, another Spring Boot app, or other service
3. **Crashed but not cleaned up** - Application crashed but process didn't terminate

## Alternative: Change Port

If you want to use a different port instead:

### Option A: Temporary (Command Line)
```powershell
.\mvnw spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
```

### Option B: Permanent (application.properties)
Edit `src/main/resources/application.properties`:
```properties
server.port=8081
```

Then update your frontend to use the new port:
```javascript
// Change from
http://localhost:8080/api/...

// To
http://localhost:8081/api/...
```

## Common Scenarios

### Scenario 1: You Started Backend Twice
```powershell
# Terminal 1
.\mvnw spring-boot:run  # Started here

# Terminal 2
.\mvnw spring-boot:run  # Error: Port already in use
```

**Solution:** Close Terminal 1 or press Ctrl+C to stop the first instance.

### Scenario 2: Backend Crashed But Process Remains
```powershell
# Backend crashed but Java process still running
```

**Solution:** Use the kill script or manually kill the process.

### Scenario 3: Another Application Using Port 8080
```powershell
# Tomcat, XAMPP, or another service using port 8080
```

**Solution:** Stop that application or change your backend port.

## Verify Backend is Running

After starting successfully:

### Check 1: Look for Success Message
```
Started OmoiservespareApplication in X.XXX seconds
```

### Check 2: Test in Browser
```
http://localhost:8080
```

### Check 3: Test API Endpoint
```powershell
curl http://localhost:8080/api/health
```

### Check 4: Check Port is in Use
```powershell
netstat -ano | findstr :8080
# Should show your Java process
```

## Troubleshooting

### Issue: Can't Find Process ID
```powershell
# Use this to see all Java processes
tasklist | findstr java

# Kill all Java processes (use with caution!)
taskkill /F /IM java.exe
```

### Issue: Access Denied When Killing Process
```powershell
# Run PowerShell as Administrator
# Right-click PowerShell → Run as Administrator

# Then try again
taskkill /F /PID <PID>
```

### Issue: Port Still in Use After Killing
```powershell
# Wait a few seconds
Start-Sleep -Seconds 5

# Check again
netstat -ano | findstr :8080

# If still in use, restart your computer (last resort)
```

## Prevention

### Always Stop Backend Properly
```powershell
# In the terminal where backend is running
# Press: Ctrl + C

# Wait for:
# "Stopped OmoiservespareApplication"
```

### Use the Kill Script Before Starting
```powershell
# Make it a habit
.\kill-port-8080.ps1
.\mvnw spring-boot:run
```

### Create a Combined Start Script
```powershell
# Save as start-backend-safe.ps1
.\kill-port-8080.ps1
Start-Sleep -Seconds 2
.\mvnw spring-boot:run
```

## Summary

**Quick Fix:**
```powershell
# Step 1: Kill process
.\kill-port-8080.ps1

# Step 2: Start backend
.\mvnw spring-boot:run
```

**Manual Fix:**
```powershell
# Find PID
netstat -ano | findstr :8080

# Kill process (replace 12345 with actual PID)
taskkill /F /PID 12345

# Start backend
.\mvnw spring-boot:run
```

That's it! Port 8080 will be free and backend will start successfully.
