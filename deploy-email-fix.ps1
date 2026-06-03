# Deploy Email Fix to Render
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Deploying Email Fix to Render" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Changes made:" -ForegroundColor Yellow
Write-Host "  ✓ Removed @Async from EmailService (errors now visible)" -ForegroundColor Green
Write-Host "  ✓ Added try-catch in AuthService (catches email errors)" -ForegroundColor Green
Write-Host "  ✓ Enhanced EmailTestService (better SMTP diagnostics)" -ForegroundColor Green
Write-Host ""

$confirm = Read-Host "Do you want to commit and deploy these changes? (y/n)"

if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    Write-Host ""
    Write-Host "Committing changes..." -ForegroundColor Yellow
    
    git add src/main/java/com/omoikaneinnovations/omoiservespare/service/EmailService.java
    git add src/main/java/com/omoikaneinnovations/omoiservespare/service/AuthService.java
    git add src/main/java/com/omoikaneinnovations/omoiservespare/service/EmailTestService.java
    
    git commit -m "Fix: Make email sending synchronous for production debugging

- Removed @Async from EmailService.sendOtpEmail()
- Added explicit error handling in AuthService
- Enhanced EmailTestService with SMTP diagnostics
- Email errors will now appear in Render logs immediately"
    
    Write-Host ""
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  ✅ Changes Deployed!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Wait 5-10 minutes for Render to rebuild" -ForegroundColor White
    Write-Host "  2. Run: .\test-email-render.ps1" -ForegroundColor White
    Write-Host "  3. Check Render logs for SMTP errors (if any)" -ForegroundColor White
    Write-Host ""
    Write-Host "Expected logs if email works:" -ForegroundColor Cyan
    Write-Host "  🔐 OTP GENERATED FOR: ..." -ForegroundColor Gray
    Write-Host "  Calling emailService.sendOtpEmail() for: ..." -ForegroundColor Gray
    Write-Host "  📧 EMAIL SERVICE: OTP Send Initiated" -ForegroundColor Gray
    Write-Host "  ✅ EMAIL SENT SUCCESSFULLY" -ForegroundColor Gray
    Write-Host "  ✅ Email service call completed successfully" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Expected logs if email FAILS:" -ForegroundColor Yellow
    Write-Host "  🔐 OTP GENERATED FOR: ..." -ForegroundColor Gray
    Write-Host "  Calling emailService.sendOtpEmail() for: ..." -ForegroundColor Gray
    Write-Host "  ❌ SMTP MAIL EXCEPTION" -ForegroundColor Red
    Write-Host "  ❌ EMAIL SENDING FAILED: [actual error message]" -ForegroundColor Red
    Write-Host ""
    Write-Host "Test endpoints available:" -ForegroundColor Cyan
    Write-Host "  GET  /api/test/email-config (tests SMTP connection)" -ForegroundColor White
    Write-Host "  POST /api/test/send-otp?email=X&otp=Y (tests full email)" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    Write-Host ""
}
