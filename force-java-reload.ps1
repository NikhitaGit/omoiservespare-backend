# Force Java Language Server to reload with Lombok
Write-Host "Forcing Java Language Server reload..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Close Kiro completely" -ForegroundColor Yellow
Write-Host "- Close all Kiro windows" -ForegroundColor White
Write-Host ""

Write-Host "Step 2: Delete Java workspace cache" -ForegroundColor Yellow
$workspaceCache = "$env:APPDATA\Code\User\workspaceStorage"
if (Test-Path $workspaceCache) {
    Write-Host "Found workspace cache at: $workspaceCache" -ForegroundColor Green
    Write-Host "You may want to delete this folder to force a clean start" -ForegroundColor White
} else {
    Write-Host "Workspace cache not found at expected location" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Step 3: Reopen Kiro" -ForegroundColor Yellow
Write-Host "- Open Kiro" -ForegroundColor White
Write-Host "- Open your project folder" -ForegroundColor White
Write-Host "- Wait for Java Language Server to start (check bottom right)" -ForegroundColor White
Write-Host ""

Write-Host "Step 4: Clean Java workspace" -ForegroundColor Yellow
Write-Host "- Press Ctrl+Shift+P" -ForegroundColor White
Write-Host "- Type: Java: Clean Java Language Server Workspace" -ForegroundColor White
Write-Host "- Select: Restart and delete" -ForegroundColor White
Write-Host ""

Write-Host "Step 5: Test compilation" -ForegroundColor Yellow
Write-Host "Run: mvn clean compile" -ForegroundColor Cyan
Write-Host ""

Write-Host "If still failing, check:" -ForegroundColor Yellow
Write-Host "1. Extension Pack for Java is installed (Ctrl+Shift+X)" -ForegroundColor White
Write-Host "2. Java Language Server is running (check bottom right status bar)" -ForegroundColor White
Write-Host "3. No error notifications in Kiro" -ForegroundColor White
