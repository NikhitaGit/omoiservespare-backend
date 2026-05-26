# Kill process on port 8080
Write-Host "=== Killing Process on Port 8080 ===" -ForegroundColor Cyan
Write-Host ""

try {
    # Find process using port 8080
    $process = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -First 1
    
    if ($process) {
        Write-Host "Found process ID: $process" -ForegroundColor Yellow
        
        # Get process details
        $processInfo = Get-Process -Id $process -ErrorAction SilentlyContinue
        if ($processInfo) {
            Write-Host "Process Name: $($processInfo.ProcessName)" -ForegroundColor Yellow
            Write-Host "Killing process..." -ForegroundColor Red
            
            Stop-Process -Id $process -Force
            Start-Sleep -Seconds 2
            
            Write-Host "✅ Process killed successfully!" -ForegroundColor Green
        }
    } else {
        Write-Host "No process found on port 8080" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Now you can start the backend with: mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
