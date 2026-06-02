# Restart Backend to Fix Database Connection Timeout
# This script helps you restart the backend cleanly

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔧 Database Connection Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Problem Detected:" -ForegroundColor Yellow
Write-Host "  - Database connection pool has stale connections" -ForegroundColor White
Write-Host "  - Backend cannot communicate with PostgreSQL" -ForegroundColor White
Write-Host "  - OTP generation failing" -ForegroundColor White
Write-Host "  - Frontend timing out (90 seconds)" -ForegroundColor White
Write-Host ""

Write-Host "Solution:" -ForegroundColor Green
Write-Host "  1. Stop current backend (Ctrl+C)" -ForegroundColor White
Write-Host "  2. Start fresh backend with new connection pool" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📋 Steps to Follow" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Stop Backend" -ForegroundColor Yellow
Write-Host "  Go to the terminal running your backend" -ForegroundColor White
Write-Host "  Press: Ctrl+C" -ForegroundColor White
Write-Host ""

Write-Host "Step 2: Start Backend" -ForegroundColor Yellow
Write-Host "  Run: mvn spring-boot:run" -ForegroundColor White
Write-Host ""

Write-Host "Step 3: Wait for Startup" -ForegroundColor Yellow
Write-Host "  Look for: 'Started OmoiservespareApplication'" -ForegroundColor White
Write-Host ""

Write-Host "Step 4: Test OTP Generation" -ForegroundColor Yellow
Write-Host "  Run: .\test-otp-generation.ps1" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ What's Fixed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "HikariCP Connection Pool Settings Added:" -ForegroundColor Green
Write-Host "  ✅ connection-test-query=SELECT 1" -ForegroundColor White
Write-Host "     Tests connections before use" -ForegroundColor Gray
Write-Host ""
Write-Host "  ✅ max-lifetime=30 minutes" -ForegroundColor White
Write-Host "     Prevents stale connections" -ForegroundColor Gray
Write-Host ""
Write-Host "  ✅ idle-timeout=10 minutes" -ForegroundColor White
Write-Host "     Closes unused connections" -ForegroundColor Gray
Write-Host ""
Write-Host "  ✅ connection-timeout=30 seconds" -ForegroundColor White
Write-Host "     Fails fast instead of hanging" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🎯 Expected Results After Restart" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ No connection timeout errors" -ForegroundColor Green
Write-Host "✅ OTP generated and saved to database" -ForegroundColor Green
Write-Host "✅ OTP sent to email via SMTP" -ForegroundColor Green
Write-Host "✅ OTP logged to console" -ForegroundColor Green
Write-Host "✅ Frontend responds quickly (no 90s wait)" -ForegroundColor Green
Write-Host "✅ Redirect to OTP page works" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
