# Test Coupon Validation Fix
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Coupon Validation (Fixed)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# First, login to get token
Write-Host "`n1. Logging in..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"phoneNumber":"1234567890","password":"admin123"}'

$token = $loginResponse.token
Write-Host "✓ Login successful" -ForegroundColor Green
Write-Host "Token: $($token.Substring(0,20))..." -ForegroundColor Gray

# Test coupon validation
Write-Host "`n2. Testing coupon validation..." -ForegroundColor Yellow

$couponRequest = @{
    couponCode = "FIRST50"
    orderValue = 500
    restaurantId = 1
} | ConvertTo-Json

try {
    $startTime = Get-Date
    
    $couponResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/coupons/validate" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $token"} `
        -Body $couponRequest
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    
    Write-Host "✓ Coupon validation successful!" -ForegroundColor Green
    Write-Host "Response time: $duration ms" -ForegroundColor Cyan
    Write-Host "Valid: $($couponResponse.valid)" -ForegroundColor White
    Write-Host "Discount: ₹$($couponResponse.discount)" -ForegroundColor White
    Write-Host "Message: $($couponResponse.message)" -ForegroundColor White
    
    if ($duration -lt 2000) {
        Write-Host "`n✓ PERFORMANCE: Response time is good (<2s)" -ForegroundColor Green
    } else {
        Write-Host "`n⚠ WARNING: Response time is slow (>2s)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "✗ Coupon validation failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test with invalid coupon
Write-Host "`n3. Testing with invalid coupon..." -ForegroundColor Yellow

$invalidRequest = @{
    couponCode = "INVALID123"
    orderValue = 500
    restaurantId = 1
} | ConvertTo-Json

try {
    $invalidResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/coupons/validate" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $token"} `
        -Body $invalidRequest
    
    Write-Host "Valid: $($invalidResponse.valid)" -ForegroundColor White
    Write-Host "Message: $($invalidResponse.message)" -ForegroundColor White
    
} catch {
    Write-Host "Response received (expected behavior)" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
