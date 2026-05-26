# Simple script to kill port 8080 and start backend
Write-Host "Killing process on port 8080..." -ForegroundColor Yellow

# Find and kill the process using port 8080
$processInfo = netstat -ano | findstr :8080
if ($processInfo) {
    $processInfo -split "`n" | ForEach-Object {
        if ($_ -match '\s+(\d+)$') {
            $pid = $matches[1]
            Write-Host "Found process $pid on port 8080, killing it..." -ForegroundColor Yellow
            taskkill /F /PID $pid 2>$null
        }
    }
    Start-Sleep -Seconds 2
}

Write-Host "Starting backend..." -ForegroundColor Green
.\mvnw spring-boot:run
