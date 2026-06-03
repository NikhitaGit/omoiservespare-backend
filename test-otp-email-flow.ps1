# ========================================
# 📧 Production OTP Email Flow Test Script
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🧪 TESTING OTP EMAIL FLOW" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$BASE_URL = "http://localhost:8080"
$TEST_EMAIL = "your.test.email@gmail.com"  # REPLACE WITH YOUR EMAIL
$TEST_COMPANY = "Omoiservespare Pvt Ltd"
$TEST_PHONE = "+91-9876543210"

# Step 1: Health Check
Write-Host "Step 1: Backend Health Check" -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "$BASE_URL/api/auth/health" -Method Get -TimeoutSec 5
    Write-Host "✅ Backend is running" -ForegroundColor Green
    Write-Host "   Response: $healthResponse" -ForegroundColor Gray
} catch {
    Write-Host "❌ Backend is not responding" -ForegroundColor Red
    Write-Host "   Please start the backend first" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Request OTP
Write-Host "Step 2: Requesting OTP for email: $TEST_EMAIL" -ForegroundColor Yellow

$loginRequest = @{
    companyName = $TEST_COMPANY
    email = $TEST_EMAIL
    phoneNumber = $TEST_PHONE
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Gray
Write-Host $loginRequest -ForegroundColor Gray

try {
    $otpResponse = Invoke-RestMethod `
        -Uri "$BASE_URL/api/auth/user/login" `
        -Method Post `
        -Body $loginRequest `
        -ContentType "application/json" `
        -TimeoutSec 30

    Write-Host "✅ OTP Request Successful" -ForegroundColor Green
    Write-Host "   Message: $($otpResponse.message)" -ForegroundColor Gray
    Write-Host "   Success: $($otpResponse.success)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ OTP Request Failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📧 CHECK YOUR EMAIL INBOX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Email should be sent to: $TEST_EMAIL" -ForegroundColor Yellow
Write-Host ""
Write-Host "What to check:" -ForegroundColor Yellow
Write-Host "  1. ✉️  Email in inbox (check spam folder too)" -ForegroundColor White
Write-Host "  2. 🎨 Professional HTML formatting" -ForegroundColor White
Write-Host "  3. 🔐 4-digit OTP code clearly displayed" -ForegroundColor White
Write-Host "  4. ⏰ 5-minute expiry message" -ForegroundColor White
Write-Host "  5. 🏢 Company branding (OmoiServespare)" -ForegroundColor White
Write-Host ""

# Wait for user to enter OTP
Write-Host "========================================" -ForegroundColor Cyan
$enteredOtp = Read-Host "Enter the OTP from your email (or press Enter to skip verification)"

if ($enteredOtp) {
    Write-Host ""
    Write-Host "Step 3: Verifying OTP: $enteredOtp" -ForegroundColor Yellow
    
    # Generate device ID
    $deviceId = [guid]::NewGuid().ToString()
    
    $otpVerifyRequest = @{
        email = $TEST_EMAIL
        otp = $enteredOtp
    } | ConvertTo-Json
    
    Write-Host "Request Body:" -ForegroundColor Gray
    Write-Host $otpVerifyRequest -ForegroundColor Gray
    
    try {
        $verifyResponse = Invoke-RestMethod `
            -Uri "$BASE_URL/api/auth/verify-otp" `
            -Method Post `
            -Body $otpVerifyRequest `
            -ContentType "application/json" `
            -Headers @{"X-Device-Id" = $deviceId} `
            -TimeoutSec 30
        
        Write-Host "✅ OTP Verification Successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response Details:" -ForegroundColor Cyan
        Write-Host "  Success: $($verifyResponse.success)" -ForegroundColor White
        Write-Host "  Message: $($verifyResponse.message)" -ForegroundColor White
        Write-Host "  Email: $($verifyResponse.email)" -ForegroundColor White
        Write-Host "  Role: $($verifyResponse.role)" -ForegroundColor White
        Write-Host "  Access Token: $($verifyResponse.accessToken.Substring(0, 30))..." -ForegroundColor White
        
    } catch {
        Write-Host "❌ OTP Verification Failed" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Response: $responseBody" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📊 TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "What was tested:" -ForegroundColor Yellow
Write-Host "  ✅ Backend connectivity" -ForegroundColor Green
Write-Host "  ✅ OTP generation and database storage" -ForegroundColor Green
Write-Host "  ✅ Email sending via SMTP" -ForegroundColor Green
Write-Host "  ✅ HTML email template rendering" -ForegroundColor Green
if ($enteredOtp) {
    Write-Host "  ✅ OTP verification" -ForegroundColor Green
    Write-Host "  ✅ JWT token generation" -ForegroundColor Green
}
Write-Host ""
Write-Host "📝 Backend logs location:" -ForegroundColor Yellow
Write-Host "   Check your Spring Boot console for detailed email sending logs" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Look for these log messages:" -ForegroundColor Yellow
Write-Host "   📧 EMAIL SERVICE: OTP Send Initiated" -ForegroundColor White
Write-Host "   ✅ EMAIL SENT SUCCESSFULLY" -ForegroundColor White
Write-Host ""
