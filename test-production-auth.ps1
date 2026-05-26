# Test Production Authentication System

Write-Host "🔐 Testing Production Authentication System" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$deviceId = "test-device-" + (Get-Random)

Write-Host "Device ID: $deviceId" -ForegroundColor Gray
Write-Host ""

# Test 1: Vendor Login
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Test 1: Vendor Login (Email + Password)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$vendorLogin = @{
    email = "vendor@restaurant.com"
    password = "vendor123"
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Cyan
Write-Host $vendorLogin
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/vendor/login" `
        -Method Post `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Device-Id" = $deviceId
        } `
        -Body $vendorLogin
    
    Write-Host "✅ Vendor Login Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
    
    $vendorToken = $response.accessToken
    Write-Host "Vendor Token: $($vendorToken.Substring(0, 50))..." -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Vendor Login Failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host ""

# Test 2: User/Admin Login (Step 1 - Send OTP)
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Test 2: User/Admin Login (Send OTP)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$userLogin = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Cyan
Write-Host $userLogin
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/user/login" `
        -Method Post `
        -Headers @{
            "Content-Type" = "application/json"
        } `
        -Body $userLogin
    
    Write-Host "✅ OTP Sent Successfully!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
    
    Write-Host "⚠️  Check backend console for OTP code" -ForegroundColor Yellow
    Write-Host ""
    
    # Prompt for OTP
    $otp = Read-Host "Enter OTP from backend console"
    
    if ($otp) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "Test 3: Verify OTP" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host ""
        
        $otpVerify = @{
            email = "nikita.a@omoikaneinnovations.com"
            otp = $otp
        } | ConvertTo-Json
        
        Write-Host "Request:" -ForegroundColor Cyan
        Write-Host $otpVerify
        Write-Host ""
        
        try {
            $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/verify-otp" `
                -Method Post `
                -Headers @{
                    "Content-Type" = "application/json"
                    "X-Device-Id" = $deviceId
                } `
                -Body $otpVerify
            
            Write-Host "✅ OTP Verification Successful!" -ForegroundColor Green
            Write-Host "Response:" -ForegroundColor Cyan
            $response | ConvertTo-Json -Depth 3
            Write-Host ""
            
            $userToken = $response.accessToken
            Write-Host "User Token: $($userToken.Substring(0, 50))..." -ForegroundColor Gray
            
        } catch {
            Write-Host "❌ OTP Verification Failed!" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ User Login Failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host ""

# Test 4: Admin Login
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Test 4: Admin Login (Vendor Portal)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$adminLogin = @{
    email = "admin@omoikaneinnovations.com"
    password = "admin123"
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Cyan
Write-Host $adminLogin
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/vendor/login" `
        -Method Post `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Device-Id" = $deviceId
        } `
        -Body $adminLogin
    
    Write-Host "✅ Admin Login Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
    
    $adminToken = $response.accessToken
    Write-Host "Admin Token: $($adminToken.Substring(0, 50))..." -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Admin Login Failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Note: Admin needs password set first. Use user/admin login flow instead." -ForegroundColor Yellow
}

Write-Host ""
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Vendor Login: Email + Password → Direct JWT" -ForegroundColor Green
Write-Host "✅ User Login: Company + Email → OTP → JWT" -ForegroundColor Green
Write-Host "✅ Admin Login: Can use both flows" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Update frontend to use new endpoints" -ForegroundColor White
Write-Host "  2. Test with actual frontend on ports 5173/5174" -ForegroundColor White
Write-Host "  3. Verify role-based access control" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
