# ✅ Restart Backend - Simple Location Fix

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  LOCATION API FIX - RESTARTING BACKEND" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔧 What was fixed:" -ForegroundColor Yellow
Write-Host "   ✅ Made /api/location/** public in SecurityConfig" -ForegroundColor Green
Write-Host "   ✅ JwtAuthFilter still runs for location API" -ForegroundColor Green
Write-Host "   ✅ Token extracted if present → currentUser set" -ForegroundColor Green
Write-Host "   ✅ Removed complex LocationApiAuthFilter" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Starting backend..." -ForegroundColor Yellow
Write-Host ""

# Start backend
mvn clean spring-boot:run
