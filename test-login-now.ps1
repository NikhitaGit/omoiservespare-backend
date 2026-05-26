# Test Login API
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING LOGIN API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test data
$loginData = @{
    email = "admin@example.com"
    password = "admin123"
} | ConvertTo-Json

Write-Host "Testing POST /api/auth/login..." -ForegroundColor Yellow
Write-Host "Email: admin@example.com" -ForegroundColor White
Write-Host "Password: admin123" -ForegroundColor White
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginData `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "SUCCESS - LOGIN WORKS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
    Write-Host ""
    Write-Host "JWT Token:" -ForegroundColor Yellow
    Write-Host $response.token -ForegroundColor White
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "LOGIN FAILED" -ForegroundColor Red
    Write-Host "Status Code: $statusCode" -ForegroundColor Red
    Write-Host ""
    
    if ($statusCode -eq 401) {
        Write-Host "Reason: Invalid credentials" -ForegroundColor Yellow
        Write-Host "The user does not exist or password is wrong" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Try creating a user first or use correct credentials" -ForegroundColor White
    } elseif ($statusCode -eq 500) {
        Write-Host "Reason: Server error" -ForegroundColor Yellow
        Write-Host "Check backend logs for details" -ForegroundColor Yellow
    } else {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend is running on port 8080" -ForegroundColor Green
Write-Host "Your frontend can now connect" -ForegroundColor Green
Write-Host "System uses PASSWORD authentication" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
