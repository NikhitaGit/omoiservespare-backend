# Fix Port 8080 Error - Complete Solution

## Current Situation
Your backend won't start because port 8080 is already occupied by another Java process.

## FASTEST SOLUTION (Choose One)

### Method 1: Kill All Java & Start (EASIEST)
Open PowerShell in the `omoiservespare` folder and run:

```powershell
taskkill /F /IM java.exe ; Start-Sleep -Seconds 3 ; .\mvnw spring-boot:run
```

This single command will:
- Kill all Java processes
- Wait 3 seconds
- Start your backend

### Method 2: Use CMD Script
```cmd
cd omoiservespare
.\kill-and-start.cmd
```

### Method 3: Use PowerShell Script
```powershell
cd omoiservespare
.\start.ps1
```

## Alternative: Change Port to 8081

If you need to keep the other Java process running:

1. The port is already configured in `application.properties` - just uncomment line 2:

**Current:**
```properties
# server.port=8081
server.port=8080
```

**Change to:**
```properties
server.port=8081
# server.port=8080
```

2. Start backend:
```powershell
.\mvnw spring-boot:run
```

3. Update your frontend API base URL from:
```javascript
const API_BASE_URL = 'http://localhost:8080/api';
```
to:
```javascript
const API_BASE_URL = 'http://localhost:8081/api';
```

## Verify Backend Started

You should see this message:
```
Started OmoiservespareApplication in X.XXX seconds (process running with PID XXXX)
```

Test it by opening: `http://localhost:8080/api/health` (or 8081 if you changed port)

## Next Steps After Backend Starts

1. ✅ Backend is running
2. 📝 Apply frontend fixes from `APPLY_FRONTEND_FIXES.md`
3. 🧪 Test the ticket system:
   - Login to get JWT token
   - Raise a ticket (phone should auto-fill)
   - Check user dashboard (tickets should display)
   - Check agent dashboard (tickets should display)

## Still Having Issues?

If the port is still in use after killing Java processes:

```powershell
# Find what's using port 8080
netstat -ano | findstr :8080

# You'll see output like:
# TCP    0.0.0.0:8080    0.0.0.0:0    LISTENING    12345

# Kill that specific process (replace 12345 with your PID)
taskkill /F /PID 12345
```

Or simply restart your computer to clear all processes.
