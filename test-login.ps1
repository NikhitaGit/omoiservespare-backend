# Test Login API
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Login API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test data
$loginData = @{
    companyName = "Omoikane"
    email = "user1@example.com"
    phoneNumber = "9876543210"
    accountType = "EMPLOYEE"
} | ConvertTo-Json

Write-Host "Sending login request..." -ForegroundColor Yellow
Write-Host "Email: user1@example.com" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/login" `
        -Method Post `
        -Body $loginData `
        -ContentType "application/json" `
        -TimeoutSec 15
    
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Check the application console for OTP!" -ForegroundColor Yellow
    Write-Host "Look for lines like:" -ForegroundColor Gray
    Write-Host "  🔐 OTP GENERATED FOR: user1@example.com" -ForegroundColor Gray
    Write-Host "  📧 OTP CODE: 1234" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Message -like "*timeout*") {
        Write-Host "⚠️  Timeout Error - Check if:" -ForegroundColor Yellow
        Write-Host "  1. Application is running" -ForegroundColor Gray
        Write-Host "  2. Redis is running" -ForegroundColor Gray
        Write-Host "  3. PostgreSQL is running" -ForegroundColor Gray
    }
    
    if ($_.Exception.Message -like "*500*") {
        Write-Host "⚠️  Server Error - Check application logs" -ForegroundColor Yellow
    }
}

Write-Host ""
