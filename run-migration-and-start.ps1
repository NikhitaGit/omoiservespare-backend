# Run Migration and Start Backend

Write-Host "🔄 Starting Backend with Flyway Migration" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flyway will run automatically when Spring Boot starts!" -ForegroundColor Yellow
Write-Host ""

# Check if PostgreSQL is running
Write-Host "Checking PostgreSQL connection..." -ForegroundColor Yellow
try {
    $null = Test-NetConnection -ComputerName localhost -Port 5432 -WarningAction SilentlyContinue -ErrorAction Stop
    Write-Host "✅ PostgreSQL is running on port 5432" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgreSQL is not running!" -ForegroundColor Red
    Write-Host "Please start PostgreSQL first" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Cyan
Write-Host "Flyway will automatically run V13__unified_auth_system.sql" -ForegroundColor Gray
Write-Host ""

# Start Spring Boot
mvn spring-boot:run
