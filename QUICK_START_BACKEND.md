# Quick Start Backend - Port 8080 Issue Fixed

## The Problem
Port 8080 is already in use by another Java process, preventing the backend from starting.

## Solution Options

### Option 1: Use the Simple CMD Script (RECOMMENDED)
```cmd
cd omoiservespare
.\kill-and-start.cmd
```

This will:
1. Kill all Java processes (including the one on port 8080)
2. Wait 3 seconds
3. Start the backend

### Option 2: Use PowerShell Script
```powershell
cd omoiservespare
.\start.ps1
```

### Option 3: Manual Commands
If scripts don't work, run these commands one by one:

```powershell
# Step 1: Kill all Java processes
taskkill /F /IM java.exe

# Step 2: Wait a few seconds
Start-Sleep -Seconds 3

# Step 3: Start backend
.\mvnw spring-boot:run
```

### Option 4: Change the Port
If you want to keep the other Java process running, change the backend port:

1. Open `src/main/resources/application.properties`
2. Add this line:
```properties
server.port=8081
```
3. Start backend normally: `.\mvnw spring-boot:run`
4. Update frontend API calls to use `http://localhost:8081` instead of `http://localhost:8080`

## After Backend Starts Successfully

You should see:
```
Started OmoiservespareApplication in X.XXX seconds
```

Then you can:
1. Test the backend: Open browser to `http://localhost:8080/api/health` (or 8081 if you changed port)
2. Apply the frontend fixes from `APPLY_FRONTEND_FIXES.md`
3. Test the complete ticket system

## Troubleshooting

If you still get port 8080 error:
1. Check what's using the port:
```powershell
netstat -ano | findstr :8080
```

2. Note the PID (last column) and kill it specifically:
```powershell
taskkill /F /PID <PID_NUMBER>
```

3. Or restart your computer to clear all processes
