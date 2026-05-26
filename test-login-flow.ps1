# Test Login Flow Script
# This script tests if your backend login endpoint is working

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Testing Login Flow" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if backend is running
Write-Host "1. Checking if backend is running..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -Method GET -ErrorAction Stop
    Write-Host "   ✓ Backend is running!" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend is NOT running!" -ForegroundColor Red
    Write-Host "   Please start backend first:" -ForegroundColor Yellow
    Write-Host "   cd omoiservespare" -ForegroundColor White
    Write-Host "   .\mvnw spring-boot:run" -ForegroundColor White
    exit
}

Write-Host ""

# Test login endpoint
Write-Host "2. Testing login endpoint..." -ForegroundColor Yellow
Write-Host "   Enter your email: " -ForegroundColor White -NoNewline
$email = Read-Host
Write-Host "   Enter your password: " -ForegroundColor White -NoNewline
$password = Read-Host -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

$loginBody = @{
    email = $email
    password = $passwordPlain
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    $responseData = $response.Content | ConvertFrom-Json
    
    Write-Host "   ✓ Login successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "3. Token received:" -ForegroundColor Yellow
    Write-Host "   $($responseData.token.Substring(0, 50))..." -ForegroundColor White
    Write-Host ""
    Write-Host "4. Next steps:" -ForegroundColor Yellow
    Write-Host "   a. Open your browser to: http://localhost:5173/login" -ForegroundColor White
    Write-Host "   b. Login with the same credentials" -ForegroundColor White
    Write-Host "   c. After login, open browser console (F12) and run:" -ForegroundColor White
    Write-Host "      localStorage.getItem('token')" -ForegroundColor Cyan
    Write-Host "   d. You should see a token similar to the one above" -ForegroundColor White
    Write-Host "   e. Then go to Raise Ticket page - it should work!" -ForegroundColor White
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "Backend login is working! ✓" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    
} catch {
    Write-Host "   ✗ Login failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "   - Wrong email or password" -ForegroundColor White
    Write-Host "   - User doesn't exist in database" -ForegroundColor White
    Write-Host "   - Backend authentication issue" -ForegroundColor White
    Write-Host ""
    Write-Host "To check if user exists, run this SQL:" -ForegroundColor Yellow
    Write-Host "   SELECT email, phone_number FROM users WHERE email = '$email';" -ForegroundColor Cyan
}
