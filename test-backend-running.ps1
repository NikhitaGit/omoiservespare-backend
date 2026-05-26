# Test if backend is running on port 8080
Write-Host "Testing if backend is running on port 8080..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Backend is RUNNING!" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "❌ Backend is NOT running or not responding" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Check if port is in use
    $port = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($port) {
        Write-Host "⚠️  Port 8080 is in use by process ID: $($port.OwningProcess)" -ForegroundColor Yellow
    } else {
        Write-Host "Port 8080 is not in use - backend may still be starting" -ForegroundColor Yellow
    }
}
