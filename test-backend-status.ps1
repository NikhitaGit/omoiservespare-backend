# Backend Status Check Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BACKEND STATUS CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Spring Boot is running
Write-Host "Checking Spring Boot (port 8080)..." -ForegroundColor Yellow
$springBoot = netstat -ano | Select-String "8080" | Select-String "LISTENING"
if ($springBoot) {
    Write-Host "  Spring Boot: RUNNING" -ForegroundColor Green
} else {
    Write-Host "  Spring Boot: NOT RUNNING" -ForegroundColor Red
}

# Check MongoDB
Write-Host "Checking MongoDB (port 27017)..." -ForegroundColor Yellow
$mongo = netstat -ano | Select-String "27017" | Select-String "LISTENING"
if ($mongo) {
    Write-Host "  MongoDB: RUNNING" -ForegroundColor Green
} else {
    Write-Host "  MongoDB: NOT RUNNING" -ForegroundColor Red
}

# Check PostgreSQL
Write-Host "Checking PostgreSQL (port 5432)..." -ForegroundColor Yellow
$postgres = netstat -ano | Select-String "5432" | Select-String "LISTENING"
if ($postgres) {
    Write-Host "  PostgreSQL: RUNNING" -ForegroundColor Green
} else {
    Write-Host "  PostgreSQL: NOT RUNNING" -ForegroundColor Red
}

# Check Kafka
Write-Host "Checking Kafka (port 9092)..." -ForegroundColor Yellow
$kafka = netstat -ano | Select-String "9092" | Select-String "LISTENING"
if ($kafka) {
    Write-Host "  Kafka: RUNNING" -ForegroundColor Green
} else {
    Write-Host "  Kafka: NOT RUNNING (Optional)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RECOMMENDATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $springBoot) {
    Write-Host "Start Spring Boot: mvn spring-boot:run" -ForegroundColor Yellow
}

if (-not $kafka) {
    Write-Host ""
    Write-Host "Kafka is optional. Your app will work without it." -ForegroundColor Gray
    Write-Host "To start Kafka: .\start-kafka-quick.ps1" -ForegroundColor Gray
    Write-Host "Or run without Kafka features for now." -ForegroundColor Gray
}

Write-Host ""
Write-Host "To create admin: .\create-first-admin.ps1" -ForegroundColor Cyan
