# Test if Redis is running
Write-Host "=== Testing Redis Connection ===" -ForegroundColor Cyan

try {
    $response = Test-NetConnection -ComputerName localhost -Port 6379 -WarningAction SilentlyContinue
    
    if ($response.TcpTestSucceeded) {
        Write-Host "✅ Redis is RUNNING on port 6379" -ForegroundColor Green
    } else {
        Write-Host "❌ Redis is NOT running on port 6379" -ForegroundColor Red
        Write-Host ""
        Write-Host "Redis is required for coupon validation!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Quick Fix Options:" -ForegroundColor Cyan
        Write-Host "1. Start Redis (if installed)" -ForegroundColor White
        Write-Host "2. Disable Redis in CouponService (temporary fix)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Cannot connect to Redis" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
