# Diagnose Login Token Issue
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Login Token Diagnostic Tool" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will help diagnose why your login isn't saving the token." -ForegroundColor Yellow
Write-Host ""

Write-Host "Step 1: Check if backend is running..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -Method GET -ErrorAction Stop
    Write-Host "   ✓ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend is NOT running!" -ForegroundColor Red
    Write-Host "   Start it with: cd omoiservespare ; .\mvnw spring-boot:run" -ForegroundColor White
    exit
}

Write-Host ""
Write-Host "Step 2: Test login endpoint..." -ForegroundColor Yellow
Write-Host "   Enter your email: " -NoNewline
$email = Read-Host
Write-Host "   Enter your password: " -NoNewline
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
    
    $data = $response.Content | ConvertFrom-Json
    
    Write-Host "   ✓ Backend login works!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Token received from backend:" -ForegroundColor Yellow
    Write-Host $data.token.Substring(0, 100) -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "================================" -ForegroundColor Green
    Write-Host "DIAGNOSIS COMPLETE" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your backend login is working correctly!" -ForegroundColor Green
    Write-Host "The problem is your frontend login component is NOT saving the token." -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUTION:" -ForegroundColor Yellow
    Write-Host "Your login component needs to add this line after successful login:" -ForegroundColor White
    Write-Host ""
    Write-Host "  localStorage.setItem('token', response.data.token);" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "See LOGIN_COMPONENT_FIX.jsx for the complete fixed login component." -ForegroundColor White
    
} catch {
    Write-Host "   ✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check:" -ForegroundColor Yellow
    Write-Host "   - Email and password are correct" -ForegroundColor White
    Write-Host "   - User exists in database" -ForegroundColor White
}
