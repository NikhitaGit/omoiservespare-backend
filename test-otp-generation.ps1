# Test OTP Generation Fix
# This script tests the complete OTP login flow

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔐 Testing OTP Generation Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test email
$email = "lata.b@omoikaneinnovations.com"
$company = "Omoiservespare Pvt Ltd"
$phone = "+91-9876543210"

Write-Host "Step 1: Requesting OTP..." -ForegroundColor Yellow
Write-Host "Email: $email" -ForegroundColor White
Write-Host "Company: $company" -ForegroundColor White
Write-Host ""

$loginBody = @{
    companyName = $company
    email = $email
    phoneNumber = $phone
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody
    
    Write-Host "✅ OTP Request Successful!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Check backend console for OTP:" -ForegroundColor Yellow
    Write-Host "   Look for: '🔐 OTP GENERATED FOR: $email'" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Check database:" -ForegroundColor Yellow
    Write-Host "   SELECT * FROM otps WHERE email = '$email';" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Check email inbox:" -ForegroundColor Yellow
    Write-Host "   Subject: 'Your Login OTP'" -ForegroundColor White
    Write-Host "   (Also check spam/junk folder)" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Verify OTP:" -ForegroundColor Yellow
    Write-Host "   Enter the OTP in the frontend verification page" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "❌ OTP Request Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Is backend running on port 8080?" -ForegroundColor White
    Write-Host "2. Check backend logs for errors" -ForegroundColor White
    Write-Host "3. Verify database connection" -ForegroundColor White
    Write-Host "4. Verify Vault configuration" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📧 Email Configuration Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    $emailConfig = Invoke-RestMethod -Uri "http://localhost:8080/api/test/email-config" -Method GET
    Write-Host "✅ Email Configuration: $emailConfig" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Email Configuration: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   This might affect email delivery" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
