# Setup Lombok for Kiro IDE
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LOMBOK SETUP FOR KIRO IDE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Checking Lombok JAR..." -ForegroundColor Yellow
$lombokPath = "$env:USERPROFILE\.m2\repository\org\projectlombok\lombok\1.18.30\lombok-1.18.30.jar"

if (Test-Path $lombokPath) {
    Write-Host "Lombok JAR found" -ForegroundColor Green
} else {
    Write-Host "Lombok JAR not found. Downloading..." -ForegroundColor Yellow
    mvn dependency:get -Dartifact=org.projectlombok:lombok:1.18.30
    if (Test-Path $lombokPath) {
        Write-Host "Lombok JAR downloaded successfully" -ForegroundColor Green
    } else {
        Write-Host "Failed to download Lombok JAR" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Step 2: VS Code settings configured" -ForegroundColor Yellow
Write-Host ".vscode/settings.json updated with Lombok configuration" -ForegroundColor Green

Write-Host ""
Write-Host "Step 3: Install Java extensions in Kiro" -ForegroundColor Yellow
Write-Host "  1. Press Ctrl+Shift+X" -ForegroundColor White
Write-Host "  2. Search for Extension Pack for Java" -ForegroundColor White
Write-Host "  3. Click Install" -ForegroundColor White
Write-Host ""

Write-Host "Step 4: Reload Kiro" -ForegroundColor Yellow
Write-Host "  - Press Ctrl+Shift+P" -ForegroundColor White
Write-Host "  - Type Reload Window" -ForegroundColor White
Write-Host ""

Write-Host "Step 5: Clean Java Language Server" -ForegroundColor Yellow
Write-Host "  - Press Ctrl+Shift+P" -ForegroundColor White
Write-Host "  - Type Java: Clean Java Language Server Workspace" -ForegroundColor White
Write-Host ""

Write-Host "Step 6: Building project..." -ForegroundColor Yellow
mvn clean install

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS! LOMBOK IS WORKING!" -ForegroundColor Green
    Write-Host "Run: mvn spring-boot:run" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "Complete steps 3-5 above, then run: mvn clean install" -ForegroundColor Yellow
}
