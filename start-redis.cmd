@echo off
echo ========================================
echo Starting Redis for Omoikane Backend
echo ========================================
echo.

echo Checking if Docker is running...
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running
    echo.
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)
echo [OK] Docker is running
echo.

echo Checking if Redis container exists...
docker ps -a --filter "name=redis" --format "{{.Names}}" | findstr /C:"redis" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Redis container exists
    echo Starting Redis container...
    docker start redis >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Redis started successfully
    ) else (
        echo [ERROR] Failed to start Redis
        pause
        exit /b 1
    )
) else (
    echo [INFO] Creating new Redis container...
    docker run -d -p 6379:6379 --name redis --restart unless-stopped redis:latest >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Redis container created and started
    ) else (
        echo [ERROR] Failed to create Redis container
        pause
        exit /b 1
    )
)

echo.
echo Testing Redis connection...
timeout /t 2 /nobreak >nul
docker exec redis redis-cli ping >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Redis is responding
) else (
    echo [WARNING] Redis may not be ready yet
)

echo.
echo ========================================
echo Redis is ready!
echo ========================================
echo.
echo You can now run: mvnw.cmd spring-boot:run
echo.
pause
