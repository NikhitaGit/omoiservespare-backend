# Test Render Backend
# Replace YOUR_SERVICE_NAME with your actual Render service name

$BACKEND_URL = "https://YOUR_SERVICE_NAME.onrender.com"

Write-Host "Testing Backend: $BACKEND_URL" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Testing Health Endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BACKEND_URL/actuator/health" -Method Get
    Write-Host "✓ Health Check: " -ForegroundColor Green -NoNewline
    Write-Host ($response | ConvertTo-Json)
} catch {
    Write-Host "✗ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing API Base..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BACKEND_URL/api" -Method Get -ErrorAction SilentlyContinue
    Write-Host "✓ API accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✓ API endpoint responding (404 expected)" -ForegroundColor Green
    } else {
        Write-Host "✗ API Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Your backend URLs:" -ForegroundColor Cyan
Write-Host "  Base: $BACKEND_URL" -ForegroundColor White
Write-Host "  Health: $BACKEND_URL/actuator/health" -ForegroundColor White
Write-Host "  Auth: $BACKEND_URL/api/auth/*" -ForegroundColor White
Write-Host "  Cart: $BACKEND_URL/api/cart" -ForegroundColor White
Write-Host ""
