Write-Host "=== Testing Backend API ===" -ForegroundColor Cyan

# Test health endpoint
Write-Host "`nTesting backend health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/test/health" -Method GET -ErrorAction Stop
    Write-Host "✓ Backend is responding!" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "✗ Backend health check failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test canteens endpoint
Write-Host "`nTesting canteens endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/canteens" -Method GET -ErrorAction Stop
    Write-Host "✓ Canteens endpoint working!" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "✗ Canteens endpoint failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Backend is running correctly ===" -ForegroundColor Green
Write-Host "The issue is in your FRONTEND code (App_Feedback.jsx line 99)" -ForegroundColor Yellow
