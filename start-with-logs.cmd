@echo off
echo ========================================
echo Starting Application with Detailed Logs
echo ========================================
echo.

echo Checking services...
echo.

REM Check Docker
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running
    echo Please start Docker Desktop first
    echo.
    pause
    exit /b 1
)
echo [OK] Docker is running

REM Check/Start Redis
docker ps --filter "name=redis" --format "{{.Names}}" | findstr /C:"redis" >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Starting Redis...
    docker run -d -p 6379:6379 --name redis redis:latest >nul 2>&1
    timeout /t 3 /nobreak >nul
)
echo [OK] Redis is ready

echo.
echo ========================================
echo Starting Spring Boot Application
echo ========================================
echo.
echo If you see errors, they will appear below:
echo.

REM Start with Maven
mvnw.cmd spring-boot:run

pause
