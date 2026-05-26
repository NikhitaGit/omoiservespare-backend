# How to Start Backend Correctly

## The Problem

You're running Maven commands from the wrong directory:
```
Current directory: C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare
Project directory: C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare
```

The `pom.xml` file is inside the `omoiservespare` subdirectory, not at the root.

## Solution

### Option 1: Navigate to Project Directory (Recommended)
```powershell
# Change to the correct directory
cd omoiservespare

# Now run Maven
mvn spring-boot:run
```

### Option 2: Use Maven Wrapper (Recommended)
```powershell
# Change to project directory
cd omoiservespare

# Use Maven wrapper (works even without Maven installed)
.\mvnw spring-boot:run
```

### Option 3: Run from Root Directory
```powershell
# Stay in root directory but specify project path
cd C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare
mvn -f omoiservespare/pom.xml spring-boot:run
```

## Complete Steps

### Step 1: Navigate to Project Directory
```powershell
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare> cd omoiservespare
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare>
```

### Step 2: Verify pom.xml Exists
```powershell
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare> dir pom.xml

# Should show:
# Mode                 LastWriteTime         Length Name
# ----                 -------------         ------ ----
# -a----        12/04/2026     20:00           xxxx pom.xml
```

### Step 3: Start Backend
```powershell
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare> .\mvnw spring-boot:run
```

## Quick Start Script

I've created a script to start the backend from anywhere:

```powershell
# Run this from the root directory
.\start-backend-from-root.ps1
```

Or create your own:
```powershell
# Save as start-backend.ps1
cd omoiservespare
.\mvnw spring-boot:run
```

## Verify Backend is Running

After starting, you should see:
```
Started OmoiservespareApplication in X.XXX seconds
```

Then test:
```powershell
# In a new terminal
curl http://localhost:8080/api/health
```

Or open in browser:
```
http://localhost:8080
```

## Common Issues

### Issue 1: "mvn: command not found"
**Solution:** Use Maven wrapper instead:
```powershell
.\mvnw spring-boot:run
```

### Issue 2: "No POM in this directory"
**Solution:** You're in the wrong directory. Navigate to `omoiservespare`:
```powershell
cd omoiservespare
```

### Issue 3: Port 8080 already in use
**Solution:** Kill the existing process:
```powershell
# Find process using port 8080
netstat -ano | findstr :8080

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

## Directory Structure

Your project structure is:
```
OmoiServespare/                    ← You are here (ROOT)
├── omoiservespare/                ← Project is here
│   ├── pom.xml                    ← Maven config
│   ├── mvnw                       ← Maven wrapper
│   ├── mvnw.cmd                   ← Maven wrapper (Windows)
│   └── src/
│       └── main/
│           └── java/
│               └── ...
├── .metadata/
├── .vscode/
└── other files...
```

You need to be inside `omoiservespare/` to run Maven commands.

## Summary

**Wrong:**
```powershell
PS C:\...\OmoiServespare> mvn spring-boot:run
# Error: No POM in this directory
```

**Correct:**
```powershell
PS C:\...\OmoiServespare> cd omoiservespare
PS C:\...\OmoiServespare\omoiservespare> .\mvnw spring-boot:run
# Success!
```
