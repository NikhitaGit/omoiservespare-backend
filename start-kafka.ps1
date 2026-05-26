# ===============================
# START KAFKA AND ZOOKEEPER
# ===============================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STARTING KAFKA SERVICES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$KAFKA_HOME = "C:\kafka\kafka_2.13-3.6.1"

# Check if Kafka is installed
if (!(Test-Path $KAFKA_HOME)) {
    Write-Host "✗ Kafka not found at: $KAFKA_HOME" -ForegroundColor Red
    Write-Host "Please run: .\install-kafka-windows.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "Kafka Home: $KAFKA_HOME" -ForegroundColor Cyan
Write-Host ""

# Check if Zookeeper is already running
$zookeeperRunning = Get-Process -Name java -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*zookeeper*" }
$kafkaRunning = Get-Process -Name java -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*kafka*" }

if ($zookeeperRunning) {
    Write-Host "⚠ Zookeeper is already running" -ForegroundColor Yellow
} else {
    Write-Host "[1/2] Starting Zookeeper..." -ForegroundColor Yellow
    
    # Start Zookeeper in a new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$KAFKA_HOME'; .\bin\windows\zookeeper-server-start.bat .\config\zookeeper.properties"
    
    Write-Host "✓ Zookeeper starting in new window..." -ForegroundColor Green
    Write-Host "Waiting 10 seconds for Zookeeper to initialize..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
}

Write-Host ""

if ($kafkaRunning) {
    Write-Host "⚠ Kafka is already running" -ForegroundColor Yellow
} else {
    Write-Host "[2/2] Starting Kafka..." -ForegroundColor Yellow
    
    # Start Kafka in a new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$KAFKA_HOME'; .\bin\windows\kafka-server-start.bat .\config\server.properties"
    
    Write-Host "✓ Kafka starting in new window..." -ForegroundColor Green
    Write-Host "Waiting 15 seconds for Kafka to initialize..." -ForegroundColor Gray
    Start-Sleep -Seconds 15
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  KAFKA SERVICES STARTED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Zookeeper: localhost:2181" -ForegroundColor Cyan
Write-Host "Kafka Broker: localhost:9092" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Run: .\create-kafka-topics.ps1 (to create topics)" -ForegroundColor White
Write-Host "2. Run: .\test-kafka-connection.ps1 (to verify setup)" -ForegroundColor White
Write-Host ""
Write-Host "To stop Kafka services, close the PowerShell windows or run:" -ForegroundColor Gray
Write-Host "  .\stop-kafka.ps1" -ForegroundColor Cyan
Write-Host ""
