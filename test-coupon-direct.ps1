# Test Coupon Validation Directly
Write-Host "=== Testing Coupon Validation API ===" -ForegroundColor Cyan
Write-Host ""

# Get your token from localStorage (you'll need to paste it)
$token = Read-Host "Paste your token from browser localStorage"

Write-Host ""
Write-Host "Testing coupon validation..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    couponCode = "WELCOME200"
    orderValue = 1000
    restaurantId = 1
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/coupons/validate" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -TimeoutSec 5
    
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ FAILED!" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
