# Port 8080 Error - Quick Solution

## The Error You're Seeing

```
APPLICATION FAILED TO START
Web server failed to start. Port 8080 was already in use.
```

## Instant Fix (One Command)

```powershell
.\kill-port-8080.ps1
```

Then start backend:
```powershell
.\mvnw spring-boot:run
```

## Or Use Safe Start (Recommended)

```powershell
.\start-backend-safe.ps1
```

This script automatically:
1. Checks if port 8080 is in use
2. Kills any process using it
3. Starts the backend

## Manual Fix (If Scripts Don't Work)

### Step 1: Find Process
```powershell
netstat -ano | findstr :8080
```

Output example:
```
TCP    0.0.0.0:8080    0.0.0.0:0    LISTENING    12345
```

The last number (12345) is the Process ID.

### Step 2: Kill Process
```powershell
taskkill /F /PID 12345
```

Replace `12345` with your actual PID.

### Step 3: Start Backend
```powershell
.\mvnw spring-boot:run
```

## Why This Happens

- You started the backend before and it's still running
- Backend crashed but process didn't terminate
- Another application is using port 8080

## Files Created to Help

| File | Purpose |
|------|---------|
| `kill-port-8080.ps1` | Kills process on port 8080 |
| `start-backend-safe.ps1` | Kills process + starts backend |
| `FIX_PORT_8080_IN_USE.md` | Detailed guide |
| `PORT_8080_ERROR_SOLUTION.md` | This file |

## Quick Commands

### Kill Port 8080
```powershell
.\kill-port-8080.ps1
```

### Safe Start
```powershell
.\start-backend-safe.ps1
```

### Check Port Status
```powershell
netstat -ano | findstr :8080
```

### Kill All Java Processes (Use with Caution)
```powershell
taskkill /F /IM java.exe
```

## After Fix

You should see:
```
Started OmoiservespareApplication in X.XXX seconds
```

Then test:
- Browser: `http://localhost:8080`
- API: `curl http://localhost:8080/api/health`

## Summary

**Easiest way:**
```powershell
.\start-backend-safe.ps1
```

**Manual way:**
```powershell
# Find PID
netstat -ano | findstr :8080

# Kill it (replace 12345)
taskkill /F /PID 12345

# Start backend
.\mvnw spring-boot:run
```

Done! Backend will start successfully on port 8080.
