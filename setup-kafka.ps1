# Kafka Setup Script for Windows
# This script helps you download and start Kafka on Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kafka Setup for Coupon Tracking System" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$kafkaVersion = "3.6.1"
$scalaVersion = "2.13"
$kafkaDir = "kafka_$scalaVersion-$kafkaVersion"
$kafkaZip = "$kafkaDir.tgz"
$downloadUrl = "https://downloads.apache.org/kafka/$kafkaVersion/$kafkaZip"

# Check if Kafka is already downloaded
if (Test-Path $kafkaDir) {
    Write-Host "Kafka is already downloaded at: $kafkaDir" -ForegroundColor Green
} else {
    Write-Host "Kafka not found. Please download Kafka manually:" -ForegroundColor Yellow
    Write-Host "1. Visit: https://kafka.apache.org/downloads" -ForegroundColor Yellow
    Write-Host "2. Download: kafka_$scalaVersion-$kafkaVersion.tgz" -ForegroundColor Yellow
    Write-Host "3. Extract it to this directory" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or download directly from:" -ForegroundColor Yellow
    Write-Host $downloadUrl -ForegroundColor Cyan
    Write-Host ""
    
    $response = Read-Host "Have you downloaded and extracted Kafka? (y/n)"
    if ($response -ne "y") {
        Write-Host "Please download Kafka first and run this script again." -ForegroundColor Red
        exit
    }
}

Write-Host ""
Write-Host "Starting Kafka services..." -ForegroundColor Cyan
Write-Host ""

# Check if Kafka directory exists
if (-not (Test-Path $kafkaDir)) {
    Write-Host "Error: Kafka directory not found: $kafkaDir" -ForegroundColor Red
    Write-Host "Please ensure Kafka is extracted in the current directory." -ForegroundColor Red
    exit
}

Write-Host "Step 1: Starting Zookeeper..." -ForegroundColor Yellow
Write-Host "Command: .\$kafkaDir\bin\windows\zookeeper-server-start.bat .\$kafkaDir\config\zookeeper.properties" -ForegroundColor Gray
Write-Host ""
Write-Host "Open a NEW PowerShell window and run:" -ForegroundColor Green
Write-Host "cd $PWD" -ForegroundColor Cyan
Write-Host ".\$kafkaDir\bin\windows\zookeeper-server-start.bat .\$kafkaDir\config\zookeeper.properties" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter after starting Zookeeper in a new window"

Write-Host ""
Write-Host "Step 2: Starting Kafka Broker..." -ForegroundColor Yellow
Write-Host "Command: .\$kafkaDir\bin\windows\kafka-server-start.bat .\$kafkaDir\config\server.properties" -ForegroundColor Gray
Write-Host ""
Write-Host "Open ANOTHER NEW PowerShell window and run:" -ForegroundColor Green
Write-Host "cd $PWD" -ForegroundColor Cyan
Write-Host ".\$kafkaDir\bin\windows\kafka-server-start.bat .\$kafkaDir\config\server.properties" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter after starting Kafka Broker in a new window"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Kafka Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Kafka is now running on localhost:9092" -ForegroundColor Green
Write-Host ""
Write-Host "Topics will be created automatically when the application starts:" -ForegroundColor Cyan
Write-Host "  - coupon-viewed-events" -ForegroundColor White
Write-Host "  - coupon-applied-events" -ForegroundColor White
Write-Host "  - coupon-validated-events" -ForegroundColor White
Write-Host "  - user-behavior-events" -ForegroundColor White
Write-Host ""
Write-Host "You can now start your Spring Boot application!" -ForegroundColor Green
Write-Host ""
