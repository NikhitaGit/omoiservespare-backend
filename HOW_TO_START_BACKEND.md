# How to Start Your Backend - IMPORTANT

## ⚠️ Common Mistake

You tried to run:
```powershell
PS C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare> mvn spring-boot:run
```

This failed because you were in the **WRONG DIRECTORY**. You were in the parent folder, not inside the `omoiservespare` project folder.

## ✅ Correct Way to Start

### Option 1: Change Directory First (Manual)
```powershell
# Step 1: Navigate to the project folder
cd C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare

# Step 2: Start the application
mvn spring-boot:run
```

### Option 2: Use the Automated Script (RECOMMENDED)
```powershell
# Navigate to the project folder
cd C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare

# Run the startup script (handles port conflicts automatically)
./start-backend.ps1
```

## 🎯 Current Status

**YOUR APPLICATION IS ALREADY RUNNING!**

- **Status:** Running in background
- **Process ID:** 3
- **Port:** 8080
- **Started:** Successfully with coupon system fix applied

You don't need to start it again!

## 🔍 How to Check if Backend is Running

### Method 1: Check Port 8080
```powershell
netstat -ano | findstr :8080
```

If you see output like this, it's running:
```
TCP    0.0.0.0:8080           0.0.0.0:0              LISTENING       19952
```

### Method 2: Test an Endpoint
```powershell
curl http://localhost:8080/api/test/health
```

## 🛑 How to Stop the Backend

If you need to stop it:

### Method 1: Find and Kill Process
```powershell
# Find the process
netstat -ano | findstr :8080

# Kill it (replace PID with actual number)
taskkill /PID 19952 /F
```

### Method 2: If Running in Terminal
Press `Ctrl+C` in the terminal where it's running

## 🔄 How to Restart

```powershell
# Step 1: Stop the current process
netstat -ano | findstr :8080
taskkill /PID <PID_NUMBER> /F

# Step 2: Navigate to project folder
cd C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare

# Step 3: Start again
./start-backend.ps1
```

## 📁 Directory Structure

```
OmoiServespare/                          ← You were here (WRONG)
└── omoiservespare/                      ← You need to be here (CORRECT)
    ├── pom.xml                          ← Maven needs this file
    ├── src/
    ├── start-backend.ps1
    └── ...
```

## 💡 Quick Tips

1. **Always check your current directory** with `pwd` command
2. **Use the automated script** `./start-backend.ps1` - it handles everything
3. **Check if already running** before starting again
4. **The application is running NOW** - you can test your coupon system!

## 🧪 Test Your Running Application

Since it's already running, try these:

### Test Health Endpoint
```powershell
curl http://localhost:8080/api/test/health
```

### Test Coupon System (requires login)
1. Open your frontend at http://localhost:5173
2. Login to your application
3. Add items to cart
4. Apply a coupon (e.g., WELCOME200)
5. It should work now!

## ❓ Why Did Maven Fail?

The error you got:
```
No plugin found for prefix 'spring-boot'
```

This happens when:
1. You're not in the project directory (where `pom.xml` is)
2. Maven can't find the Spring Boot plugin configuration

**Solution:** Always run Maven commands from inside the `omoiservespare` folder where `pom.xml` exists.

---

## 🎉 Summary

- ✅ Your backend is ALREADY RUNNING on port 8080
- ✅ Coupon system is fixed and ready
- ✅ No need to start it again
- ✅ Just test your frontend now!
