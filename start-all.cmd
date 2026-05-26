@echo off
echo ========================================
echo Omoikane Backend - Complete Startup
echo ========================================
echo.

REM Check Java
echo [1/4] Checking Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java not found
    pause
    exit /b 1
)
echo [OK] Java is installed
echo.

REM Check PostgreSQL
echo [2/4] Checking PostgreSQL...
"C:\Program Files\PostgreSQL\16\bin\psql.exe" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PostgreSQL not found
    pause
    exit /b 1
)
echo [OK] PostgreSQL is installed
echo.

REM Check Docker and start Redis
echo [3/4] Checking Docker and Redis...
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Docker is not running
    echo Please start Docker Desktop manually
    echo.
    echo Press any key when Docker is ready...
    pause >nul
)

echo Starting Redis...
docker ps -a --filter "name=redis" --format "{{.Names}}" | findstr /C:"redis" >nul 2>&1
if %errorlevel% equ 0 (
    docker start redis >nul 2>&1
    echo [OK] Redis started
) else (
    docker run -d -p 6379:6379 --name redis --restart unless-stopped redis:latest >nul 2>&1
    echo [OK] Redis container created
)
echo.

REM Wait for Redis
echo Waiting for Redis to be ready...
timeout /t 3 /nobreak >nul
echo.

REM Start Application
echo [4/4] Starting Application...
echo ========================================
echo.
echo Application is starting...
echo Press Ctrl+C to stop
echo.
echo ========================================
echo.

mvnw.cmd spring-boot:run

pause
