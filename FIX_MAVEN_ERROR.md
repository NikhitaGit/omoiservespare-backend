# Fix Maven Error - Quick Guide

## The Error You're Seeing

```
[ERROR] No plugin found for prefix 'spring-boot'
[ERROR] The goal you specified requires a project to execute but there is no POM in this directory
```

## The Problem

You're running Maven commands from the **WRONG DIRECTORY**.

**Current location:** `C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare`  
**Correct location:** `C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare`

## Quick Fix (Choose One)

### Option 1: Use the Start Script (Easiest)
```powershell
# From the root directory (where you are now)
.\start-backend-from-root.ps1
```

This script automatically:
- Navigates to the correct directory
- Checks if port 8080 is in use
- Starts the backend

### Option 2: Navigate Manually
```powershell
# Step 1: Go to project directory
cd omoiservespare

# Step 2: Start backend
.\mvnw spring-boot:run
```

### Option 3: Use Maven Wrapper from Root
```powershell
# Stay in root directory
cd omoiservespare
.\mvnw spring-boot:run
```

## Step-by-Step Instructions

### 1. Check Your Current Directory
```powershell
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare> pwd

# You should see:
# Path
# ----
# C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare
```

### 2. Navigate to Project Directory
```powershell
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare> cd omoiservespare
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare>
```

### 3. Verify pom.xml Exists
```powershell
PS C:\...\omoiservespare> dir pom.xml

# Should show the file
```

### 4. Start Backend
```powershell
PS C:\...\omoiservespare> .\mvnw spring-boot:run
```

## What You Should See

When starting successfully:
```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.x.x)

...
Started OmoiservespareApplication in X.XXX seconds
```

## Common Mistakes

### ❌ Wrong: Running from Root
```powershell
PS C:\...\OmoiServespare> mvn spring-boot:run
# Error: No POM in this directory
```

### ✅ Correct: Running from Project Directory
```powershell
PS C:\...\OmoiServespare> cd omoiservespare
PS C:\...\OmoiServespare\omoiservespare> .\mvnw spring-boot:run
# Success!
```

## Directory Structure

```
OmoiServespare/                    ← You are HERE (wrong place)
│
├── omoiservespare/                ← You need to be HERE
│   ├── pom.xml                    ← Maven needs this file
│   ├── mvnw                       ← Maven wrapper
│   ├── mvnw.cmd                   ← Maven wrapper (Windows)
│   └── src/
│       └── main/
│           └── java/
│
├── .metadata/
├── .vscode/
└── start-backend-from-root.ps1    ← Use this script!
```

## After Backend Starts

1. **Check if running:**
   - Open browser: `http://localhost:8080`
   - Or test: `curl http://localhost:8080`

2. **Test API:**
   ```powershell
   # In a new terminal
   curl http://localhost:8080/api/health
   ```

3. **View logs:**
   - Check the terminal where backend is running
   - Look for "Started OmoiservespareApplication"

## Troubleshooting

### Issue: Port 8080 already in use
```powershell
# Find process
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /PID <PID> /F

# Or use the script (it does this automatically)
.\start-backend-from-root.ps1
```

### Issue: mvnw not found
```powershell
# Make sure you're in omoiservespare directory
cd omoiservespare

# Check if file exists
dir mvnw*

# If not found, use mvn instead
mvn spring-boot:run
```

### Issue: Java not found
```powershell
# Check Java version
java -version

# Should show Java 17 or higher
# If not installed, download from: https://adoptium.net/
```

## Summary

**The Fix:**
```powershell
# From root directory
cd omoiservespare
.\mvnw spring-boot:run
```

**Or use the script:**
```powershell
# From root directory
.\start-backend-from-root.ps1
```

That's it! The backend will start on `http://localhost:8080`
