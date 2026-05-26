# Restart Backend with Vendor Login Fix

Write-Host "🔄 Restarting Backend..." -ForegroundColor Cyan
Write-Host "This will compile the new PasswordHashController and SecurityConfig changes" -ForegroundColor Yellow

Write-Host "`nPress Ctrl+C in the backend terminal to stop it, then run:" -ForegroundColor White
Write-Host "mvn spring-boot:run" -ForegroundColor Green

Write-Host "`nAfter the backend starts, run these tests:" -ForegroundColor Cyan
Write-Host "1. ./test-password-encoder.ps1" -ForegroundColor White
Write-Host "2. ./test-vendor-login.ps1" -ForegroundColor White
Write-Host "3. Test in browser at http://localhost:5174/login" -ForegroundColor White

Write-Host "`nTest Credentials:" -ForegroundColor Yellow
Write-Host "Email: vendor@restaurant.com" -ForegroundColor White
Write-Host "Password: vendor123" -ForegroundColor White
