# ===============================
# STOP KAFKA AND ZOOKEEPER
# ===============================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STOPPING KAFKA SERVICES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$KAFKA_HOME = "C:\kafka\kafka_2.13-3.6.1"

# Check if Kafka is installed
if (!(Test-Path $KAFKA_HOME)) {
    Write-Host "✗ Kafka not found at: $KAFKA_HOME" -ForegroundColor Red
    exit 1
}

Write-Host "[1/2] Stopping Kafka..." -ForegroundColor Yellow

# Stop Kafka
& "$KAFKA_HOME\bin\windows\kafka-server-stop.bat"
Start-Sleep -Seconds 5

Write-Host "✓ Kafka stopped" -ForegroundColor Green
Write-Host ""

Write-Host "[2/2] Stopping Zookeeper..." -ForegroundColor Yellow

# Stop Zookeeper
& "$KAFKA_HOME\bin\windows\zookeeper-server-stop.bat"
Start-Sleep -Seconds 3

Write-Host "✓ Zookeeper stopped" -ForegroundColor Green
Write-Host ""

# Kill any remaining Java processes related to Kafka/Zookeeper
Write-Host "Cleaning up any remaining processes..." -ForegroundColor Gray

Get-Process -Name java -ErrorAction SilentlyContinue | Where-Object { 
    $_.CommandLine -like "*kafka*" -or $_.CommandLine -like "*zookeeper*" 
} | Stop-Process -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  KAFKA SERVICES STOPPED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
