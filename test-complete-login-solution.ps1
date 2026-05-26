# Complete Login Solution Test
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Complete Login Solution Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Check Backend
Write-Host "`n[Step 1/5] Checking Backend Status..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/health" -Method GET -TimeoutSec 5
    Write-Host "✅ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is NOT running!" -ForegroundColor Red
    Write-Host "Please start backend: mvn spring-boot:run" -ForegroundColor Yellow
    exit
}

# Step 2: Generate Device ID
Write-Host "`n[Step 2/5] Generating Device ID..." -ForegroundColor Yellow
$deviceId = [guid]::NewGuid().ToString()
Write-Host "✅ Device ID: $deviceId" -ForegroundColor Green

# Step 3: Test Login
Write-Host "`n[Step 3/5] Testing Login Request..." -ForegroundColor Yellow

$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
    "X-Device-Id" = $deviceId
}

Write-Host "Request:" -ForegroundColor Gray
Write-Host "  URL: http://localhost:8080/api/auth/user/login" -ForegroundColor White
Write-Host "  Method: POST" -ForegroundColor White
Write-Host "  Headers:" -ForegroundColor White
$headers.GetEnumerator() | ForEach-Object { Write-Host "    $($_.Key): $($_.Value)" -ForegroundColor White }
Write-Host "  Body:" -ForegroundColor White
Write-Host "    $loginPayload" -ForegroundColor White

try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -Headers $headers `
        -Body $loginPayload `
        -UseBasicParsing
    
    $loginData = $loginResponse.Content | ConvertFrom-Json
    
    Write-Host "✅ Login Request Successful!" -ForegroundColor Green
    Write-Host "  Status: $($loginResponse.StatusCode)" -ForegroundColor Green
    Write-Host "  Success: $($loginData.success)" -ForegroundColor Green
    Write-Host "  Message: $($loginData.message)" -ForegroundColor Green
    Write-Host "  OTP Required: $($loginData.otpRequired)" -ForegroundColor Green
    
    if ($loginData.otpRequired) {
        # Step 4: Get OTP
        Write-Host "`n[Step 4/5] Getting OTP..." -ForegroundColor Yellow
        Write-Host "⚠️  IMPORTANT: Check your backend console for OTP!" -ForegroundColor Yellow
        Write-Host "Look for:" -ForegroundColor Gray
        Write-Host "  === OTP GENERATED ===" -ForegroundColor White
        Write-Host "  Email: nikita.a@omoikaneinnovations.com" -ForegroundColor White
        Write-Host "  OTP: 1234" -ForegroundColor White
        Write-Host "  =====================" -ForegroundColor White
        Write-Host ""
        $otp = Read-Host "Enter the OTP from backend console"
        
        # Step 5: Verify OTP
        Write-Host "`n[Step 5/5] Testing OTP Verification..." -ForegroundColor Yellow
        
        $otpPayload = @{
            email = "nikita.a@omoikaneinnovations.com"
            otp = $otp
        } | ConvertTo-Json
        
        Write-Host "Request:" -ForegroundColor Gray
        Write-Host "  URL: http://localhost:8080/api/auth/verify-otp" -ForegroundColor White
        Write-Host "  Method: POST" -ForegroundColor White
        Write-Host "  Headers:" -ForegroundColor White
        $headers.GetEnumerator() | ForEach-Object { Write-Host "    $($_.Key): $($_.Value)" -ForegroundColor White }
        Write-Host "  Body:" -ForegroundColor White
        Write-Host "    $otpPayload" -ForegroundColor White
        
        try {
            $otpResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/verify-otp" `
                -Method POST `
                -Headers $headers `
                -Body $otpPayload `
                -UseBasicParsing
            
            $otpData = $otpResponse.Content | ConvertFrom-Json
            
            Write-Host "✅ OTP Verification Successful!" -ForegroundColor Green
            Write-Host "  Status: $($otpResponse.StatusCode)" -ForegroundColor Green
            Write-Host "  Success: $($otpData.success)" -ForegroundColor Green
            Write-Host "  Message: $($otpData.message)" -ForegroundColor Green
            
            if ($otpData.accessToken) {
                Write-Host "`n========================================" -ForegroundColor Cyan
                Write-Host "✅ LOGIN FLOW COMPLETE!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "User Details:" -ForegroundColor Yellow
                Write-Host "  Email: $($otpData.email)" -ForegroundColor White
                Write-Host "  Role: $($otpData.role)" -ForegroundColor White
                Write-Host "  Company: $($otpData.companyName)" -ForegroundColor White
                Write-Host "  Phone: $($otpData.phoneNumber)" -ForegroundColor White
                Write-Host ""
                Write-Host "Tokens:" -ForegroundColor Yellow
                Write-Host "  Access Token: $($otpData.accessToken.Substring(0, 50))..." -ForegroundColor White
                if ($otpData.refreshToken) {
                    Write-Host "  Refresh Token: $($otpData.refreshToken.Substring(0, 50))..." -ForegroundColor White
                }
                Write-Host ""
                Write-Host "Next Steps:" -ForegroundColor Yellow
                Write-Host "  1. Copy frontend-integration/authApi_FINAL_FIXED.js to your app" -ForegroundColor White
                Write-Host "  2. Clear browser cache and localStorage" -ForegroundColor White
                Write-Host "  3. Test login in your React app" -ForegroundColor White
                Write-Host "  4. Use the same credentials and OTP from console" -ForegroundColor White
                
            } else {
                Write-Host "❌ No access token in response!" -ForegroundColor Red
                Write-Host "Response:" -ForegroundColor Gray
                $otpData | ConvertTo-Json -Depth 3
            }
            
        } catch {
            Write-Host "❌ OTP Verification Failed!" -ForegroundColor Red
            Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errorBody = $reader.ReadToEnd()
                Write-Host "  Error Body: $errorBody" -ForegroundColor Red
            }
            
            Write-Host "`nPossible Issues:" -ForegroundColor Yellow
            Write-Host "  - Wrong OTP entered" -ForegroundColor White
            Write-Host "  - OTP expired (5 minutes)" -ForegroundColor White
            Write-Host "  - Missing X-Device-Id header" -ForegroundColor White
            Write-Host "  - Backend error (check logs)" -ForegroundColor White
        }
    } else {
        Write-Host "❌ OTP not required in response!" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Login Request Failed!" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "  Error Body: $errorBody" -ForegroundColor Red
    }
    
    Write-Host "`nPossible Issues:" -ForegroundColor Yellow
    Write-Host "  - Company name incorrect (use: Omoiservespare Pvt Ltd)" -ForegroundColor White
    Write-Host "  - Email not in mock HR data" -ForegroundColor White
    Write-Host "  - Database not running" -ForegroundColor White
    Write-Host "  - Backend error (check logs)" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
