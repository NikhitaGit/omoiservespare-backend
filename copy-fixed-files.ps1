# Copy fixed files to your React project

Write-Host "📋 Copying Fixed Files" -ForegroundColor Cyan
Write-Host "=====================`n" -ForegroundColor Cyan

# Get the React project path from user
$reactPath = Read-Host "Enter your React project path (e.g., C:\path\to\my-react-app)"

if (-not (Test-Path $reactPath)) {
    Write-Host "❌ Path does not exist: $reactPath" -ForegroundColor Red
    exit 1
}

$apiPath = Join-Path $reactPath "src\api"

if (-not (Test-Path $apiPath)) {
    Write-Host "Creating api folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $apiPath -Force | Out-Null
}

# Copy authApi.js
Write-Host "Copying authApi.js..." -ForegroundColor Yellow
Copy-Item "frontend-integration\authApi.js" -Destination (Join-Path $apiPath "authApi.js") -Force

Write-Host "✅ Files copied successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Restart your React dev server" -ForegroundColor White
Write-Host "2. Clear browser cache (Ctrl+Shift+R)" -ForegroundColor White
Write-Host "3. Test login at http://localhost:5173/login" -ForegroundColor White
Write-Host "4. Check backend logs for OTP" -ForegroundColor White
