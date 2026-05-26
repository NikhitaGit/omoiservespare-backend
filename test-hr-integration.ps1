#!/usr/bin/env pwsh

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔍 TESTING HR API INTEGRATION" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080"

# Test data
$testCompany = "Omoikane Innovations"
$testEmail = "john.doe@omoikaneinnovations.com"
$testPhone = "+91-9876543210"

Write-Host ""
Write-Host "📋 Test Configuration:" -ForegroundColor Yellow
Write-Host "  Company: $testCompany"
Write-Host "  Email: $testEmail"
Write-Host "  Phone: $testPhone"
Write-Host ""

# Test 1: Login with valid HR credentials
Write-Host "🧪 Test 1: Login with valid HR credentials" -ForegroundColor Green
Write-Host "-------------------------------------------"

$loginPayload = @{
    companyName = $testCompany
    email = $testEmail
    phoneNumber = $testPhone
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginPayload -ContentType "application/json"
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor White
} catch {
    Write-Host "❌ Login failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorBody = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorBody)
        $errorText = $reader.ReadToEnd()
        Write-Host "Error details: $errorText" -ForegroundColor Red
    }
}

Write-Host ""

# Test 2: Login with invalid company
Write-Host "🧪 Test 2: Login with invalid company" -ForegroundColor Green
Write-Host "--------------------------------------"

$invalidCompanyPayload = @{
    companyName = "Invalid Company"
    email = $testEmail
    phoneNumber = $testPhone
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $invalidCompanyPayload -ContentType "application/json"
    Write-Host "⚠️ Unexpected success with invalid company!" -ForegroundColor Yellow
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor White
} catch {
    Write-Host "✅ Correctly rejected invalid company!" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor White
}

Write-Host ""

# Test 3: Login with invalid email
Write-Host "🧪 Test 3: Login with invalid email" -ForegroundColor Green
Write-Host "------------------------------------"

$invalidEmailPayload = @{
    companyName = $testCompany
    email = "invalid@wrongcompany.com"
    phoneNumber = $testPhone
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $invalidEmailPayload -ContentType "application/json"
    Write-Host "⚠️ Unexpected success with invalid email!" -ForegroundColor Yellow
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor White
} catch {
    Write-Host "✅ Correctly rejected invalid email!" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor White
}

Write-Host ""

# Test 4: Check application health
Write-Host "🧪 Test 4: Application health check" -ForegroundColor Green
Write-Host "------------------------------------"

try {
    $healthResponse = Invoke-RestMethod -Uri "$baseUrl/actuator/health" -Method GET -ErrorAction SilentlyContinue
    Write-Host "✅ Application is healthy!" -ForegroundColor Green
    Write-Host "Health status: $($healthResponse.status)" -ForegroundColor White
} catch {
    Write-Host "⚠️ Health endpoint not available (this is normal)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🎯 HR API INTEGRATION TEST COMPLETED" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. If tests pass, the HR integration is working correctly"
Write-Host "2. Update hr.api.enabled=true in application.properties when ready for production"
Write-Host "3. Configure actual HR API URL and token for production use"
Write-Host "4. Test with real HR system credentials"