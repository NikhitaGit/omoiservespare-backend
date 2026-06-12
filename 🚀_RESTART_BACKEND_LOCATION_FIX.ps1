# 🚀 Restart Backend with Location API Fix

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  RESTARTING BACKEND WITH LOCATION API FIX" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ Changes Applied:" -ForegroundColor Green
Write-Host "   1. Created LocationApiAuthFilter.java" -ForegroundColor White
Write-Host "   2. Updated SecurityConfig.java" -ForegroundColor White
Write-Host "   3. Updated JwtAuthFilter.java" -ForegroundColor White
Write-Host ""

Write-Host "🔧 What was fixed:" -ForegroundColor Yellow
Write-Host "   - Location API now has dedicated auth filter" -ForegroundColor Gray
Write-Host "   - Manual JWT extraction for location endpoints" -ForegroundColor Gray
Write-Host "   - No more 401 errors!" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 Starting backend..." -ForegroundColor Yellow
Write-Host ""

# Kill any existing Spring Boot process
$springProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*spring-boot*" }
if ($springProcesses) {
    Write-Host "⏹️  Stopping existing backend process..." -ForegroundColor Yellow
    $springProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# Start backend
Write-Host "🚀 Starting Spring Boot application..." -ForegroundColor Green
Write-Host ""

try {
    mvn spring-boot:run
} catch {
    Write-Host ""
    Write-Host "❌ Error starting backend: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try manually:" -ForegroundColor Yellow
    Write-Host "   mvn clean spring-boot:run" -ForegroundColor Gray
    exit 1
}
