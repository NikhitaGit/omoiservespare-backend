# Test Spring Boot with Kafka

Write-Host "Testing Spring Boot Application with Kafka..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting application (this may take 30-40 seconds)..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the application once you see it's running." -ForegroundColor Gray
Write-Host ""

# Start the application
mvn spring-boot:run
