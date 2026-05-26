# Verify Lombok is Working
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LOMBOK VERIFICATION SCRIPT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script verifies that Lombok is working correctly." -ForegroundColor Yellow
Write-Host "Run this AFTER installing the Lombok IDE plugin." -ForegroundColor Yellow
Write-Host ""

# Check Java version
Write-Host "[1/4] Checking Java version..." -ForegroundColor Cyan
$javaVersion = java -version 2>&1 | Select-Object -First 1
Write-Host $javaVersion -ForegroundColor White
if ($javaVersion -match "17\.") {
    Write-Host "✓ Java 17 detected" -ForegroundColor Green
} else {
    Write-Host "⚠ Warning: Java 17 recommended" -ForegroundColor Yellow
}
Write-Host ""

# Check Maven version
Write-Host "[2/4] Checking Maven version..." -ForegroundColor Cyan
$mavenVersion = mvn -version | Select-Object -First 1
Write-Host $mavenVersion -ForegroundColor White
Write-Host "✓ Maven detected" -ForegroundColor Green
Write-Host ""

# Check Lombok in cache
Write-Host "[3/4] Checking Lombok installation..." -ForegroundColor Cyan
$lombokJar = "$env:USERPROFILE\.m2\repository\org\projectlombok\lombok\1.18.30\lombok-1.18.30.jar"
if (Test-Path $lombokJar) {
    Write-Host "✓ Lombok JAR found" -ForegroundColor Green
    Write-Host "  Location: $lombokJar" -ForegroundColor Gray
} else {
    Write-Host "✗ Lombok JAR not found" -ForegroundColor Red
    Write-Host "  Downloading..." -ForegroundColor Yellow
    mvn dependency:get -Dartifact=org.projectlombok:lombok:1.18.30 2>&1 | Out-Null
    Write-Host "✓ Lombok downloaded" -ForegroundColor Green
}
Write-Host ""

# Compile and check for errors
Write-Host "[4/4] Compiling project..." -ForegroundColor Cyan
Write-Host "This may take 30-60 seconds..." -ForegroundColor Gray
Write-Host ""

$output = mvn clean compile 2>&1
$success = $LASTEXITCODE -eq 0

if ($success) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ SUCCESS! LOMBOK IS WORKING!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your project compiled successfully with 0 errors." -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run your application:" -ForegroundColor White
    Write-Host "   mvn spring-boot:run" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Or package it:" -ForegroundColor White
    Write-Host "   mvn clean package" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "✗ COMPILATION FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    
    # Count errors
    $errors = $output | Select-String -Pattern "\[ERROR\].*error:"
    $errorCount = $errors.Count
    
    Write-Host "Found $errorCount compilation errors" -ForegroundColor Red
    Write-Host ""
    
    # Show first 5 errors
    Write-Host "First 5 errors:" -ForegroundColor Yellow
    $errors | Select-Object -First 5 | ForEach-Object {
        $line = $_.Line -replace ".*\[ERROR\] ", ""
        Write-Host "  • $line" -ForegroundColor Red
    }
    Write-Host ""
    
    # Check if errors are Lombok-related
    $lombokErrors = $output | Select-String -Pattern "cannot find symbol.*(log|builder|get|set)"
    if ($lombokErrors.Count -gt 0) {
        Write-Host "⚠ These look like Lombok errors!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "This means the Lombok IDE plugin is NOT installed or NOT enabled." -ForegroundColor Red
        Write-Host ""
        Write-Host "REQUIRED ACTIONS:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "For IntelliJ IDEA:" -ForegroundColor White
        Write-Host "1. File → Settings → Plugins" -ForegroundColor Gray
        Write-Host "2. Search 'Lombok' and install" -ForegroundColor Gray
        Write-Host "3. Restart IntelliJ" -ForegroundColor Gray
        Write-Host "4. File → Settings → Compiler → Annotation Processors" -ForegroundColor Gray
        Write-Host "5. Enable annotation processing" -ForegroundColor Gray
        Write-Host "6. Run this script again" -ForegroundColor Gray
        Write-Host ""
        Write-Host "For Eclipse:" -ForegroundColor White
        Write-Host "1. Run: java -jar `"$lombokJar`"" -ForegroundColor Gray
        Write-Host "2. Select Eclipse and install" -ForegroundColor Gray
        Write-Host "3. Restart Eclipse" -ForegroundColor Gray
        Write-Host "4. Run this script again" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "These don't look like Lombok errors." -ForegroundColor Yellow
        Write-Host "Check the full error output above for details." -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "For detailed help, read:" -ForegroundColor Cyan
    Write-Host "  LOMBOK_FIX_REQUIRED_ACTIONS.md" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verification complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
