# Java 17 Compilation Quick Guide

## Problem
Your system has both Java 17 and Java 25 installed. Kiro's terminal picks up Java 25 by default, but this project requires Java 17.

## Solution Applied

### 1. Fixed OrderStatus Enum
Added missing `PENDING` status to `OrderStatus.java`

### 2. Updated Lombok
- Version: **1.18.36** (latest, compatible with Java 17)
- Configured annotation processor in `pom.xml`

### 3. Created Helper Scripts

## How to Compile

### Option 1: Use the Fix Script (Recommended)
```powershell
powershell -ExecutionPolicy Bypass -File FIX_AND_COMPILE.ps1
```

### Option 2: Use the Compile Script
```powershell
powershell -ExecutionPolicy Bypass -File compile-with-java17.ps1
```

### Option 3: Run Any Maven Command with Java 17
```powershell
# Install
powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 install

# Clean and compile
powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 clean compile

# Package
powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 package
```

## How to Run Application

```powershell
powershell -ExecutionPolicy Bypass -File start-with-java17.ps1
```

## ⚠️ Important Notes

1. **Never use `mvn` directly** - It will use Java 25 and fail
2. **Always use the provided scripts** - They force Java 17
3. **If you see Lombok errors** - You're using the wrong Java version

## Verification

Check which Java is being used:
```powershell
java -version
```

Should show: `java version "17.0.12"`

## Files Created

- `FIX_AND_COMPILE.ps1` - Complete fix and compile
- `compile-with-java17.ps1` - Compile only
- `mvn-java17.ps1` - Run any Maven command with Java 17
- `start-with-java17.ps1` - Start application with Java 17

## Quick Commands

```powershell
# Fix and compile
powershell -ExecutionPolicy Bypass -File FIX_AND_COMPILE.ps1

# Start application
powershell -ExecutionPolicy Bypass -File start-with-java17.ps1

# Run tests
powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 test

# Create JAR
powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 package
```
