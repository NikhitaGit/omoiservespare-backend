# Test OTP-Based Login System
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING OTP-BASED LOGIN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Request OTP
Write-Host "Step 1: Requesting OTP..." -ForegroundColor Yellow
Write-Host ""

$loginData = @{
    companyName = "Omoi Innovations"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

Write-Host "Sending login request with:" -ForegroundColor White
Write-Host "  Company: Omoi Innovations" -ForegroundColor Gray
Write-Host "  Email: nikita.a@omoikaneinnovations.com" -ForegroundColor Gray
Write-Host "  Phone: +91-9876543210" -ForegroundColor Gray
Write-Host ""

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginData `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "SUCCESS - OTP Request Sent!" -ForegroundColor Green
    Write-Host "Message: $($loginResponse.message)" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "CHECK YOUR BACKEND CONSOLE FOR OTP!" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Look for output like:" -ForegroundColor White
    Write-Host "===========================================" -ForegroundColor Gray
    Write-Host "OTP GENERATED FOR: nikita.a@omoikaneinnovations.com" -ForegroundColor Gray
    Write-Host "OTP CODE: 123456" -ForegroundColor Gray
    Write-Host "===========================================" -ForegroundColor Gray
    Write-Host ""
    
    # Step 2: Verify OTP
    Write-Host "Step 2: Enter the OTP from console" -ForegroundColor Yellow
    $otp = Read-Host "Enter OTP"
    Write-Host ""
    
    $otpData = @{
        email = "nikita.a@omoikaneinnovations.com"
        otp = $otp
    } | ConvertTo-Json
    
    Write-Host "Verifying OTP..." -ForegroundColor Yellow
    
    $headers = @{
        "X-Device-Id" = "test-device-123"
    }
    
    $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" `
        -Method POST `
        -Body $otpData `
        -ContentType "application/json" `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "LOGIN SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access Token:" -ForegroundColor Yellow
    Write-Host $verifyResponse.accessToken -ForegroundColor White
    Write-Host ""
    Write-Host "User Info:" -ForegroundColor Yellow
    Write-Host "  Email: $($verifyResponse.email)" -ForegroundColor White
    Write-Host "  Company: $($verifyResponse.companyName)" -ForegroundColor White
    Write-Host "  Phone: $($verifyResponse.phoneNumber)" -ForegroundColor White
    Write-Host "  Account Type: $($verifyResponse.accountType)" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "YOUR OTP LOGIN SYSTEM IS WORKING!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "How it works:" -ForegroundColor Yellow
    Write-Host "1. User enters company name + email" -ForegroundColor White
    Write-Host "2. System validates against HR data" -ForegroundColor White
    Write-Host "3. OTP sent to email (console for now)" -ForegroundColor White
    Write-Host "4. User enters OTP" -ForegroundColor White
    Write-Host "5. System returns JWT tokens" -ForegroundColor White
    
} catch {
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Message: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "- Backend not running on port 8080" -ForegroundColor White
    Write-Host "- User not found in HR system" -ForegroundColor White
    Write-Host "- Invalid company name" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "To configure email sending:" -ForegroundColor Yellow
Write-Host "1. Get SendGrid API key" -ForegroundColor White
Write-Host "2. Set in application.properties" -ForegroundColor White
Write-Host "3. Enable: sendgrid.enabled=true" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
