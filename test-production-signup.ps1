# =====================================================
# Production Signup System Test Script
# =====================================================
# Tests vendor registration and admin creation flows

$baseUrl = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔐 PRODUCTION SIGNUP SYSTEM TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# =====================================================
# TEST 1: Vendor Registration
# =====================================================
Write-Host "📝 TEST 1: Vendor Registration" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

$vendorData = @{
    email = "testvendor@example.com"
    phoneNumber = "+1234567890"
    restaurantName = "Test Restaurant"
    ownerName = "John Doe"
    address = "123 Main St, Test City"
    businessLicense = "BL123456789"
    description = "We serve delicious food with love"
} | ConvertTo-Json

try {
    Write-Host "Registering vendor..." -ForegroundColor Gray
    $vendorResponse = Invoke-RestMethod -Uri "$baseUrl/api/vendor/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $vendorData
    
    Write-Host "✅ Vendor registered successfully!" -ForegroundColor Green
    Write-Host "   Email: $($vendorResponse.email)" -ForegroundColor Gray
    Write-Host "   Status: $($vendorResponse.status)" -ForegroundColor Gray
    Write-Host "   Message: $($vendorResponse.message)" -ForegroundColor Gray
} catch {
    $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "⚠️  $($errorDetails.message)" -ForegroundColor Yellow
}

Write-Host ""

# =====================================================
# TEST 2: Check Vendor Status
# =====================================================
Write-Host "📊 TEST 2: Check Vendor Application Status" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

try {
    Write-Host "Checking status for: testvendor@example.com" -ForegroundColor Gray
    $statusResponse = Invoke-RestMethod -Uri "$baseUrl/api/vendor/status/testvendor@example.com" `
        -Method GET
    
    Write-Host "✅ Status retrieved!" -ForegroundColor Green
    Write-Host "   Status: $($statusResponse.status)" -ForegroundColor Gray
    Write-Host "   Message: $($statusResponse.message)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to check status" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# =====================================================
# TEST 3: Create First Admin
# =====================================================
Write-Host "👑 TEST 3: Create First Admin" -ForegroundColor Yellow
Write-Host "-----------------------------" -ForegroundColor Yellow

$adminData = @{
    email = "admin@company.com"
    phoneNumber = "+9876543210"
    fullName = "System Administrator"
    secretKey = "qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG"
} | ConvertTo-Json

try {
    Write-Host "Creating first admin..." -ForegroundColor Gray
    $adminResponse = Invoke-RestMethod -Uri "$baseUrl/api/admin/create-first" `
        -Method POST `
        -ContentType "application/json" `
        -Body $adminData
    
    Write-Host "✅ First admin created successfully!" -ForegroundColor Green
    Write-Host "   Email: $($adminResponse.email)" -ForegroundColor Gray
    Write-Host "   Role: $($adminResponse.role)" -ForegroundColor Gray
} catch {
    $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "⚠️  $($errorDetails.message)" -ForegroundColor Yellow
}

Write-Host ""

# =====================================================
# TEST 4: Admin Login
# =====================================================
Write-Host "🔑 TEST 4: Admin Login" -ForegroundColor Yellow
Write-Host "----------------------" -ForegroundColor Yellow

$loginData = @{
    email = "admin@company.com"
    phoneNumber = "+9876543210"
} | ConvertTo-Json

try {
    Write-Host "Logging in as admin..." -ForegroundColor Gray
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginData
    
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "   OTP sent to: $($loginResponse.message)" -ForegroundColor Gray
    
    # Store for later use
    $global:adminEmail = "admin@company.com"
    
    Write-Host ""
    Write-Host "⚠️  MANUAL STEP REQUIRED:" -ForegroundColor Yellow
    Write-Host "   1. Check console logs for OTP" -ForegroundColor Gray
    Write-Host "   2. Run the verification step below" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Login failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# =====================================================
# TEST 5: Get Pending Vendors (Requires Admin Token)
# =====================================================
Write-Host "📋 TEST 5: Get Pending Vendors (Admin Only)" -ForegroundColor Yellow
Write-Host "--------------------------------------------" -ForegroundColor Yellow
Write-Host "⚠️  This requires admin JWT token from OTP verification" -ForegroundColor Yellow
Write-Host "   Run this after verifying OTP:" -ForegroundColor Gray
Write-Host ""
Write-Host '   $token = "<your-jwt-token>"' -ForegroundColor Cyan
Write-Host '   $vendors = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/pending" `' -ForegroundColor Cyan
Write-Host '       -Method GET `' -ForegroundColor Cyan
Write-Host '       -Headers @{ Authorization = "Bearer $token" }' -ForegroundColor Cyan
Write-Host '   $vendors' -ForegroundColor Cyan

Write-Host ""

# =====================================================
# TEST 6: Approve Vendor (Requires Admin Token)
# =====================================================
Write-Host "✅ TEST 6: Approve Vendor (Admin Only)" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
Write-Host "⚠️  This requires admin JWT token and vendor ID" -ForegroundColor Yellow
Write-Host "   Run this after getting pending vendors:" -ForegroundColor Gray
Write-Host ""
Write-Host '   $approvalData = @{' -ForegroundColor Cyan
Write-Host '       action = "APPROVE"' -ForegroundColor Cyan
Write-Host '       reason = "All documents verified"' -ForegroundColor Cyan
Write-Host '   } | ConvertTo-Json' -ForegroundColor Cyan
Write-Host ''
Write-Host '   Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/1/process" `' -ForegroundColor Cyan
Write-Host '       -Method POST `' -ForegroundColor Cyan
Write-Host '       -ContentType "application/json" `' -ForegroundColor Cyan
Write-Host '       -Headers @{ Authorization = "Bearer $token" } `' -ForegroundColor Cyan
Write-Host '       -Body $approvalData' -ForegroundColor Cyan

Write-Host ""

# =====================================================
# Summary
# =====================================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📊 TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Vendor Registration: Public endpoint" -ForegroundColor Green
Write-Host "✅ Vendor Status Check: Public endpoint" -ForegroundColor Green
Write-Host "✅ First Admin Creation: Secret key required" -ForegroundColor Green
Write-Host "⚠️  Admin Login: Requires OTP verification" -ForegroundColor Yellow
Write-Host "⚠️  Vendor Management: Requires admin JWT token" -ForegroundColor Yellow
Write-Host ""
Write-Host "📖 For complete documentation, see: PRODUCTION_SIGNUP_SYSTEM.md" -ForegroundColor Cyan
Write-Host ""

# =====================================================
# Quick Reference
# =====================================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔗 QUICK REFERENCE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Public Endpoints:" -ForegroundColor White
Write-Host "  POST /api/vendor/register" -ForegroundColor Gray
Write-Host "  GET  /api/vendor/status/{email}" -ForegroundColor Gray
Write-Host "  POST /api/admin/create-first" -ForegroundColor Gray
Write-Host ""
Write-Host "Protected Endpoints (Admin Only):" -ForegroundColor White
Write-Host "  POST /api/admin/create" -ForegroundColor Gray
Write-Host "  GET  /api/admin/vendors/pending" -ForegroundColor Gray
Write-Host "  GET  /api/admin/vendors" -ForegroundColor Gray
Write-Host "  POST /api/admin/vendors/{id}/process" -ForegroundColor Gray
Write-Host "  POST /api/admin/vendors/{id}/suspend" -ForegroundColor Gray
Write-Host ""
