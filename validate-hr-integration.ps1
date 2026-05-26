#!/usr/bin/env pwsh

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔍 VALIDATING HR INTEGRATION SETUP" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$requiredFiles = @(
    "src/main/java/com/omoikaneinnovations/omoiservespare/controller/AuthController.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/service/AuthService.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/service/HRApiService.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/dto/HREmployeeDTO.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/dto/LoginRequest.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/dto/LoginResponse.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/dto/OtpRequest.java",
    "src/main/java/com/omoikaneinnovations/omoiservespare/config/RestTemplateConfig.java",
    "src/main/resources/application.properties",
    "pom.xml"
)

$missingFiles = @()
$presentFiles = @()

Write-Host "📁 Checking required files..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
        $presentFiles += $file
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
        $missingFiles += $file
    }
}

Write-Host ""
Write-Host "📊 Validation Summary:" -ForegroundColor Cyan
Write-Host "  Present: $($presentFiles.Count) files" -ForegroundColor Green
Write-Host "  Missing: $($missingFiles.Count) files" -ForegroundColor Red

if ($missingFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "✅ All required files are present!" -ForegroundColor Green
    
    # Check configuration
    Write-Host ""
    Write-Host "🔧 Checking HR API configuration..." -ForegroundColor Yellow
    
    $appProps = Get-Content "src/main/resources/application.properties" -Raw
    
    if ($appProps -match "hr\.api\.enabled") {
        Write-Host "✅ HR API configuration found" -ForegroundColor Green
    } else {
        Write-Host "❌ HR API configuration missing" -ForegroundColor Red
    }
    
    if ($appProps -match "hr\.api\.base-url") {
        Write-Host "✅ HR API base URL configured" -ForegroundColor Green
    } else {
        Write-Host "❌ HR API base URL missing" -ForegroundColor Red
    }
    
    # Check for removed signup files
    Write-Host ""
    Write-Host "🗑️ Checking signup removal..." -ForegroundColor Yellow
    
    $signupFiles = @(
        "src/main/java/com/omoikaneinnovations/omoiservespare/dto/SignupRequest.java",
        "src/main/java/com/omoikaneinnovations/omoiservespare/dto/SignupResponse.java"
    )
    
    $removedCount = 0
    foreach ($file in $signupFiles) {
        if (-not (Test-Path $file)) {
            Write-Host "✅ $file (removed)" -ForegroundColor Green
            $removedCount++
        } else {
            Write-Host "⚠️ $file (still exists)" -ForegroundColor Yellow
        }
    }
    
    if ($removedCount -eq $signupFiles.Count) {
        Write-Host "✅ Signup files successfully removed" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "🎯 HR Integration Setup Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Run: .\start-with-hr-integration.ps1" -ForegroundColor White
    Write-Host "2. Test: .\test-hr-integration.ps1" -ForegroundColor White
    Write-Host "3. Check logs for OTP codes during testing" -ForegroundColor White
    
} else {
    Write-Host ""
    Write-Host "❌ Setup incomplete! Missing files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "   • $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan