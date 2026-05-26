# 🚀 Start Application with Location System
# This script starts the Spring Boot application with location features

Write-Host "`n🚀 Starting Application with Location System..." -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Check if port 8080 is free
Write-Host "🔍 Checking port 8080..." -ForegroundColor Yellow
$portCheck = netstat -ano | findstr :8080 | findstr LISTENING

if ($portCheck) {
    Write-Host "❌ Port 8080 is still in use!" -ForegroundColor Red
    Write-Host "   Run: .\fix-port-8080.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Port 8080 is free" -ForegroundColor Green

# Check Google Maps API key
Write-Host "`n🗺️  Checking Google Maps API configuration..." -ForegroundColor Yellow

if ($env:GOOGLE_MAPS_API_KEY) {
    $keyPreview = $env:GOOGLE_MAPS_API_KEY.Substring(0, [Math]::Min(10, $env:GOOGLE_MAPS_API_KEY.Length))
    Write-Host "✅ Google Maps API key found: $keyPreview..." -ForegroundColor Green
} else {
    Write-Host "⚠️  Google Maps API key not set" -ForegroundColor Yellow
    Write-Host "   System will use fallback coordinates" -ForegroundColor Cyan
    Write-Host "   To set up: .\setup-google-maps-api.ps1" -ForegroundColor Cyan
}

# Start application
Write-Host "`n🚀 Starting Spring Boot application..." -ForegroundColor Cyan
Write-Host "   This may take 20-30 seconds...`n" -ForegroundColor Yellow

Write-Host "📋 What to look for in logs:" -ForegroundColor Yellow
Write-Host "   ✅ 'Successfully applied 1 migration to schema' (V14)" -ForegroundColor White
Write-Host "   ✅ 'Google Maps API configured' or 'WARNING: not configured'" -ForegroundColor White
Write-Host "   ✅ 'Started OmoiservespareApplication'" -ForegroundColor White
Write-Host "   ✅ 'Tomcat started on port 8080'" -ForegroundColor White

Write-Host "`n🔄 Starting now...`n" -ForegroundColor Cyan

# Start Maven
mvn spring-boot:run
