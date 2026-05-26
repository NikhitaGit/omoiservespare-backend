#!/usr/bin/env pwsh

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🚀 STARTING APPLICATION WITH HR INTEGRATION" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Check if Java is installed
Write-Host "🔍 Checking Java installation..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java found: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java not found! Please install Java 17 or higher." -ForegroundColor Red
    exit 1
}

# Check if Maven is installed
Write-Host "🔍 Checking Maven installation..." -ForegroundColor Yellow
try {
    $mavenVersion = mvn -version 2>&1 | Select-String "Apache Maven"
    Write-Host "✅ Maven found: $mavenVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Maven not found! Please install Maven." -ForegroundColor Red
    exit 1
}

# Check PostgreSQL connection
Write-Host "🔍 Checking PostgreSQL connection..." -ForegroundColor Yellow
try {
    $pgResult = psql -U postgres -d omoiservespare_db -c "SELECT 1;" 2>&1
    if ($pgResult -match "1") {
        Write-Host "✅ PostgreSQL connection successful!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ PostgreSQL connection issue, but continuing..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Could not test PostgreSQL connection, but continuing..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 HR Integration Configuration:" -ForegroundColor Yellow
Write-Host "  • HR API Enabled: false (mock mode for testing)"
Write-Host "  • Mock Companies: Omoikane Innovations, Tech Corp"
Write-Host "  • Mock Email Domains: @omoikaneinnovations.com, @techcorp.com, @example.com"
Write-Host "  • Mock Phone Patterns: +91-*, 91*, 9*"
Write-Host ""

# Clean and compile
Write-Host "🧹 Cleaning and compiling application..." -ForegroundColor Yellow
mvn clean compile

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Compilation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Compilation successful!" -ForegroundColor Green
Write-Host ""

# Start the application
Write-Host "🚀 Starting Spring Boot application..." -ForegroundColor Green
Write-Host "   Application will be available at: http://localhost:8080" -ForegroundColor White
Write-Host "   Press Ctrl+C to stop the application" -ForegroundColor White
Write-Host ""

Write-Host "📝 Test Credentials (Mock Mode):" -ForegroundColor Cyan
Write-Host "   Company: Omoikane Innovations" -ForegroundColor White
Write-Host "   Email: john.doe@omoikaneinnovations.com" -ForegroundColor White
Write-Host "   Phone: +91-9876543210" -ForegroundColor White
Write-Host ""

Write-Host "🧪 To test HR integration after startup:" -ForegroundColor Cyan
Write-Host "   Run: .\test-hr-integration.ps1" -ForegroundColor White
Write-Host ""

# Start the application
mvn spring-boot:run