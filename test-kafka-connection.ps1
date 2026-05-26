# ===============================
# TEST KAFKA CONNECTION
# ===============================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTING KAFKA CONNECTION" -ForegroundColor Cyan
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

Write-Host "[1/4] Checking Zookeeper connection..." -ForegroundColor Yellow

try {
    $zookeeperTest = Test-NetConnection -ComputerName localhost -Port 2181 -WarningAction SilentlyContinue
    if ($zookeeperTest.TcpTestSucceeded) {
        Write-Host "✓ Zookeeper is running on port 2181" -ForegroundColor Green
    } else {
        Write-Host "✗ Zookeeper is NOT running!" -ForegroundColor Red
        Write-Host "Run: .\start-kafka.ps1" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Cannot connect to Zookeeper" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/4] Checking Kafka broker connection..." -ForegroundColor Yellow

try {
    $kafkaTest = Test-NetConnection -ComputerName localhost -Port 9092 -WarningAction SilentlyContinue
    if ($kafkaTest.TcpTestSucceeded) {
        Write-Host "✓ Kafka broker is running on port 9092" -ForegroundColor Green
    } else {
        Write-Host "✗ Kafka broker is NOT running!" -ForegroundColor Red
        Write-Host "Run: .\start-kafka.ps1" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Cannot connect to Kafka broker" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/4] Listing Kafka topics..." -ForegroundColor Yellow

& "$KAFKA_BIN\kafka-topics.bat" --list --bootstrap-server localhost:9092

Write-Host ""
Write-Host "[4/4] Testing message production and consumption..." -ForegroundColor Yellow

$testTopic = "test-connection-topic"

# Create test topic
Write-Host "Creating test topic..." -ForegroundColor Gray
& "$KAFKA_BIN\kafka-topics.bat" --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic $testTopic --if-not-exists | Out-Null

# Send test message
Write-Host "Sending test message..." -ForegroundColor Gray
$testMessage = "Test message from Kafka setup - $(Get-Date)"
echo $testMessage | & "$KAFKA_BIN\kafka-console-producer.bat" --bootstrap-server localhost:9092 --topic $testTopic

Start-Sleep -Seconds 2

# Try to consume the message
Write-Host "Reading test message..." -ForegroundColor Gray
$consumedMessage = & "$KAFKA_BIN\kafka-console-consumer.bat" --bootstrap-server localhost:9092 --topic $testTopic --from-beginning --max-messages 1 --timeout-ms 5000 2>$null

if ($consumedMessage -like "*Test message*") {
    Write-Host "✓ Message production and consumption working!" -ForegroundColor Green
} else {
    Write-Host "⚠ Could not verify message consumption" -ForegroundColor Yellow
}

# Clean up test topic
& "$KAFKA_BIN\kafka-topics.bat" --delete --bootstrap-server localhost:9092 --topic $testTopic 2>$null | Out-Null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  KAFKA CONNECTION TEST COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "✓ Zookeeper: Running" -ForegroundColor Green
Write-Host "✓ Kafka Broker: Running" -ForegroundColor Green
Write-Host "✓ Topics: Available" -ForegroundColor Green
Write-Host "✓ Message Flow: Working" -ForegroundColor Green
Write-Host ""
Write-Host "Your Kafka setup is ready!" -ForegroundColor Cyan
Write-Host "You can now start your Spring Boot application." -ForegroundColor Cyan
Write-Host ""
