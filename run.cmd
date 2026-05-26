@echo off
echo ========================================
echo Starting Omoikane Backend Application
echo ========================================
echo.

echo Checking prerequisites...
echo.

REM Check Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java not found. Please install Java 17
    pause
    exit /b 1
)
echo [OK] Java found

REM Check PostgreSQL
psql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] PostgreSQL not found in PATH
    echo Please ensure PostgreSQL is installed and running
    echo.
)

REM Check Redis
redis-cli ping >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Redis not responding
    echo The application may fail if Redis is required
    echo.
)

echo.
echo Starting application...
echo Press Ctrl+C to stop
echo.

mvnw.cmd spring-boot:run

pause
