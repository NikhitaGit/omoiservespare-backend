# Safe Backend Start Script
# Automatically kills any process on port 8080 and starts the backend

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Safe Backend Start" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check for processes on port 8080
Write-Host "[1/3] Checking port 8080..." -ForegroundColor Yellow
$processes = netstat -ano | findstr :8080

if ($processes) {
    Write-Host "Port 8080 is in use" -ForegroundColor Red
    Write-Host ""
    
    # Extract and kill PIDs
    $pids = @()
    foreach ($line in $processes) {
        $parts = $line -split '\s+'
        $pid = $parts[-1]
        if ($pid -match '^\d+$' -and $pid -ne "0") {
            $pids += $pid
        }
    }
    
    $pids = $pids | Select-Object -Unique
    
    Write-Host "Killing processes: $($pids -join ', ')" -ForegroundColor Yellow
    foreach ($pid in $pids) {
        taskkill /F /PID $pid 2>$null | Out-Null
    }
    
    Write-Host "Processes killed" -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "Port 8080 is free" -ForegroundColor Green
}

Write-Host ""

# Step 2: Verify port is free
Write-Host "[2/3] Verifying port is free..." -ForegroundColor Yellow
$check = netstat -ano | findstr :8080

if ($check) {
    Write-Host "Port 8080 is still in use!" -ForegroundColor Red
    Write-Host "Please manually kill the process and try again." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "Port 8080 is ready" -ForegroundColor Green
}

Write-Host ""

# Step 3: Start backend
Write-Host "[3/3] Starting backend..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Backend will be available at: http://localhost:8080" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

.\mvnw spring-boot:run
