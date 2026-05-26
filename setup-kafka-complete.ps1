# KAFKA COMPLETE SETUP
# This script runs all setup steps automatically

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  KAFKA COMPLETE SETUP FOR WINDOWS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Install Kafka
Write-Host "[STEP 1/4] Installing Kafka" -ForegroundColor Yellow
Write-Host ""

$kafkaInstalled = Test-Path "C:\kafka\kafka_2.13-3.6.1"
if ($kafkaInstalled) {
    Write-Host "Kafka is already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Kafka..." -ForegroundColor Gray
    & .\install-kafka-windows.ps1
}

Write-Host ""
Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host

# Step 2: Start Kafka Services
Write-Host ""
Write-Host "[STEP 2/4] Starting Kafka Services" -ForegroundColor Yellow
Write-Host ""

& .\start-kafka.ps1

Write-Host ""
Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host

# Step 3: Create Topics
Write-Host ""
Write-Host "[STEP 3/4] Creating Kafka Topics" -ForegroundColor Yellow
Write-Host ""

& .\create-kafka-topics.ps1

Write-Host ""
Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host

# Step 4: Test Connection
Write-Host ""
Write-Host "[STEP 4/4] Testing Kafka Connection" -ForegroundColor Yellow
Write-Host ""

& .\test-kafka-connection.ps1

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  KAFKA SETUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services Running:" -ForegroundColor Cyan
Write-Host "  - Zookeeper: localhost:2181" -ForegroundColor White
Write-Host "  - Kafka Broker: localhost:9092" -ForegroundColor White
Write-Host ""
Write-Host "Topics Created:" -ForegroundColor Cyan
Write-Host "  - coupon-viewed-events" -ForegroundColor White
Write-Host "  - coupon-applied-events" -ForegroundColor White
Write-Host "  - coupon-validated-events" -ForegroundColor White
Write-Host "  - user-behavior-events" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Start your Spring Boot application:" -ForegroundColor White
Write-Host "     .\mvnw.cmd spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Or use your existing start script:" -ForegroundColor White
Write-Host "     .\start-backend.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "  - Stop Kafka: .\stop-kafka.ps1" -ForegroundColor White
Write-Host "  - Restart Kafka: .\start-kafka.ps1" -ForegroundColor White
Write-Host "  - Test connection: .\test-kafka-connection.ps1" -ForegroundColor White
Write-Host ""
