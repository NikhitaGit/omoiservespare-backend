# Restart Backend with Vendor Dashboard Access Fix

Write-Host "🔄 Restarting backend with vendor dashboard access..." -ForegroundColor Cyan
Write-Host ""

# Stop any running Spring Boot process
Write-Host "Stopping existing backend..." -ForegroundColor Yellow
$javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
if ($javaProcesses) {
    $javaProcesses | Stop-Process -Force
    Write-Host "✅ Stopped existing backend" -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "No running backend found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Starting backend..." -ForegroundColor Yellow
Write-Host ""

# Start backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "mvn spring-boot:run"

Write-Host ""
Write-Host "✅ Backend starting..." -ForegroundColor Green
Write-Host ""
Write-Host "📋 Changes Applied:" -ForegroundColor Cyan
Write-Host "  1. CORS now allows port 5174" -ForegroundColor White
Write-Host "  2. Admin Dashboard accessible by VENDOR and ADMIN" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Wait for backend to start (check for 'Started OmoiservespareApplication')" -ForegroundColor White
Write-Host "  2. Clear browser data (F12 → Application → Clear site data)" -ForegroundColor White
Write-Host "  3. Login as vendor" -ForegroundColor White
Write-Host "  4. Navigate to Admin Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
