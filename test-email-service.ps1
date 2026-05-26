Write-Host "============================================" -ForegroundColor Cyan
Write-Host "TESTING EMAIL SERVICE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080"

Write-Host ""
Write-Host "1. Testing SendGrid configuration..." -ForegroundColor Yellow

try {
    $configResponse = Invoke-RestMethod -Uri "$baseUrl/api/test/email-config" -Method GET
    Write-Host "✅ SendGrid Config: $configResponse" -ForegroundColor Green
} catch {
    Write-Host "❌ SendGrid Config Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing OTP email sending..." -ForegroundColor Yellow

$testEmail = "nikita.a@omoikaneinnovations.com"
$testOtp = "1234"

try {
    $otpResponse = Invoke-RestMethod -Uri "$baseUrl/api/test/send-otp?email=$testEmail&otp=$testOtp" -Method POST
    Write-Host "✅ Test OTP: $otpResponse" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Check your application console for detailed logs!" -ForegroundColor Cyan
    Write-Host "📧 Check your email (including spam folder)!" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Test OTP Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "IMPORTANT NOTES:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "• Check your application console for OTP codes" -ForegroundColor Yellow
Write-Host "• Use console OTP to complete login process" -ForegroundColor Yellow
Write-Host "• Check email spam/junk folder" -ForegroundColor Yellow
Write-Host "• Look for detailed email logs in console" -ForegroundColor Yellow
Write-Host ""