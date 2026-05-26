# Check Kafka Status

Write-Host "Checking Kafka Status..." -ForegroundColor Cyan
Write-Host ""

# Check Zookeeper
Write-Host "[1/2] Checking Zookeeper (port 2181)..." -ForegroundColor Yellow
$zookeeperTest = Test-NetConnection -ComputerName localhost -Port 2181 -WarningAction SilentlyContinue -InformationLevel Quiet

if ($zookeeperTest) {
    Write-Host "Zookeeper is RUNNING" -ForegroundColor Green
} else {
    Write-Host "Zookeeper is NOT running" -ForegroundColor Red
}

Write-Host ""

# Check Kafka
Write-Host "[2/2] Checking Kafka Broker (port 9092)..." -ForegroundColor Yellow
$kafkaTest = Test-NetConnection -ComputerName localhost -Port 9092 -WarningAction SilentlyContinue -InformationLevel Quiet

if ($kafkaTest) {
    Write-Host "Kafka Broker is RUNNING" -ForegroundColor Green
} else {
    Write-Host "Kafka Broker is NOT running" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($zookeeperTest -and $kafkaTest) {
    Write-Host "Kafka is ready!" -ForegroundColor Green
    Write-Host "You can start your Spring Boot application." -ForegroundColor White
} else {
    Write-Host "Kafka is NOT running!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To start Kafka, run: .\start-kafka.ps1" -ForegroundColor White
}

Write-Host ""
