# Test email sending functionality
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Testing Email Configuration" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`n1. Testing email configuration..." -ForegroundColor Yellow

$testEmail = "test@example.com"
$response = curl -X POST http://localhost:8080/api/auth/generate-otp `
    -H "Content-Type: application/json" `
    -d "{`"email`":`"$testEmail`",`"userType`":`"USER`"}"

Write-Host $response

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Check your backend console logs for:" -ForegroundColor Green
Write-Host "  - 'OTP email sent successfully'" -ForegroundColor White
Write-Host "  - Or any email sending errors" -ForegroundColor White
Write-Host "==================================" -ForegroundColor Cyan
