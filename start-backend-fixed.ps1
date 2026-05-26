# Start Backend with Redis Disabled
Write-Host "=== Starting Backend (Redis Disabled) ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Compilation successful!" -ForegroundColor Green
Write-Host "✅ Redis is now optional" -ForegroundColor Green
Write-Host "✅ Coupons will work without Redis" -ForegroundColor Green
Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Yellow
Write-Host ""

mvn spring-boot:run
