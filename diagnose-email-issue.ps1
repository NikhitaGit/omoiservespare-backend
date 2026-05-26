Write-Host "============================================" -ForegroundColor Cyan
Write-Host "DIAGNOSING EMAIL OTP ISSUE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Checking email configuration..." -ForegroundColor Yellow

# Check if SendGrid config exists
$appProps = Get-Content "src/main/resources/application.properties" -Raw

if ($appProps.Contains("sendgrid.api.key")) {
    Write-Host "✅ SendGrid API key configured" -ForegroundColor Green
} else {
    Write-Host "❌ SendGrid API key missing" -ForegroundColor Red
}

if ($appProps.Contains("sendgrid.from.email")) {
    Write-Host "✅ SendGrid from email configured" -ForegroundColor Green
} else {
    Write-Host "❌ SendGrid from email missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Email Issue Troubleshooting Guide:" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. CHECK CONSOLE OUTPUT:" -ForegroundColor Yellow
Write-Host "   Look for this in your application console:" -ForegroundColor White
Write-Host "   ===========================================" -ForegroundColor Gray
Write-Host "   🔐 OTP GENERATED FOR: your-email@domain.com" -ForegroundColor Gray
Write-Host "   📧 OTP CODE: 1234" -ForegroundColor Gray
Write-Host "   ⏰ EXPIRES AT: 2026-03-17T15:30:00" -ForegroundColor Gray
Write-Host "   ===========================================" -ForegroundColor Gray
Write-Host ""

Write-Host "2. COMMON EMAIL ISSUES:" -ForegroundColor Yellow
Write-Host "   • Check SPAM/JUNK folder" -ForegroundColor White
Write-Host "   • SendGrid API key might be invalid/expired" -ForegroundColor White
Write-Host "   • Email domain verification required" -ForegroundColor White
Write-Host "   • Rate limiting by SendGrid" -ForegroundColor White
Write-Host "   • Network connectivity issues" -ForegroundColor White
Write-Host ""

Write-Host "3. IMMEDIATE WORKAROUND:" -ForegroundColor Yellow
Write-Host "   • Use the OTP code from console output" -ForegroundColor White
Write-Host "   • The OTP is valid for 5 minutes" -ForegroundColor White
Write-Host "   • You can complete login without receiving email" -ForegroundColor White
Write-Host ""

Write-Host "4. CHECK APPLICATION LOGS:" -ForegroundColor Yellow
Write-Host "   Look for these log messages:" -ForegroundColor White
Write-Host "   • 'Sending OTP email to: your-email'" -ForegroundColor Gray
Write-Host "   • 'OTP email sent successfully'" -ForegroundColor Green
Write-Host "   • 'Failed to send OTP email'" -ForegroundColor Red
Write-Host ""

Write-Host "5. TEST EMAIL MANUALLY:" -ForegroundColor Yellow
Write-Host "   Run this command to test SendGrid:" -ForegroundColor White
Write-Host "   curl -X POST https://api.sendgrid.com/v3/mail/send \" -ForegroundColor Gray
Write-Host "     -H 'Authorization: Bearer YOUR_API_KEY' \" -ForegroundColor Gray
Write-Host "     -H 'Content-Type: application/json' \" -ForegroundColor Gray
Write-Host "     -d '{...}'" -ForegroundColor Gray
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check your application console for OTP code" -ForegroundColor White
Write-Host "2. Use the console OTP to complete login" -ForegroundColor White
Write-Host "3. Check email spam/junk folder" -ForegroundColor White
Write-Host "4. If needed, we can fix SendGrid configuration" -ForegroundColor White
Write-Host ""