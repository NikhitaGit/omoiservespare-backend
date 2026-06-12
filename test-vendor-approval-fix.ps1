# Test Vendor Approval Fix - WebSocket Serialization Issue

Write-Host "🧪 Testing Vendor Approval Fix..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Approve cancellation
Write-Host "📝 Test 1: Approving Cancellation..." -ForegroundColor Yellow
$approveBody = @{
    canteenOrderId = 3
    action = "APPROVE"
    remarks = "Cancellation accepted by vendor"
    vendorId = 1
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Gray
Write-Host $approveBody -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/refunds/vendor-approval" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer YOUR_VENDOR_TOKEN_HERE"
        } `
        -Body $approveBody

    Write-Host "✅ Approval Successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
    Write-Host ""
}
catch {
    Write-Host "❌ Approval Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Test 2: Reject cancellation
Write-Host "📝 Test 2: Rejecting Cancellation..." -ForegroundColor Yellow
$rejectBody = @{
    canteenOrderId = 4
    action = "REJECT"
    remarks = "Order already being prepared"
    vendorId = 1
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Gray
Write-Host $rejectBody -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/refunds/vendor-approval" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer YOUR_VENDOR_TOKEN_HERE"
        } `
        -Body $rejectBody

    Write-Host "✅ Rejection Successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
    Write-Host ""
}
catch {
    Write-Host "❌ Rejection Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Fix Summary:" -ForegroundColor Cyan
Write-Host "✅ Changed OrderEventPublisher to send CanteenOrderWebSocketDTO instead of Order entity" -ForegroundColor Green
Write-Host "✅ Added toWebSocketDTO() method to convert CanteenOrder to serializable DTO" -ForegroundColor Green
Write-Host "✅ Prevents Hibernate lazy-loading serialization errors" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Get a valid vendor JWT token from /api/auth/login" -ForegroundColor White
Write-Host "2. Replace 'YOUR_VENDOR_TOKEN_HERE' with actual token" -ForegroundColor White
Write-Host "3. Run this script to test vendor approval/rejection" -ForegroundColor White
Write-Host "4. Check browser console - WebSocket messages should work without errors" -ForegroundColor White
Write-Host ""
