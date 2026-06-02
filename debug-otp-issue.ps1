# Debug OTP Generation Issue
# This script helps diagnose why OTP is not being generated or saved

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔍 OTP Generation Debug" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$email = "nikita.a@omoikaneinnovations.com"
$company = "Omoiservespare Pvt Ltd"

Write-Host "Step 1: Test Login Request" -ForegroundColor Yellow
Write-Host ""

$loginBody = @{
    companyName = $company
    email = $email
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Write-Host "Sending login request..." -ForegroundColor White

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -Verbose
    
    Write-Host "✅ Response received:" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json) -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "❌ Request failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 2: Check Database for OTP" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Run this SQL query in pgAdmin:" -ForegroundColor White
Write-Host "SELECT * FROM otps WHERE email = '$email' ORDER BY id DESC LIMIT 1;" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 3: Check Backend Console" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Look for these log lines in your backend console:" -ForegroundColor White
Write-Host ""
Write-Host "1. Login attempt log:" -ForegroundColor Yellow
Write-Host "   User/Admin login attempt: $email from company: $company" -ForegroundColor Gray
Write-Host ""
Write-Host "2. OTP generation log:" -ForegroundColor Yellow
Write-Host "   ==========================================" -ForegroundColor Gray
Write-Host "   🔐 OTP GENERATED FOR: $email" -ForegroundColor Gray
Write-Host "   📧 OTP CODE: 1234" -ForegroundColor Gray
Write-Host "   ⏰ EXPIRES AT: ..." -ForegroundColor Gray
Write-Host "   ==========================================" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Email sending log:" -ForegroundColor Yellow
Write-Host "   OTP email sent successfully to $email" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 4: Check Email Configuration" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing email configuration..." -ForegroundColor White

try {
    $emailTest = Invoke-RestMethod -Uri "http://localhost:8080/api/test/email-config" -Method GET
    Write-Host "✅ Email Config: $emailTest" -ForegroundColor Green
} catch {
    Write-Host "❌ Email Config Test Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📋 Common Issues" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Issue 1: Vault Email Credentials Not Configured" -ForegroundColor Yellow
Write-Host "  Solution: Check if Vault has these secrets:" -ForegroundColor White
Write-Host "    - vault.mail.username" -ForegroundColor Gray
Write-Host "    - vault.mail.password" -ForegroundColor Gray
Write-Host "    - vault.mail.from" -ForegroundColor Gray
Write-Host ""

Write-Host "Issue 2: OTP Generation Method Not Called" -ForegroundColor Yellow
Write-Host "  Solution: Check ProductionAuthService.userAdminLogin()" -ForegroundColor White
Write-Host "  Should call: otpAuthService.generateAndSendOtp()" -ForegroundColor Gray
Write-Host ""

Write-Host "Issue 3: Email Service Failing Silently" -ForegroundColor Yellow
Write-Host "  Solution: Check backend logs for email errors" -ForegroundColor White
Write-Host "  Look for: 'Failed to send OTP email'" -ForegroundColor Gray
Write-Host ""

Write-Host "Issue 4: @Async Not Working" -ForegroundColor Yellow
Write-Host "  Email sending is async - errors might not show" -ForegroundColor White
Write-Host "  Solution: Check for any async-related errors" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
