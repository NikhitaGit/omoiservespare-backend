# ========================================
# TEST LOGIN TIMEOUT FIX
# ========================================

Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "TESTING LOGIN TIMEOUT FIX"  -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host ""

# Check if backend is running
Write-Host "Checking if backend is running..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/health" -TimeoutSec 5
    Write-Host "✅ Backend is running: $health" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is not responding!" -ForegroundColor Red
    Write-Host "Please start backend with: mvn spring-boot:run" -ForegroundColor Yellow
    Write-Host "Then wait 60-90 seconds and run this script again" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Testing login endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test login with timeout tracking
$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "testuser@company.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Cyan
Write-Host $loginPayload -ForegroundColor Gray
Write-Host ""

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -Body $loginPayload `
        -ContentType "application/json" `
        -TimeoutSec 60
    
    $stopwatch.Stop()
    $elapsed = $stopwatch.Elapsed.TotalSeconds
    
    Write-Host ""
    Write-Host "✅ LOGIN SUCCESSFUL!" -ForegroundColor Green
    Write-Host "⏱️  Response time: $([Math]::Round($elapsed, 2)) seconds" -ForegroundColor Cyan
    Write-Host ""
    
    if ($elapsed -lt 5) {
        Write-Host "✅ EXCELLENT! Response was very fast (< 5 seconds)" -ForegroundColor Green
    } elseif ($elapsed -lt 10) {
        Write-Host "✅ GOOD! Response was reasonable (< 10 seconds)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Response was slow (> 10 seconds) but didn't timeout" -ForegroundColor Yellow
        Write-Host "   Email sending might be slow, but OTP was saved" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    Write-Host ""
    
    if ($response.success -eq $true -and $response.otpRequired -eq $true) {
        Write-Host "✅ OTP was generated and saved successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Check backend console for OTP code (printed with 🔐 emoji)" -ForegroundColor Yellow
        Write-Host "Email will arrive within 5-30 seconds" -ForegroundColor Yellow
    }
    
} catch {
    $stopwatch.Stop()
    $elapsed = $stopwatch.Elapsed.TotalSeconds
    
    Write-Host ""
    Write-Host "❌ LOGIN FAILED!" -ForegroundColor Red
    Write-Host "⏱️  Failed after: $([Math]::Round($elapsed, 2)) seconds" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Message -like "*timeout*") {
        Write-Host "TIMEOUT ISSUE DETECTED!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible causes:" -ForegroundColor Yellow
        Write-Host "1. Backend not fully started (wait 90+ seconds after mvn spring-boot:run)" -ForegroundColor Yellow
        Write-Host "2. Database connection slow" -ForegroundColor Yellow
        Write-Host "3. Email server unreachable" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Try:" -ForegroundColor Yellow
        Write-Host "- Restart backend and wait longer" -ForegroundColor Yellow
        Write-Host "- Check database is running (PostgreSQL)" -ForegroundColor Yellow
        Write-Host "- Check backend logs for errors" -ForegroundColor Yellow
    } else {
        Write-Host "This is not a timeout error. Check backend logs for details." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "TEST COMPLETE"  -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. If test passed, try logging in from React app (http://localhost:5173)" -ForegroundColor Yellow
Write-Host "2. Check backend console for OTP code" -ForegroundColor Yellow
Write-Host "3. Enter OTP on OTP verification page" -ForegroundColor Yellow
Write-Host ""
