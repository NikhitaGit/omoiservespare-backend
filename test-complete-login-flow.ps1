# Complete User/Admin Login Flow Test

Write-Host "🔐 Testing Complete Login Flow" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

$deviceId = [guid]::NewGuid().ToString()
Write-Host "Device ID: $deviceId`n" -ForegroundColor Yellow

# Step 1: User/Admin Login (Request OTP)
Write-Host "Step 1: Requesting OTP..." -ForegroundColor Yellow

$loginBody = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $loginBody

    Write-Host "✅ OTP Request Successful!" -ForegroundColor Green
    Write-Host "Message: $($loginResponse.message)" -ForegroundColor White
    Write-Host "OTP Required: $($loginResponse.otpRequired)" -ForegroundColor White
    
    Write-Host "`n⚠️  CHECK BACKEND LOGS FOR OTP!" -ForegroundColor Yellow
    Write-Host "Look for a line like: 'OTP for user@email.com: XXXX'" -ForegroundColor Yellow
    
    # Step 2: Get OTP from user
    Write-Host "`nStep 2: Enter the OTP from backend logs" -ForegroundColor Yellow
    $otp = Read-Host "Enter OTP"
    
    if ($otp.Length -ne 4) {
        Write-Host "❌ OTP must be 4 digits!" -ForegroundColor Red
        exit 1
    }
    
    # Step 3: Verify OTP
    Write-Host "`nStep 3: Verifying OTP..." -ForegroundColor Yellow
    
    $otpBody = @{
        email = "nikita.a@omoikaneinnovations.com"
        otp = $otp
    } | ConvertTo-Json
    
    $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Device-Id" = $deviceId
        } `
        -Body $otpBody
    
    Write-Host "✅ OTP Verification Successful!" -ForegroundColor Green
    Write-Host "`nLogin Response:" -ForegroundColor Cyan
    Write-Host "Success: $($verifyResponse.success)" -ForegroundColor White
    Write-Host "Email: $($verifyResponse.email)" -ForegroundColor White
    Write-Host "Role: $($verifyResponse.role)" -ForegroundColor White
    Write-Host "Company: $($verifyResponse.companyName)" -ForegroundColor White
    Write-Host "Access Token: $($verifyResponse.accessToken.Substring(0, 50))..." -ForegroundColor White
    
    Write-Host "`n✅ COMPLETE LOGIN FLOW SUCCESSFUL!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            $reader.Close()
            Write-Host "`nResponse:" -ForegroundColor Yellow
            Write-Host $responseBody
        } catch {
            Write-Host "Could not read response body" -ForegroundColor Yellow
        }
    }
}
