# Quick Kafka Startup Script
# Make sure you have Kafka installed first

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "KAFKA QUICK START" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Kafka directory exists
$kafkaPath = "C:\kafka"
if (-not (Test-Path $kafkaPath)) {
    Write-Host "ERROR: Kafka not found at $kafkaPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Kafka first:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://kafka.apache.org/downloads" -ForegroundColor Gray
    Write-Host "2. Extract to C:\kafka" -ForegroundColor Gray
    Write-Host "3. Run this script again" -ForegroundColor Gray
    exit 1
}

Write-Host "Starting Zookeeper..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $kafkaPath; .\bin\windows\zookeeper-server-start.bat .\config\zookeeper.properties"

Write-Host "Waiting 10 seconds for Zookeeper to start..." -ForegroundColor Gray
Start-Sleep -Seconds 10

Write-Host "Starting Kafka..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $kafkaPath; .\bin\windows\kafka-server-start.bat .\config\server.properties"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Kafka is starting!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Two new windows opened:" -ForegroundColor White
Write-Host "1. Zookeeper (port 2181)" -ForegroundColor Gray
Write-Host "2. Kafka (port 9092)" -ForegroundColor Gray
Write-Host ""
Write-Host "Wait 30 seconds, then restart your Spring Boot app" -ForegroundColor Yellow
