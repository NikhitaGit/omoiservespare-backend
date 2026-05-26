# ===============================
# CREATE KAFKA TOPICS FOR COUPON SYSTEM
# ===============================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CREATING KAFKA TOPICS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$KAFKA_HOME = "C:\kafka\kafka_2.13-3.6.1"
$KAFKA_BIN = "$KAFKA_HOME\bin\windows"

# Check if Kafka is installed
if (!(Test-Path $KAFKA_HOME)) {
    Write-Host "✗ Kafka not found at: $KAFKA_HOME" -ForegroundColor Red
    Write-Host "Please run: .\install-kafka-windows.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Topics to create (from application.properties)
$topics = @(
    "coupon-viewed-events",
    "coupon-applied-events",
    "coupon-validated-events",
    "user-behavior-events"
)

Write-Host "Creating topics for Coupon System..." -ForegroundColor Yellow
Write-Host ""

foreach ($topic in $topics) {
    Write-Host "Creating topic: $topic" -ForegroundColor Cyan
    
    try {
        & "$KAFKA_BIN\kafka-topics.bat" --create `
            --bootstrap-server localhost:9092 `
            --replication-factor 1 `
            --partitions 3 `
            --topic $topic `
            --if-not-exists
        
        Write-Host "✓ Topic '$topic' created successfully" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Failed to create topic '$topic'" -ForegroundColor Yellow
        Write-Host "Error: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "  LISTING ALL TOPICS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

& "$KAFKA_BIN\kafka-topics.bat" --list --bootstrap-server localhost:9092

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  TOPICS CREATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Kafka setup is ready for the Coupon System!" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Run: .\test-kafka-connection.ps1 (to verify)" -ForegroundColor White
Write-Host "2. Start your Spring Boot application" -ForegroundColor White
Write-Host ""
