# Test Unified Authentication System
$baseUrl = "http://localhost:8080/api/v2/auth"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "UNIFIED AUTH SYSTEM TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Signup as USER
Write-Host "Test 1: Signup as USER" -ForegroundColor Yellow
$userSignup = @{
    email = "testuser@example.com"
    password = "password123"
    companyName = "Test Company"
    phoneNumber = "+1234567890"
    role = "USER"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/signup" -Method POST -ContentType "application/json" -Body $userSignup
    Write-Host "  SUCCESS: User created" -ForegroundColor Green
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.user.role)" -ForegroundColor Gray
    Write-Host "  Token: $($response.accessToken.Substring(0, 20))..." -ForegroundColor Gray
    $userToken = $response.accessToken
} catch {
    Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Signup as VENDOR
Write-Host "Test 2: Signup as VENDOR" -ForegroundColor Yellow
$vendorSignup = @{
    email = "testvendor@example.com"
    password = "vendor123"
    companyName = "Vendor Restaurant"
    phoneNumber = "+9876543210"
    role = "VENDOR"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/signup" -Method POST -ContentType "application/json" -Body $vendorSignup
    Write-Host "  SUCCESS: Vendor created" -ForegroundColor Green
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.user.role)" -ForegroundColor Gray
    Write-Host "  Status: $($response.user.vendorStatus)" -ForegroundColor Gray
    Write-Host "  Message: $($response.message)" -ForegroundColor Gray
    $vendorToken = $response.accessToken
} catch {
    Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Login as USER
Write-Host "Test 3: Login as USER" -ForegroundColor Yellow
$userLogin = @{
    email = "testuser@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -ContentType "application/json" -Body $userLogin
    Write-Host "  SUCCESS: User logged in" -ForegroundColor Green
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.user.role)" -ForegroundColor Gray
} catch {
    Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Login as VENDOR
Write-Host "Test 4: Login as VENDOR" -ForegroundColor Yellow
$vendorLogin = @{
    email = "testvendor@example.com"
    password = "vendor123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -ContentType "application/json" -Body $vendorLogin
    Write-Host "  SUCCESS: Vendor logged in" -ForegroundColor Green
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.user.role)" -ForegroundColor Gray
    Write-Host "  Status: $($response.user.vendorStatus)" -ForegroundColor Gray
} catch {
    Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 5: Login as ADMIN (if exists)
Write-Host "Test 5: Login as ADMIN" -ForegroundColor Yellow
Write-Host "  First, set password for admin..." -ForegroundColor Gray
Write-Host "  Run: .\set-admin-password.ps1" -ForegroundColor Gray

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Set admin password: .\set-admin-password.ps1" -ForegroundColor Gray
Write-Host "2. Update frontend to use new API" -ForegroundColor Gray
Write-Host "3. Test role-based access" -ForegroundColor Gray
