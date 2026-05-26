# Test if backend returns token properly
Write-Host "Testing OTP Login Token Response" -ForegroundColor Cyan
Write-Host ""

# Step 1: Login
Write-Host "Step 1: Requesting OTP..." -ForegroundColor Yellow
$loginData = @{
    companyName = "Omoi Innovations"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginData `
        -ContentType "application/json"
    
    Write-Host "Login request successful" -ForegroundColor Green
    Write-Host ""
    
    # Get OTP from user
    Write-Host "Check backend console for OTP" -ForegroundColor Yellow
    $otp = Read-Host "Enter OTP"
    Write-Host ""
    
    # Step 2: Verify OTP
    Write-Host "Step 2: Verifying OTP..." -ForegroundColor Yellow
    $otpData = @{
        email = "nikita.a@omoikaneinnovations.com"
        otp = $otp
    } | ConvertTo-Json
    
    $headers = @{
        "X-Device-Id" = "test-device-123"
    }
    
    $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" `
        -Method POST `
        -Body $otpData `
        -ContentType "application/json" `
        -Headers $headers
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "RESPONSE FROM BACKEND:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Full Response:" -ForegroundColor Yellow
    $verifyResponse | ConvertTo-Json -Depth 10
    Write-Host ""
    
    Write-Host "Access Token:" -ForegroundColor Yellow
    if ($verifyResponse.accessToken) {
        Write-Host "✓ Token present: $($verifyResponse.accessToken.Substring(0, 50))..." -ForegroundColor Green
    } else {
        Write-Host "✗ Token is NULL or missing!" -ForegroundColor Red
    }
    Write-Host ""
    
    Write-Host "User Info:" -ForegroundColor Yellow
    Write-Host "  Email: $($verifyResponse.email)" -ForegroundColor White
    Write-Host "  Company: $($verifyResponse.companyName)" -ForegroundColor White
    Write-Host "  Phone: $($verifyResponse.phoneNumber)" -ForegroundColor White
    Write-Host "  Account Type: $($verifyResponse.accountType)" -ForegroundColor White
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
