# 🔄 Restart Backend with Location Fix
Write-Host "`n🔄 Restarting Backend with Location Fix..." -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Check if backend is running
$javaProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue

if ($javaProcess) {
    Write-Host "⏹️  Stopping existing backend..." -ForegroundColor Yellow
    Stop-Process -Name "java" -Force
    Start-Sleep -Seconds 3
    Write-Host "✅ Backend stopped" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No running backend found" -ForegroundColor Cyan
}

Write-Host "`n🚀 Starting backend with location fix..." -ForegroundColor Yellow
Write-Host "   This will compile and start the Spring Boot application`n" -ForegroundColor Gray

# Start backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "mvn spring-boot:run"

Write-Host "✅ Backend is starting..." -ForegroundColor Green
Write-Host "`n⏳ Waiting for backend to be ready (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`n✅ Backend should be ready now!" -ForegroundColor Green
Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open your React app at http://localhost:5173" -ForegroundColor White
Write-Host "2. Navigate to the location picker" -ForegroundColor White
Write-Host "3. Click 'Use current location'" -ForegroundColor White
Write-Host "4. Allow location permission" -ForegroundColor White
Write-Host "5. Location should save successfully!" -ForegroundColor White

Write-Host "`n🔍 Check backend logs in the new window for any errors" -ForegroundColor Yellow
