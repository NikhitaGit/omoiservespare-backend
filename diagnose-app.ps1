Write-Host "=== Application Diagnostics ===" -ForegroundColor Cyan

# Check if backend is running
Write-Host "`nChecking if Spring Boot backend is running on port 8080..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ Backend is running!" -ForegroundColor Green
    Write-Host "Response: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend is NOT running on port 8080" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Check if frontend is running
Write-Host "`nChecking if frontend is running on port 5173..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5173" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✓ Frontend is running!" -ForegroundColor Green
} catch {
    Write-Host "✗ Frontend is NOT running on port 5173" -ForegroundColor Red
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Start backend: mvn spring-boot:run" -ForegroundColor White
Write-Host "2. Check backend logs for errors" -ForegroundColor White
Write-Host "3. Verify database connection in application.properties" -ForegroundColor White
