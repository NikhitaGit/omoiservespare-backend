# Fix Signup Errors
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixing Signup Issues" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Checking Redis..." -ForegroundColor Yellow

# Check if Docker is running
try {
    $dockerCheck = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Docker is not running" -ForegroundColor Red
        Write-Host "  Please start Docker Desktop and try again" -ForegroundColor Yellow
        Write-Host ""
        pause
        exit 1
    }
    Write-Host "  ✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Docker error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Check Redis container
$redisContainer = docker ps --filter "name=redis" --format "{{.Names}}" 2>&1
if ($redisContainer -match "redis") {
    Write-Host "  ✅ Redis container exists" -ForegroundColor Green
    
    # Test Redis connection
    $redisPing = docker exec redis redis-cli ping 2>&1
    if ($redisPing -match "PONG") {
        Write-Host "  ✅ Redis is responding" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Redis not responding, restarting..." -ForegroundColor Yellow
        docker restart redis >$null 2>&1
        Start-Sleep -Seconds 3
        Write-Host "  ✅ Redis restarted" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  Redis container not found, creating..." -ForegroundColor Yellow
    docker run -d -p 6379:6379 --name redis --restart unless-stopped redis:latest >$null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Redis container created and started" -ForegroundColor Green
        Start-Sleep -Seconds 5
    } else {
        Write-Host "  ❌ Failed to create Redis container" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "[2/3] Stopping current application..." -ForegroundColor Yellow

# Kill any running Java processes (Spring Boot)
$javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
if ($javaProcesses) {
    Write-Host "  Stopping Java processes..." -ForegroundColor Gray
    $javaProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "  ✅ Java processes stopped" -ForegroundColor Green
} else {
    Write-Host "  ✅ No Java processes running" -ForegroundColor Green
}

Write-Host ""
Write-Host "[3/3] Starting application with clean build..." -ForegroundColor Yellow

Write-Host "  Cleaning and compiling..." -ForegroundColor Gray
$compileResult = mvn clean compile -q 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Compilation successful" -ForegroundColor Green
} else {
    Write-Host "  ❌ Compilation failed" -ForegroundColor Red
    Write-Host "  Error: $compileResult" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ready to Start Application" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Redis is running and ready" -ForegroundColor Green
Write-Host "Application compiled successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Now run:" -ForegroundColor White
Write-Host "  mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or use the startup script:" -ForegroundColor White
Write-Host "  .\start-all.cmd" -ForegroundColor Cyan
Write-Host ""