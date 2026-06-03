# Test OTP Email Sending
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing OTP Generation and Email Sending" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test data - use a valid email from MockHRDataService
$testCompany = "Omoiservespare Pvt Ltd"
$testEmail = "nikita.a@omoikaneinnovations.com"  # Valid test user from mock HR
$testPhone = "+91-9876543210"

Write-Host "Test Credentials:" -ForegroundColor Yellow
Write-Host "Company: $testCompany" -ForegroundColor White
Write-Host "Email: $testEmail" -ForegroundColor White
Write-Host "Phone: $testPhone`n" -ForegroundColor White

# Call the USER/ADMIN login endpoint (triggers OTP)
$body = @{
    companyName = $testCompany
    email = $testEmail
    phoneNumber = $testPhone
} | ConvertTo-Json

Write-Host "Sending request to: http://localhost:8080/api/auth/user/login" -ForegroundColor Yellow
Write-Host "This should trigger OTP generation and email sending...`n" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ SUCCESS! OTP REQUEST SENT" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    Write-Host "Response:" -ForegroundColor Cyan
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor White
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "WHAT TO CHECK NOW:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    Write-Host "`n1. CHECK BACKEND CONSOLE LOGS:" -ForegroundColor Yellow
    Write-Host "   Look for these messages:" -ForegroundColor White
    Write-Host "   ✓ '🔐 OTP GENERATED FOR: $testEmail'" -ForegroundColor Green
    Write-Host "   ✓ '📧 OTP CODE: xxxx'" -ForegroundColor Green
    Write-Host "   ✓ 'Starting OTP email send to $testEmail'" -ForegroundColor Green
    Write-Host "   ✓ 'OTP email sent successfully to $testEmail'" -ForegroundColor Green
    
    Write-Host "`n2. CHECK YOUR EMAIL INBOX:" -ForegroundColor Yellow
    Write-Host "   Email: $testEmail" -ForegroundColor White
    Write-Host "   Subject: 'Your Login OTP'" -ForegroundColor White
    Write-Host "   Check spam folder too!" -ForegroundColor White
    
    Write-Host "`n3. IF NO EMAIL RECEIVED:" -ForegroundColor Yellow
    Write-Host "   ✓ Check if OTP logs appear in backend console" -ForegroundColor White
    Write-Host "   ✓ Check for 'EMAIL SENDING FAILED' error in logs" -ForegroundColor White
    Write-Host "   ✓ Verify Gmail App Password: bbfskhrhtnujkokk" -ForegroundColor White
    Write-Host "   ✓ Verify SMTP settings in application.properties" -ForegroundColor White
    
} catch {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "❌ REQUEST FAILED" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    
    Write-Host "Error Details:" -ForegroundColor Yellow
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        Write-Host "Server Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nPossible reasons:" -ForegroundColor Yellow
    Write-Host "1. Backend is not running on port 8080" -ForegroundColor White
    Write-Host "2. Email not found in HR system (MockHRDataService)" -ForegroundColor White
    Write-Host "3. Invalid company name" -ForegroundColor White
    Write-Host "4. Check backend logs for detailed error" -ForegroundColor White
}

Write-Host "`n" -ForegroundColor White
