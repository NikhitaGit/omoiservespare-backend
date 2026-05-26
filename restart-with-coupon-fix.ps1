# Restart Application with Coupon Fix
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Restarting Application with Coupon Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Stop existing Java processes
Write-Host "`n1. Stopping existing application..." -ForegroundColor Yellow
$javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
if ($javaProcesses) {
    $javaProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "✓ Stopped existing processes" -ForegroundColor Green
} else {
    Write-Host "No running processes found" -ForegroundColor Gray
}

# Clean and compile
Write-Host "`n2. Compiling application..." -ForegroundColor Yellow
$compileResult = & ./mvnw clean compile -DskipTests 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Compilation successful" -ForegroundColor Green
} else {
    Write-Host "✗ Compilation failed!" -ForegroundColor Red
    Write-Host $compileResult
    exit 1
}

# Start application
Write-Host "`n3. Starting application..." -ForegroundColor Yellow
Write-Host "Using profile: no-kafka, no-redis (for fast startup)" -ForegroundColor Gray

Start-Process powershell -ArgumentList "-NoExit", "-Command", "& ./mvnw spring-boot:run -Dspring-boot.run.profiles=no-kafka,no-redis"

Write-Host "✓ Application starting in new window..." -ForegroundColor Green

# Wait for application to start
Write-Host "`n4. Waiting for application to start..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$started = $false

while ($attempt -lt $maxAttempts -and -not $started) {
    Start-Sleep -Seconds 2
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $started = $true
        }
    } catch {
        $attempt++
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if ($started) {
    Write-Host "`n✓ Application started successfully!" -ForegroundColor Green
    Write-Host "`nApplication is ready at: http://localhost:8080" -ForegroundColor Cyan
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "1. Test coupon validation:" -ForegroundColor White
    Write-Host "   .\test-coupon-fix.ps1" -ForegroundColor Yellow
    Write-Host "`n2. Try applying a coupon in your cart" -ForegroundColor White
    Write-Host "`n3. Check the fix details:" -ForegroundColor White
    Write-Host "   cat COUPON_TIMEOUT_FIX.md" -ForegroundColor Yellow
    
} else {
    Write-Host "`n⚠ Application may still be starting..." -ForegroundColor Yellow
    Write-Host "Check the application window for startup logs" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
