# Check if Java Extension is installed in Kiro
Write-Host "Checking Java Extension status in Kiro..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Please verify manually:" -ForegroundColor Yellow
Write-Host "1. Press Ctrl+Shift+X in Kiro" -ForegroundColor White
Write-Host "2. Search for 'Extension Pack for Java'" -ForegroundColor White
Write-Host "3. Check if it shows 'Installed'" -ForegroundColor White
Write-Host ""
Write-Host "If NOT installed:" -ForegroundColor Yellow
Write-Host "- Click Install" -ForegroundColor White
Write-Host "- Wait for installation to complete" -ForegroundColor White
Write-Host "- Press Ctrl+Shift+P and type 'Reload Window'" -ForegroundColor White
Write-Host ""
Write-Host "After installing and reloading:" -ForegroundColor Yellow
Write-Host "- Press Ctrl+Shift+P" -ForegroundColor White
Write-Host "- Type 'Java: Clean Java Language Server Workspace'" -ForegroundColor White
Write-Host "- Select 'Restart and delete'" -ForegroundColor White
Write-Host ""
Write-Host "Then run: mvn clean compile" -ForegroundColor Cyan
