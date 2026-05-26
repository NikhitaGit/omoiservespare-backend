# Verify Lombok Plugin Installation
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LOMBOK PLUGIN VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run this AFTER installing Lombok plugin in your IDE" -ForegroundColor Yellow
Write-Host ""

# Clean and compile
Write-Host "Testing compilation..." -ForegroundColor Cyan
mvn clean compile 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! LOMBOK IS WORKING!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your project compiled with 0 errors." -ForegroundColor White
    Write-Host ""
    Write-Host "You can now run your application:" -ForegroundColor Cyan
    Write-Host "  mvn spring-boot:run" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "STILL FAILING" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "The IDE plugin may not be installed correctly." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Cyan
    Write-Host "1. Did you restart your IDE after installing the plugin?" -ForegroundColor White
    Write-Host "2. Is annotation processing enabled in IDE settings?" -ForegroundColor White
    Write-Host "3. Did you invalidate IDE caches?" -ForegroundColor White
    Write-Host ""
    Write-Host "For IntelliJ IDEA:" -ForegroundColor Cyan
    Write-Host "- File -> Invalidate Caches -> Invalidate and Restart" -ForegroundColor White
    Write-Host "- Settings -> Compiler -> Annotation Processors -> Enable" -ForegroundColor White
    Write-Host ""
}
