Write-Host "Starting Application - Original Code Restored" -ForegroundColor Green

Write-Host "Stopping any running instances..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "Starting application..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "./mvnw spring-boot:run"

Write-Host "Application starting in new window" -ForegroundColor Green
Write-Host "Wait 30-60 seconds for startup" -ForegroundColor Cyan
