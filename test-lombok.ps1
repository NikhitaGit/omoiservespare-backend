# Test Lombok Installation
Write-Host "Testing Lombok..." -ForegroundColor Cyan
Write-Host ""

# Check Lombok JAR
$lombokJar = "$env:USERPROFILE\.m2\repository\org\projectlombok\lombok\1.18.30\lombok-1.18.30.jar"
if (Test-Path $lombokJar) {
    Write-Host "Lombok JAR found" -ForegroundColor Green
} else {
    Write-Host "Lombok JAR not found - downloading..." -ForegroundColor Yellow
    mvn dependency:get -Dartifact=org.projectlombok:lombok:1.18.30 2>&1 | Out-Null
}

Write-Host ""
Write-Host "Compiling project..." -ForegroundColor Cyan
mvn clean compile 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS! Lombok is working!" -ForegroundColor Green
    Write-Host "You can now run: mvn spring-boot:run" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "FAILED - IDE plugin required" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Lombok plugin in IntelliJ IDEA:" -ForegroundColor Yellow
    Write-Host "1. File -> Settings -> Plugins" -ForegroundColor White
    Write-Host "2. Search Lombok and install" -ForegroundColor White
    Write-Host "3. Restart IDE" -ForegroundColor White
    Write-Host "4. Enable annotation processing in Settings" -ForegroundColor White
    Write-Host ""
    Write-Host "Read LOMBOK_FIX_REQUIRED_ACTIONS.md for details" -ForegroundColor Cyan
}
