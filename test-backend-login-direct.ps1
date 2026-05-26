# Direct Backend Login Test
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Backend Login Directly" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$deviceId = [guid]::NewGuid().ToString()
Write-Host "Device ID: $deviceId" -ForegroundColor Gray

# Test 1: Login Request
Write-Host "`n1. Testing Login Request..." -ForegroundColor Yellow

$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
    "X-Device-Id" = $deviceId
}

Write-Host "Payload:" -ForegroundColor Gray
Write-Host $loginPayload -ForegroundColor White

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -Headers $headers `
        -Body $loginPayload `
        -UseBasicParsing
    
    Write-Host "✅ Login Successful!" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Gray
    $responseData = $response.Content | ConvertFrom-Json
    $responseData | ConvertTo-Json -Depth 3
    
    if ($responseData.otpRequired) {
        Write-Host "`n✅ OTP Required - Check console/email for OTP" -ForegroundColor Green
        
        # Test 2: OTP Verification
        Write-Host "`n2. Testing OTP Verification..." -ForegroundColor Yellow
        $otp = Read-Host "Enter OTP from console/email"
        
        $otpPayload = @{
            email = "nikita.a@omoikaneinnovations.com"
            otp = $otp
        } | ConvertTo-Json
        
        Write-Host "OTP Payload:" -ForegroundColor Gray
        Write-Host $otpPayload -ForegroundColor White
        
        try {
            $otpResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/verify-otp" `
                -Method POST `
                -Headers $headers `
                -Body $otpPayload `
                -UseBasicParsing
            
            Write-Host "✅ OTP Verification Successful!" -ForegroundColor Green
            Write-Host "Status: $($otpResponse.StatusCode)" -ForegroundColor Green
            Write-Host "Response:" -ForegroundColor Gray
            $otpData = $otpResponse.Content | ConvertFrom-Json
            $otpData | ConvertTo-Json -Depth 3
            
            if ($otpData.accessToken) {
                Write-Host "`n✅ Access Token Received!" -ForegroundColor Green
                Write-Host "Token: $($otpData.accessToken.Substring(0, 50))..." -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "❌ OTP Verification Failed!" -ForegroundColor Red
            Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errorBody = $reader.ReadToEnd()
                Write-Host "Error Body: $errorBody" -ForegroundColor Red
            }
        }
    }
    
} catch {
    Write-Host "❌ Login Failed!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Body: $errorBody" -ForegroundColor Red
    }
    
    Write-Host "`n⚠️  Check backend logs for detailed error information" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
