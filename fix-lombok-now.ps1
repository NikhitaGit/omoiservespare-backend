# PERMANENT LOMBOK COMPILATION FIX
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "LOMBOK COMPILATION FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean target
Write-Host "[1/5] Cleaning target directory..." -ForegroundColor Yellow
if (Test-Path "target") {
    Remove-Item -Path "target" -Recurse -Force
    Write-Host "Target cleaned" -ForegroundColor Green
}
Write-Host ""

# Step 2: Clean Lombok cache
Write-Host "[2/5] Cleaning Lombok cache..." -ForegroundColor Yellow
$lombokPath = "$env:USERPROFILE\.m2\repository\org\projectlombok"
if (Test-Path $lombokPath) {
    Remove-Item -Path $lombokPath -Recurse -Force
    Write-Host "Lombok cache cleaned" -ForegroundColor Green
}
Write-Host ""

# Step 3: Download Lombok
Write-Host "[3/5] Downloading Lombok..." -ForegroundColor Yellow
mvn dependency:get -Dartifact=org.projectlombok:lombok:1.18.30 2>&1 | Out-Null
Write-Host "Lombok downloaded" -ForegroundColor Green
Write-Host ""

# Step 4: Compile
Write-Host "[4/5] Compiling..." -ForegroundColor Yellow
mvn clean compile -U 2>&1 | Out-Null
$success = $LASTEXITCODE -eq 0

if ($success) {
    Write-Host "SUCCESS! Compilation successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run: mvn spring-boot:run" -ForegroundColor Cyan
}
else {
    Write-Host "COMPILATION FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "IDE PLUGIN REQUIRED" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "FOR INTELLIJ IDEA:" -ForegroundColor Cyan
    Write-Host "1. File -> Settings -> Plugins" -ForegroundColor White
    Write-Host "2. Search for Lombok" -ForegroundColor White
    Write-Host "3. Install and restart" -ForegroundColor White
    Write-Host "4. Enable annotation processing in Settings" -ForegroundColor White
    Write-Host ""
    Write-Host "OR run Lombok installer:" -ForegroundColor Cyan
    $jar = "$env:USERPROFILE\.m2\repository\org\projectlombok\lombok\1.18.30\lombok-1.18.30.jar"
    Write-Host "java -jar $jar" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Show versions
Write-Host "[5/5] System info:" -ForegroundColor Yellow
java -version 2>&1 | Select-Object -First 1
mvn -version | Select-Object -First 1
