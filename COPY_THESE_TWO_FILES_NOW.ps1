# 🔧 LOCATION FIX - COPY FILES SCRIPT
# Run this from your project root directory

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  LOCATION API PERMANENT FIX - FILE COPIER" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "frontend-integration")) {
    Write-Host "❌ ERROR: frontend-integration folder not found!" -ForegroundColor Red
    Write-Host "   Please run this script from your project root directory" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "omoi-app")) {
    Write-Host "❌ ERROR: omoi-app folder not found!" -ForegroundColor Red
    Write-Host "   Please run this script from your project root directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Directories found. Starting file copy..." -ForegroundColor Green
Write-Host ""

# Copy axiosInstance
Write-Host "📦 Copying axiosInstance.js..." -ForegroundColor Yellow
try {
    Copy-Item "frontend-integration/axiosInstance_PERMANENT_LOCATION_FIX.js" `
              "omoi-app/src/api/axiosInstance.js" -Force
    Write-Host "   ✅ axiosInstance.js copied successfully!" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to copy axiosInstance.js: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Copy LocationPicker
Write-Host "📦 Copying LocationPicker.jsx..." -ForegroundColor Yellow
try {
    Copy-Item "frontend-integration/LocationPicker_AUTH_FIXED.jsx" `
              "omoi-app/src/pages/LocationPicker.jsx" -Force
    Write-Host "   ✅ LocationPicker.jsx copied successfully!" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to copy LocationPicker.jsx: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ✅ ALL FILES COPIED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Restart your React dev server:" -ForegroundColor White
Write-Host "   cd omoi-app" -ForegroundColor Gray
Write-Host "   npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Clear browser cache:" -ForegroundColor White
Write-Host "   - Open DevTools (F12)" -ForegroundColor Gray
Write-Host "   - Go to Application tab" -ForegroundColor Gray
Write-Host "   - Click 'Clear site data'" -ForegroundColor Gray
Write-Host "   - Refresh page" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Test the location picker:" -ForegroundColor White
Write-Host "   - Login with valid credentials" -ForegroundColor Gray
Write-Host "   - Navigate to location picker" -ForegroundColor Gray
Write-Host "   - Click 'Use current location'" -ForegroundColor Gray
Write-Host "   - Verify no redirect to login" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  🎉 LOCATION FIX READY TO TEST!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
