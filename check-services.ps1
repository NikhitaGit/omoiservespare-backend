# Check all required services
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Checking Required Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check PostgreSQL
Write-Host "[1/3] PostgreSQL..." -ForegroundColor Yellow
try {
    $env:PGPASSWORD = "NikhitaMumbai123*"
    $result = & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ PostgreSQL is running" -ForegroundColor Green
        Write-Host "  ✅ Database 'omoiservespare_db' exists" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Database connection failed" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ PostgreSQL error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Check Redis
Write-Host "[2/3] Redis..." -ForegroundColor Yellow
try {
    $dockerRunning = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker is running" -ForegroundColor Green
        
        $redisContainer = docker ps --filter "name=redis" --format "{{.Names}}" 2>&1
        if ($redisContainer -match "redis") {
            Write-Host "  ✅ Redis container is running" -ForegroundColor Green
            
            # Test Redis connection
            $redisPing = docker exec redis redis-cli ping 2>&1
            if ($redisPing -match "PONG") {
                Write-Host "  ✅ Redis is responding" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  Redis not responding" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ❌ Redis container not found" -ForegroundColor Red
            Write-Host "  Run: docker run -d -p 6379:6379 --name redis redis:latest" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ Docker is not running" -ForegroundColor Red
        Write-Host "  Please start Docker Desktop" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ Docker error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Check Port 8080
Write-Host "[3/3] Port 8080..." -ForegroundColor Yellow
$portInUse = netstat -ano | Select-String ":8080" | Select-Object -First 1
if ($portInUse) {
    Write-Host "  ⚠️  Port 8080 is in use" -ForegroundColor Yellow
    Write-Host "  $portInUse" -ForegroundColor Gray
    Write-Host "  You may need to kill the process" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Port 8080 is available" -ForegroundColor Green
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If all checks passed, try running:" -ForegroundColor White
Write-Host "  mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or use the startup script:" -ForegroundColor White
Write-Host "  .\start-all.cmd" -ForegroundColor Cyan
Write-Host ""
