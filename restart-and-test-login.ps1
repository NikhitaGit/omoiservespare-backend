# Restart Backend and Test Login
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Restart Backend and Test Login" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n⚠️  IMPORTANT: You need to restart your backend!" -ForegroundColor Yellow
Write-Host "The backend code has been updated to make X-Device-Id optional." -ForegroundColor Yellow
Write-Host ""
Write-Host "Steps:" -ForegroundColor White
Write-Host "1. Stop your current backend (Ctrl+C in the terminal running mvn)" -ForegroundColor White
Write-Host "2. Restart backend: mvn spring-boot:run" -ForegroundColor White
Write-Host "3. Come back here and press Enter to test" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter when backend is restarted"

Write-Host "`nTesting login flow..." -ForegroundColor Yellow

# Test login
$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
}

Write-Host "`n1. Testing Login..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -Headers $headers `
        -Body $loginPayload `
        -UseBasicParsing
    
    $loginData = $loginResponse.Content | ConvertFrom-Json
    Write-Host "✅ Login Successful!" -ForegroundColor Green
    Write-Host "Message: $($loginData.message)" -ForegroundColor Green
    
    if ($loginData.otpRequired) {
        Write-Host "`n2. Check Backend Console for OTP" -ForegroundColor Yellow
        Write-Host "Look for:" -ForegroundColor Gray
        Write-Host "=== OTP GENERATED ===" -ForegroundColor White
        Write-Host "OTP: 1234" -ForegroundColor White
        Write-Host ""
        $otp = Read-Host "Enter OTP from backend console"
        
        Write-Host "`n3. Testing OTP Verification..." -ForegroundColor Yellow
        $otpPayload = @{
            email = "nikita.a@omoikaneinnovations.com"
            otp = $otp
        } | ConvertTo-Json
        
        try {
            $otpResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/verify-otp" `
                -Method POST `
                -Headers $headers `
                -Body $otpPayload `
                -UseBasicParsing
            
            $otpData = $otpResponse.Content | ConvertFrom-Json
            Write-Host "✅ OTP Verification Successful!" -ForegroundColor Green
            Write-Host "Access Token: $($otpData.accessToken.Substring(0, 50))..." -ForegroundColor Green
            
            Write-Host "`n========================================" -ForegroundColor Cyan
            Write-Host "✅ LOGIN WORKS!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Now test in your React app:" -ForegroundColor Yellow
            Write-Host "1. Clear browser cache (F12 → Application → Clear storage)" -ForegroundColor White
            Write-Host "2. Go to login page" -ForegroundColor White
            Write-Host "3. Enter same credentials" -ForegroundColor White
            Write-Host "4. Get OTP from backend console" -ForegroundColor White
            Write-Host "5. Should work!" -ForegroundColor White
            
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
}
