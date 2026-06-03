# Test Email on Render
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Testing OTP Email on Render" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$email = Read-Host "Enter your test email address"

$body = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = $email
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Write-Host ""
Write-Host "Sending OTP request to Render..." -ForegroundColor Yellow
Write-Host "URL: https://omoiservespare-backend.onrender.com/api/auth/user/login" -ForegroundColor Gray
Write-Host "Endpoint: /api/auth/user/login (NOT /send-otp)" -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "https://omoiservespare-backend.onrender.com/api/auth/user/login" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "Response from server:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  ✅ Request Sent Successfully" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Check your email: $email" -ForegroundColor White
    Write-Host "  2. Check spam folder if not in inbox" -ForegroundColor White
    Write-Host "  3. Check Render logs for:" -ForegroundColor White
    Write-Host "     - '🔐 OTP GENERATED FOR: $email'" -ForegroundColor Gray
    Write-Host "     - '📧 EMAIL SERVICE: OTP Send Initiated'" -ForegroundColor Gray
    Write-Host "     - '✅ EMAIL SENT SUCCESSFULLY'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "If OTP logs appear but NO email logs:" -ForegroundColor Yellow
    Write-Host "  → Async email is failing silently" -ForegroundColor White
    Write-Host "  → Check EMAIL_ASYNC_ISSUE_FIX.md" -ForegroundColor White
    Write-Host "  → Verify SENDER_PASSWORD is correct app password" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "  ❌ Request Failed" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor White
    Write-Host ""
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "  1. Render service is down" -ForegroundColor White
    Write-Host "  2. HR validation failed (wrong company name)" -ForegroundColor White
    Write-Host "  3. Network connectivity issue" -ForegroundColor White
    Write-Host ""
}
