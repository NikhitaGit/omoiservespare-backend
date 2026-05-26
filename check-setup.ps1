# Setup Verification Script for Windows
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Omoikane Backend Setup Checker" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check Java
Write-Host "Checking Java..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java installed: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java not found. Please install Java 17" -ForegroundColor Red
}

# Check PostgreSQL
Write-Host "`nChecking PostgreSQL..." -ForegroundColor Yellow
try {
    $pgVersion = psql --version 2>&1
    Write-Host "✅ PostgreSQL installed: $pgVersion" -ForegroundColor Green
    
    # Try to connect
    Write-Host "Testing database connection..." -ForegroundColor Yellow
    $env:PGPASSWORD = "NikhitaMumbai123*"
    $dbCheck = psql -U postgres -d omoiservespare_db -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database 'omoiservespare_db' exists and is accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Database 'omoiservespare_db' not found or not accessible" -ForegroundColor Red
        Write-Host "   Run: psql -U postgres -c 'CREATE DATABASE omoiservespare_db;'" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ PostgreSQL not found" -ForegroundColor Red
    Write-Host "   Install from: https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
}

# Check Redis
Write-Host "`nChecking Redis..." -ForegroundColor Yellow
try {
    $redisCheck = redis-cli ping 2>&1
    if ($redisCheck -eq "PONG") {
        Write-Host "✅ Redis is running" -ForegroundColor Green
    } else {
        Write-Host "❌ Redis not responding" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Redis not found" -ForegroundColor Red
    Write-Host "   Options:" -ForegroundColor Yellow
    Write-Host "   1. Install Memurai: https://www.memurai.com/" -ForegroundColor Yellow
    Write-Host "   2. Use Docker: docker run -d -p 6379:6379 redis" -ForegroundColor Yellow
}

# Check Port 8080
Write-Host "`nChecking port 8080..." -ForegroundColor Yellow
$portCheck = netstat -ano | Select-String ":8080"
if ($portCheck) {
    Write-Host "⚠️  Port 8080 is in use" -ForegroundColor Yellow
    Write-Host "   Process using port 8080:" -ForegroundColor Yellow
    Write-Host "   $portCheck" -ForegroundColor Gray
} else {
    Write-Host "✅ Port 8080 is available" -ForegroundColor Green
}

# Check Maven Wrapper
Write-Host "`nChecking Maven wrapper..." -ForegroundColor Yellow
if (Test-Path ".\mvnw.cmd") {
    Write-Host "✅ Maven wrapper found" -ForegroundColor Green
} else {
    Write-Host "❌ Maven wrapper not found" -ForegroundColor Red
}

# Summary
Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Install any missing components (marked with ❌)" -ForegroundColor White
Write-Host "2. Create database if needed" -ForegroundColor White
Write-Host "3. Run: .\mvnw.cmd spring-boot:run" -ForegroundColor White
Write-Host ""
Write-Host "For detailed setup instructions, see: SETUP_GUIDE_WINDOWS.md" -ForegroundColor Cyan
