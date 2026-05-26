# Test Signup and Login
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING SIGNUP AND LOGIN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Signup
Write-Host "Step 1: Creating a new user..." -ForegroundColor Yellow
$signupData = @{
    email = "test@example.com"
    password = "test123"
    companyName = "Test Company"
    phoneNumber = "+1234567890"
    role = "USER"
} | ConvertTo-Json

try {
    $signupResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/signup" `
        -Method POST `
        -Body $signupData `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "SUCCESS - User created!" -ForegroundColor Green
    Write-Host "Email: test@example.com" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "Signup result: $_" -ForegroundColor Yellow
    Write-Host "(User might already exist - continuing to login test)" -ForegroundColor White
    Write-Host ""
}

# Step 2: Login
Write-Host "Step 2: Testing login..." -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginData `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS - LOGIN WORKS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "JWT Token:" -ForegroundColor Yellow
    Write-Host $loginResponse.token -ForegroundColor White
    Write-Host ""
    Write-Host "User Info:" -ForegroundColor Yellow
    $loginResponse.userInfo | Format-List
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "YOUR BACKEND IS WORKING!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Your frontend at http://localhost:5173 can now connect" -ForegroundColor White
    Write-Host "2. Use email + password to login (NO OTP)" -ForegroundColor White
    Write-Host "3. Backend will return JWT token" -ForegroundColor White
    Write-Host "4. Store token and use for API calls" -ForegroundColor White
    
} catch {
    Write-Host "LOGIN FAILED" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}
