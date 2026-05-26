# ===============================
# KAFKA INSTALLATION SCRIPT FOR WINDOWS
# ===============================
# This script downloads and sets up Apache Kafka on Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  KAFKA INSTALLATION FOR WINDOWS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$KAFKA_VERSION = "3.6.1"
$SCALA_VERSION = "2.13"
$KAFKA_FOLDER = "kafka_$SCALA_VERSION-$KAFKA_VERSION"
$KAFKA_DOWNLOAD_URL = "https://archive.apache.org/dist/kafka/$KAFKA_VERSION/$KAFKA_FOLDER.tgz"
$INSTALL_DIR = "C:\kafka"

Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow

# Check if Java is installed
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✓ Java is installed: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Java is NOT installed!" -ForegroundColor Red
    Write-Host "Please install Java 11 or higher from: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[2/6] Creating installation directory..." -ForegroundColor Yellow

# Create Kafka directory
if (!(Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Write-Host "✓ Created directory: $INSTALL_DIR" -ForegroundColor Green
} else {
    Write-Host "✓ Directory already exists: $INSTALL_DIR" -ForegroundColor Green
}

Write-Host ""
Write-Host "[3/6] Downloading Kafka..." -ForegroundColor Yellow
Write-Host "This may take a few minutes depending on your internet speed..." -ForegroundColor Gray

$downloadPath = "$env:TEMP\$KAFKA_FOLDER.tgz"

try {
    # Download Kafka
    Invoke-WebRequest -Uri $KAFKA_DOWNLOAD_URL -OutFile $downloadPath -UseBasicParsing
    Write-Host "✓ Downloaded Kafka $KAFKA_VERSION" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download Kafka!" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Download manually from:" -ForegroundColor Yellow
    Write-Host $KAFKA_DOWNLOAD_URL -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "[4/6] Extracting Kafka..." -ForegroundColor Yellow

try {
    # Extract using tar (available in Windows 10+)
    Set-Location $INSTALL_DIR
    tar -xzf $downloadPath -C $INSTALL_DIR
    Write-Host "✓ Extracted Kafka to $INSTALL_DIR" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to extract Kafka!" -ForegroundColor Red
    Write-Host "Please extract manually using 7-Zip or WinRAR" -ForegroundColor Yellow
    exit 1
}

# Clean up download
Remove-Item $downloadPath -Force

Write-Host ""
Write-Host "[5/6] Configuring Kafka..." -ForegroundColor Yellow

$kafkaHome = "$INSTALL_DIR\$KAFKA_FOLDER"

# Create data directories
$zookeeperDataDir = "$kafkaHome\data\zookeeper"
$kafkaLogsDir = "$kafkaHome\data\kafka-logs"

New-Item -ItemType Directory -Path $zookeeperDataDir -Force | Out-Null
New-Item -ItemType Directory -Path $kafkaLogsDir -Force | Out-Null

Write-Host "✓ Created data directories" -ForegroundColor Green

# Update Zookeeper config
$zookeeperConfig = "$kafkaHome\config\zookeeper.properties"
(Get-Content $zookeeperConfig) -replace 'dataDir=.*', "dataDir=$($zookeeperDataDir -replace '\\', '/')" | Set-Content $zookeeperConfig

# Update Kafka config
$kafkaConfig = "$kafkaHome\config\server.properties"
(Get-Content $kafkaConfig) -replace 'log.dirs=.*', "log.dirs=$($kafkaLogsDir -replace '\\', '/')" | Set-Content $kafkaConfig

Write-Host "✓ Updated configuration files" -ForegroundColor Green

Write-Host ""
Write-Host "[6/6] Setting up environment..." -ForegroundColor Yellow

# Create environment variable setup script
$envScript = @"
# Add to your PowerShell profile or run manually
`$env:KAFKA_HOME = "$kafkaHome"
`$env:PATH += ";`$env:KAFKA_HOME\bin\windows"
"@

$envScript | Out-File "$kafkaHome\set-kafka-env.ps1" -Encoding UTF8

Write-Host "✓ Created environment setup script" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  KAFKA INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Kafka Location: $kafkaHome" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Run: .\start-kafka.ps1 (to start Zookeeper and Kafka)" -ForegroundColor White
Write-Host "2. Run: .\create-kafka-topics.ps1 (to create required topics)" -ForegroundColor White
Write-Host "3. Start your Spring Boot application" -ForegroundColor White
Write-Host ""
Write-Host "To set environment variables permanently, run:" -ForegroundColor Yellow
Write-Host "  $kafkaHome\set-kafka-env.ps1" -ForegroundColor Cyan
Write-Host ""
