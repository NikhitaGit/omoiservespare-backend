# ========================================
# FIX LOGIN TIMEOUT ISSUE
# ========================================

Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "FIXING LOGIN TIMEOUT ISSUE"  -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host ""

Write-Host "CHANGES APPLIED:" -ForegroundColor Green
Write-Host "1. Increased SMTP timeout from 5s to 30s" -ForegroundColor Yellow
Write-Host "2. Increased axios timeout to 60s" -ForegroundColor Yellow
Write-Host "3. Added async email configuration" -ForegroundColor Yellow
Write-Host "4. Made OTP response immediate (async email)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Stopping any running backend processes..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "*maven*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "Starting backend with fixes..." -ForegroundColor Green
Write-Host ""

# Start the backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "mvn spring-boot:run"

Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "BACKEND STARTING..."  -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host ""
Write-Host "Waiting for application to start (60 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

Write-Host ""
Write-Host "Testing login flow..." -ForegroundColor Green
Write-Host ""

# Test login
$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "user@test.com"
    phoneNumber = "+91-1234567890"
} | ConvertTo-Json

Write-Host "Sending login request..." -ForegroundColor Yellow
Write-Host "Payload: $loginPayload" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -Body $loginPayload `
        -ContentType "application/json" `
        -TimeoutSec 60
    
    Write-Host ""
    Write-Host "✅ LOGIN SUCCESSFUL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    Write-Host ""
    Write-Host "Check your backend console for the OTP code" -ForegroundColor Yellow
    Write-Host "The OTP will also be sent to your email" -ForegroundColor Yellow
    
} catch {
    Write-Host ""
    Write-Host "❌ LOGIN FAILED!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "If you see 'timeout exceeded', wait longer for backend to start" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "NEXT STEPS:"  -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "1. If timeout still occurs, restart backend and wait 90+ seconds" -ForegroundColor Yellow
Write-Host "2. Check backend console for OTP code" -ForegroundColor Yellow
Write-Host "3. Test login from your React app on http://localhost:5173" -ForegroundColor Yellow
Write-Host ""
