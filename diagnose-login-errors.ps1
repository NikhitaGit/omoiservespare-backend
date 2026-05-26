# Comprehensive Login Diagnostics
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Login Error Diagnostics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 1: Check if backend is running
Write-Host "`n1. Checking Backend Status..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/health" -Method GET -TimeoutSec 5
    Write-Host "✅ Backend is running" -ForegroundColor Green
    Write-Host "Response: $health" -ForegroundColor Gray
} catch {
    Write-Host "❌ Backend is not responding!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease start your backend first:" -ForegroundColor Yellow
    Write-Host "mvn spring-boot:run" -ForegroundColor White
    exit
}

# Test 2: Check database connection
Write-Host "`n2. Testing Database Connection..." -ForegroundColor Yellow
Write-Host "Check your backend logs for database connection status" -ForegroundColor Gray

# Test 3: Test User Login (Request OTP)
Write-Host "`n3. Testing User Login (Request OTP)..." -ForegroundColor Yellow
$deviceId = [guid]::NewGuid().ToString()
Write-Host "Using Device ID: $deviceId" -ForegroundColor Gray

$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
    "X-Device-Id" = $deviceId
}

Write-Host "Request Payload:" -ForegroundColor Gray
Write-Host $loginPayload -ForegroundColor Gray
Write-Host "Request Headers:" -ForegroundColor Gray
$headers | Format-Table

try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -Headers $headers `
        -Body $loginPayload `
        -UseBasicParsing
    
    Write-Host "✅ Login Request Successful!" -ForegroundColor Green
    Write-Host "Status Code: $($loginResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Response Body:" -ForegroundColor Gray
    $loginResponse.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
    
    # Test 4: Test OTP Verification
    Write-Host "`n4. Testing OTP Verification..." -ForegroundColor Yellow
    Write-Host "⚠️  Check your email for OTP" -ForegroundColor Yellow
    $otp = Read-Host "Enter the OTP you received"
    
    $otpPayload = @{
        email = "nikita.a@omoikaneinnovations.com"
        otp = $otp
    } | ConvertTo-Json
    
    Write-Host "OTP Request Payload:" -ForegroundColor Gray
    Write-Host $otpPayload -ForegroundColor Gray
    
    try {
        $otpResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/verify-otp" `
            -Method POST `
            -Headers $headers `
            -Body $otpPayload `
            -UseBasicParsing
        
        Write-Host "✅ OTP Verification Successful!" -ForegroundColor Green
        Write-Host "Status Code: $($otpResponse.StatusCode)" -ForegroundColor Green
        Write-Host "Response Body:" -ForegroundColor Gray
        $responseData = $otpResponse.Content | ConvertFrom-Json
        $responseData | ConvertTo-Json -Depth 3
        
        if ($responseData.accessToken) {
            Write-Host "`n✅ Access Token Received!" -ForegroundColor Green
            Write-Host "Token: $($responseData.accessToken.Substring(0, 50))..." -ForegroundColor Gray
        } else {
            Write-Host "`n❌ No access token in response!" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "❌ OTP Verification Failed!" -ForegroundColor Red
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response Body: $responseBody" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ Login Request Failed!" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Diagnostics Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Check backend console logs for detailed error messages" -ForegroundColor White
Write-Host "2. Verify database is running and accessible" -ForegroundColor White
Write-Host "3. Check if user exists in database" -ForegroundColor White
Write-Host "4. Verify email service is configured correctly" -ForegroundColor White
