Write-Host "============================================" -ForegroundColor Cyan
Write-Host "QUICK VALIDATION - HR INTEGRATION" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Check key files exist
$keyFiles = @(
    "src/main/java/com/omoikaneinnovations/omoiservespare/service/HRApiService.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/dto/HREmployeeDTO.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/config/RestTemplateConfig.java"
)

Write-Host "Checking key HR integration files..." -ForegroundColor Yellow

$allPresent = $true
foreach ($file in $keyFiles) {
    if (Test-Path $file) {
        Write-Host "OK: $file" -ForegroundColor Green
    } else {
        Write-Host "MISSING: $file" -ForegroundColor Red
        $allPresent = $false
    }
}

# Check signup files are removed
$signupFiles = @(
    "src/main/java/com/omoikaneinnovations/omoiservespare/dto/SignupRequest.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/dto/SignupResponse.java"
)

Write-Host ""
Write-Host "Checking signup removal..." -ForegroundColor Yellow

foreach ($file in $signupFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "OK: $file (removed)" -ForegroundColor Green
    } else {
        Write-Host "WARNING: $file (still exists)" -ForegroundColor Yellow
    }
}

# Try to compile
Write-Host ""
Write-Host "Testing compilation..." -ForegroundColor Yellow

try {
    $compileResult = mvn compile -q 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: Application compiles successfully" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Compilation failed" -ForegroundColor Red
        Write-Host $compileResult -ForegroundColor Red
        $allPresent = $false
    }
} catch {
    Write-Host "ERROR: Could not test compilation" -ForegroundColor Red
    $allPresent = $false
}

Write-Host ""
if ($allPresent) {
    Write-Host "SUCCESS: HR Integration is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Start: mvn spring-boot:run" -ForegroundColor White
    Write-Host "2. Test with company: 'Omoikane Innovations'" -ForegroundColor White
    Write-Host "3. Test with email: 'john.doe@omoikaneinnovations.com'" -ForegroundColor White
    Write-Host "4. Check console for OTP codes" -ForegroundColor White
} else {
    Write-Host "ERROR: Setup incomplete!" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan