# Permanent Solution: Start Backend with Port Conflict Resolution
# This script automatically kills any process using port 8080 before starting

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Starting OmoiServesSpare Backend" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if port 8080 is in use
Write-Host "Checking port 8080..." -ForegroundColor Yellow
$portCheck = netstat -ano | findstr ":8080"

if ($portCheck) {
    Write-Host "Port 8080 is in use. Killing the process..." -ForegroundColor Yellow
    
    # Extract all PIDs and kill them
    $pids = $portCheck | ForEach-Object {
        if ($_ -match '\s+(\d+)\s*$') {
            $matches[1]
        }
    } | Select-Object -Unique
    
    foreach ($pid in $pids) {
        if ($pid) {
            Write-Host "Killing process with PID: $pid" -ForegroundColor Red
            try {
                taskkill /PID $pid /F 2>&1 | Out-Null
            } catch {
                Write-Host "Could not kill PID $pid (may already be stopped)" -ForegroundColor Yellow
            }
        }
    }
    
    # Wait for the port to be released
    Start-Sleep -Seconds 3
    Write-Host "Port 8080 is now free!" -ForegroundColor Green
} else {
    Write-Host "Port 8080 is available!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start the application
mvn spring-boot:run
