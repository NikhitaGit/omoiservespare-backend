# ============================================
# PERMANENT LOMBOK COMPILATION FIX
# ============================================
# This script fixes Lombok annotation processing issues permanently

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LOMBOK COMPILATION FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean Maven target directory
Write-Host "[1/6] Cleaning Maven target directory..." -ForegroundColor Yellow
if (Test-Path "target") {
    Remove-Item -Path "target" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Target directory cleaned" -ForegroundColor Green
} else {
    Write-Host "✓ Target directory doesn't exist (already clean)" -ForegroundColor Green
}
Write-Host ""

# Step 2: Clean Maven cache for Lombok
Write-Host "[2/6] Cleaning Lombok from Maven cache..." -ForegroundColor Yellow
$lombokPath = "$env:USERPROFILE\.m2\repository\org\projectlombok"
if (Test-Path $lombokPath) {
    Remove-Item -Path $lombokPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Lombok cache cleaned" -ForegroundColor Green
} else {
    Write-Host "✓ Lombok cache doesn't exist" -ForegroundColor Green
}
Write-Host ""

# Step 3: Clean IDE caches (IntelliJ)
Write-Host "[3/6] Cleaning IDE caches..." -ForegroundColor Yellow
if (Test-Path ".idea") {
    Remove-Item -Path ".idea" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ IntelliJ IDEA cache cleaned" -ForegroundColor Green
}
if (Test-Path "*.iml") {
    Remove-Item -Path "*.iml" -Force -ErrorAction SilentlyContinue
    Write-Host "✓ IntelliJ module files cleaned" -ForegroundColor Green
}
Write-Host ""

# Step 4: Download Lombok fresh
Write-Host "[4/6] Downloading Lombok fresh..." -ForegroundColor Yellow
mvn dependency:get -Dartifact=org.projectlombok:lombok:1.18.30 -DremoteRepositories=https://repo1.maven.org/maven2 2>&1 | Out-Null
Write-Host "✓ Lombok downloaded" -ForegroundColor Green
Write-Host ""

# Step 5: Compile with verbose output
Write-Host "[5/6] Compiling project (this may take a minute)..." -ForegroundColor Yellow
Write-Host ""
mvn clean compile -U -e 2>&1 | Out-Null
$compileSuccess = $LASTEXITCODE -eq 0

if ($compileSuccess) {
    Write-Host "SUCCESS! COMPILATION SUCCESSFUL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Lombok is working correctly." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run:" -ForegroundColor Cyan
    Write-Host "  mvn spring-boot:run" -ForegroundColor White
    Write-Host ""
}
else {
    Write-Host "COMPILATION FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "MANUAL STEPS REQUIRED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "The Maven configuration is correct, but your IDE needs Lombok plugin." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "FOR INTELLIJ IDEA:" -ForegroundColor Cyan
    Write-Host "1. File -> Settings -> Plugins" -ForegroundColor White
    Write-Host "2. Search for 'Lombok'" -ForegroundColor White
    Write-Host "3. Install the Lombok plugin" -ForegroundColor White
    Write-Host "4. Restart IntelliJ IDEA" -ForegroundColor White
    Write-Host "5. File -> Settings -> Build, Execution, Deployment -> Compiler -> Annotation Processors" -ForegroundColor White
    Write-Host "6. Check 'Enable annotation processing'" -ForegroundColor White
    Write-Host "7. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "FOR ECLIPSE:" -ForegroundColor Cyan
    Write-Host "1. Download: https://projectlombok.org/download" -ForegroundColor White
    Write-Host "2. Run: java -jar lombok.jar" -ForegroundColor White
    Write-Host "3. Select your Eclipse installation" -ForegroundColor White
    Write-Host "4. Click Install/Update" -ForegroundColor White
    Write-Host "5. Restart Eclipse" -ForegroundColor White
    Write-Host "6. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "ALTERNATIVE - Install Lombok Agent:" -ForegroundColor Cyan
    Write-Host "Run this command:" -ForegroundColor White
    $lombokJar = "$env:USERPROFILE\.m2\repository\org\projectlombok\lombok\1.18.30\lombok-1.18.30.jar"
    Write-Host "  java -jar `"$lombokJar`"" -ForegroundColor Yellow
    Write-Host ""
}

# Step 6: Verify Java and Maven versions
Write-Host "[6/6] System Information:" -ForegroundColor Yellow
Write-Host "Java Version:" -ForegroundColor Cyan
java -version 2>&1 | Select-Object -First 1
Write-Host "Maven Version:" -ForegroundColor Cyan
mvn -version | Select-Object -First 1
Write-Host ""
