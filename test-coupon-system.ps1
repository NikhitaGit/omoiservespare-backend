# Test Coupon System
# PowerShell script to test all coupon endpoints

Write-Host "🎟️  Testing Coupon System..." -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"

# Test 1: Get All Coupons
Write-Host "Test 1: Get All Active Coupons" -ForegroundColor Yellow
Write-Host "GET $baseUrl/api/coupons" -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/coupons" -Method Get
    Write-Host "✅ Success! Found $($response.Count) coupons" -ForegroundColor Green
    $response | ForEach-Object {
        Write-Host "  - $($_.code): $($_.description)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Get Available Coupons for Order
Write-Host "Test 2: Get Available Coupons for Order Value ₹1500" -ForegroundColor Yellow
Write-Host "GET $baseUrl/api/coupons/available?orderValue=1500" -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/coupons/available?orderValue=1500" -Method Get
    Write-Host "✅ Success! Found $($response.Count) applicable coupons" -ForegroundColor Green
    $response | ForEach-Object {
        if ($_.isApplicable) {
            Write-Host "  ✓ $($_.code): Save ₹$($_.calculatedDiscount)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($_.code): $($_.notApplicableReason)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Validate Valid Coupon
Write-Host "Test 3: Validate Coupon SAVE50 for ₹1500 order" -ForegroundColor Yellow
Write-Host "POST $baseUrl/api/coupons/validate" -ForegroundColor Gray
try {
    $body = @{
        couponCode = "SAVE50"
        orderValue = 1500
        restaurantId = 1
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/api/coupons/validate" `
        -Method Post `
        -Body $body `
        -ContentType "application/json"
    
    if ($response.isValid) {
        Write-Host "✅ Valid! Discount: ₹$($response.discount)" -ForegroundColor Green
        Write-Host "   Message: $($response.message)" -ForegroundColor White
    } else {
        Write-Host "❌ Invalid: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Validate Coupon with Low Order Value
Write-Host "Test 4: Validate Coupon SAVE50 for ₹300 order (should fail)" -ForegroundColor Yellow
Write-Host "POST $baseUrl/api/coupons/validate" -ForegroundColor Gray
try {
    $body = @{
        couponCode = "SAVE50"
        orderValue = 300
        restaurantId = 1
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/api/coupons/validate" `
        -Method Post `
        -Body $body `
        -ContentType "application/json"
    
    if ($response.isValid) {
        Write-Host "❌ Should have failed but passed!" -ForegroundColor Red
    } else {
        Write-Host "✅ Correctly rejected: $($response.message)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: Validate Invalid Coupon Code
Write-Host "Test 5: Validate Invalid Coupon Code" -ForegroundColor Yellow
Write-Host "POST $baseUrl/api/coupons/validate" -ForegroundColor Gray
try {
    $body = @{
        couponCode = "INVALID123"
        orderValue = 1500
        restaurantId = 1
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/api/coupons/validate" `
        -Method Post `
        -Body $body `
        -ContentType "application/json"
    
    if ($response.isValid) {
        Write-Host "❌ Should have failed but passed!" -ForegroundColor Red
    } else {
        Write-Host "✅ Correctly rejected: $($response.message)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Test All Sample Coupons
Write-Host "Test 6: Testing All Sample Coupons" -ForegroundColor Yellow
$testCoupons = @("WELCOME200", "SAVE50", "FLAT100", "CASHBACK20", "MEGA30")
$testOrderValue = 1500

foreach ($coupon in $testCoupons) {
    try {
        $body = @{
            couponCode = $coupon
            orderValue = $testOrderValue
            restaurantId = 1
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "$baseUrl/api/coupons/validate" `
            -Method Post `
            -Body $body `
            -ContentType "application/json"
        
        if ($response.isValid) {
            Write-Host "  ✓ $coupon : ₹$($response.discount) discount" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $coupon : $($response.message)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ✗ $coupon : Error" -ForegroundColor Red
    }
}
Write-Host ""

# Summary
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🎉 Coupon System Test Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Test the frontend by navigating to /coupons" -ForegroundColor White
Write-Host "2. Add items to cart and try applying coupons" -ForegroundColor White
Write-Host "3. Check Redis cache: redis-cli KEYS 'coupon:*'" -ForegroundColor White
Write-Host "4. Monitor database: SELECT * FROM coupon_usage;" -ForegroundColor White
Write-Host ""
