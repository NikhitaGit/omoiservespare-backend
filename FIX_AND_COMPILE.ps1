# ============================================
# COMPLETE FIX AND COMPILE SCRIPT
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIXING COMPILATION ISSUES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Force Java 17
Write-Host "[1/3] Setting Java 17..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "  Java Version:" -ForegroundColor Gray
java -version 2>&1 | Select-Object -First 1
Write-Host ""

# Step 2: Clean old build
Write-Host "[2/3] Cleaning old build..." -ForegroundColor Yellow
if (Test-Path "target") {
    Remove-Item -Recurse -Force "target" -ErrorAction SilentlyContinue
    Write-Host "  ✓ Cleaned target directory" -ForegroundColor Green
}
Write-Host ""

# Step 3: Compile
Write-Host "[3/3] Compiling project..." -ForegroundColor Yellow
Write-Host ""

.\mvnw.cmd clean compile -DskipTests

Write-Host ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: powershell -ExecutionPolicy Bypass -File start-with-java17.ps1" -ForegroundColor White
    Write-Host "  2. Or use: .\mvnw.cmd spring-boot:run" -ForegroundColor White
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "✗ BUILD FAILED!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the error messages above." -ForegroundColor Yellow
}
