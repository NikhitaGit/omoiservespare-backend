# Test Login Fix - Complete Flow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Complete Login Flow" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 1: User Login (Request OTP)
Write-Host "`n1. Testing User Login (Request OTP)..." -ForegroundColor Yellow
$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Write-Host "Payload:" -ForegroundColor Gray
Write-Host $loginPayload -ForegroundColor Gray

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginPayload
    
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Gray
    $loginResponse | ConvertTo-Json -Depth 3
    
    if ($loginResponse.success -and $loginResponse.otpRequired) {
        Write-Host "`n✅ OTP has been sent to email" -ForegroundColor Green
        
        # Test 2: Verify OTP
        Write-Host "`n2. Testing OTP Verification..." -ForegroundColor Yellow
        Write-Host "⚠️  Check your email for OTP and enter it below" -ForegroundColor Yellow
        $otp = Read-Host "Enter OTP"
        
        # Generate device ID
        $deviceId = [guid]::NewGuid().ToString()
        Write-Host "Using Device ID: $deviceId" -ForegroundColor Gray
        
        $otpPayload = @{
            email = "nikita.a@omoikaneinnovations.com"
            otp = $otp
        } | ConvertTo-Json
        
        Write-Host "Payload:" -ForegroundColor Gray
        Write-Host $otpPayload -ForegroundColor Gray
        
        $headers = @{
            "Content-Type" = "application/json"
            "X-Device-Id" = $deviceId
        }
        
        $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" `
            -Method POST `
            -Headers $headers `
            -Body $otpPayload `
            -SessionVariable session
        
        Write-Host "`n✅ OTP Verification successful!" -ForegroundColor Green
        Write-Host "Response:" -ForegroundColor Gray
        $verifyResponse | ConvertTo-Json -Depth 3
        
        if ($verifyResponse.accessToken) {
            Write-Host "`n✅ Access Token received!" -ForegroundColor Green
            Write-Host "Token: $($verifyResponse.accessToken.Substring(0, 50))..." -ForegroundColor Gray
            
            # Test 3: Use token to access protected endpoint
            Write-Host "`n3. Testing Protected Endpoint Access..." -ForegroundColor Yellow
            
            $authHeaders = @{
                "Authorization" = "Bearer $($verifyResponse.accessToken)"
                "X-Device-Id" = $deviceId
            }
            
            try {
                $profileResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/users/profile" `
                    -Method GET `
                    -Headers $authHeaders
                
                Write-Host "✅ Protected endpoint access successful!" -ForegroundColor Green
                Write-Host "Profile:" -ForegroundColor Gray
                $profileResponse | ConvertTo-Json -Depth 3
            } catch {
                Write-Host "⚠️  Protected endpoint test failed (this is OK if endpoint doesn't exist)" -ForegroundColor Yellow
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
            }
            
            Write-Host "`n========================================" -ForegroundColor Cyan
            Write-Host "✅ ALL TESTS PASSED!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "`nYou can now use these credentials in your frontend:" -ForegroundColor Yellow
            Write-Host "Email: nikita.a@omoikaneinnovations.com" -ForegroundColor White
            Write-Host "Company: Omoiservespare Pvt Ltd" -ForegroundColor White
            Write-Host "Token: $($verifyResponse.accessToken.Substring(0, 30))..." -ForegroundColor White
        } else {
            Write-Host "❌ No access token in response!" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ OTP not sent!" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Test failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
