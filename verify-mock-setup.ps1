Write-Host "============================================" -ForegroundColor Cyan
Write-Host "VERIFYING MOCK HR SETUP" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Checking if required files exist..." -ForegroundColor Yellow

$files = @(
    "src/main/java/com/omoikaneinnovations/omoiservespare/service/MockHRDataService.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/controller/HRMockDataController.java"
)

$allExist = $true
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "OK: $file" -ForegroundColor Green
    } else {
        Write-Host "MISSING: $file" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host ""
    Write-Host "ERROR: Required files are missing!" -ForegroundColor Red
    Write-Host "Please ensure MockHRDataService.java and HRMockDataController.java exist" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Compiling application..." -ForegroundColor Yellow

try {
    $compileOutput = mvn compile -q 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: Application compiles successfully" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Compilation failed" -ForegroundColor Red
        Write-Host $compileOutput -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Could not compile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SETUP VERIFIED!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Stop your current application (Ctrl+C)" -ForegroundColor White
Write-Host "2. Run: mvn spring-boot:run" -ForegroundColor White
Write-Host "3. Look for: 'Mock HR Data initialized: 10 employees'" -ForegroundColor White
Write-Host "4. Try login again" -ForegroundColor White
Write-Host ""