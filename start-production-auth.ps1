# Start Production Authentication System

Write-Host "🚀 Starting Production Authentication System" -ForegroundColor Cyan
Write-Host ""

# Check PostgreSQL
Write-Host "Checking PostgreSQL..." -ForegroundColor Yellow
try {
    $null = Test-NetConnection -ComputerName localhost -Port 5432 -WarningAction SilentlyContinue -ErrorAction Stop
    Write-Host "✅ PostgreSQL is running" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgreSQL is not running!" -ForegroundColor Red
    Write-Host "Please start PostgreSQL first" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "📋 What will happen:" -ForegroundColor Cyan
Write-Host "  1. Compile Java code" -ForegroundColor White
Write-Host "  2. Run Flyway migration V13 (unified auth)" -ForegroundColor White
Write-Host "  3. Start Spring Boot on port 8080" -ForegroundColor White
Write-Host "  4. Create test accounts (vendor, admin)" -ForegroundColor White
Write-Host ""
Write-Host "Starting backend..." -ForegroundColor Yellow
Write-Host ""

# Start Spring Boot
mvn spring-boot:run
