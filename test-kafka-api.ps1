# Test Kafka Connection via API

Write-Host "Testing Kafka Connection..." -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"

# Test 1: Check Kafka Status
Write-Host "[1/2] Checking Kafka configuration..." -ForegroundColor Yellow
try {
    $statusResponse = Invoke-RestMethod -Uri "$baseUrl/api/kafka/status" -Method Get
    Write-Host "Kafka Configuration:" -ForegroundColor Green
    Write-Host "  Bootstrap Servers: $($statusResponse.bootstrapServers)" -ForegroundColor White
    Write-Host "  Consumer Group: $($statusResponse.consumerGroup)" -ForegroundColor White
    Write-Host "  Topics:" -ForegroundColor White
    foreach ($topic in $statusResponse.topics) {
        Write-Host "    - $topic" -ForegroundColor Gray
    }
} catch {
    Write-Host "Failed to get Kafka status: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Send Test Event
Write-Host "[2/2] Sending test event to Kafka..." -ForegroundColor Yellow
try {
    $testResponse = Invoke-RestMethod -Uri "$baseUrl/api/kafka/test" -Method Get
    
    if ($testResponse.status -eq "success") {
        Write-Host "SUCCESS! Kafka is connected and working!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Test Event Details:" -ForegroundColor Cyan
        Write-Host "  User ID: $($testResponse.testEvent.userId)" -ForegroundColor White
        Write-Host "  Coupon Code: $($testResponse.testEvent.couponCode)" -ForegroundColor White
        Write-Host "  Order Amount: $($testResponse.testEvent.orderAmount)" -ForegroundColor White
        Write-Host "  Status: $($testResponse.testEvent.status)" -ForegroundColor White
        Write-Host ""
        Write-Host "Message: $($testResponse.message)" -ForegroundColor Green
    } else {
        Write-Host "FAILED! $($testResponse.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Failed to send test event: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "This might mean:" -ForegroundColor Yellow
    Write-Host "  1. Kafka is not running (run: .\start-kafka.ps1)" -ForegroundColor White
    Write-Host "  2. Application is not running (run: mvn spring-boot:run)" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  KAFKA CONNECTION VERIFIED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: Monitor Kafka topics to see events:" -ForegroundColor Yellow
Write-Host "  C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-viewed-events --from-beginning" -ForegroundColor Gray
Write-Host ""
