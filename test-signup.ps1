# Test Signup API
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Signup API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test data
$signupData = @{
    companyName = "Test Company"
    email = "testuser@example.com"
    password = "password123"
    confirmPassword = "password123"
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

Write-Host "Creating new user account..." -ForegroundColor Yellow
Write-Host "Company: Test Company" -ForegroundColor Gray
Write-Host "Email: testuser@example.com" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/auth/signup" `
        -Method Post `
        -Body $signupData `
        -ContentType "application/json" `
        -TimeoutSec 15
    
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
    
    if ($response.success) {
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Account created! Now test login:" -ForegroundColor Green
        Write-Host ""
        Write-Host "1. Run: .\test-login.ps1" -ForegroundColor Yellow
        Write-Host "2. Use email: testuser@example.com" -ForegroundColor Yellow
        Write-Host "3. Check console for OTP" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Message -like "*timeout*") {
        Write-Host "⚠️  Timeout Error - Check if application is running" -ForegroundColor Yellow
    }
    
    if ($_.Exception.Message -like "*400*") {
        Write-Host "⚠️  Bad Request - Check if user already exists" -ForegroundColor Yellow
    }
    
    if ($_.Exception.Message -like "*500*") {
        Write-Host "⚠️  Server Error - Check application logs" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "To test with different email, edit this script and change the email field" -ForegroundColor Gray
Write-Host ""