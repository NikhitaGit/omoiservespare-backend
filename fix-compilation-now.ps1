# 🔧 Fix All Compilation Errors
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "FIXING COMPILATION ERRORS" -ForegroundColor Yellow
Write-Host "=" * 60 -ForegroundColor Cyan

# Step 1: Delete target directory completely
Write-Host "`n[1/5] 🗑️  Cleaning build artifacts..." -ForegroundColor Cyan
if (Test-Path "target") {
    Remove-Item -Recurse -Force "target"
    Write-Host "   ✅ Deleted target/ directory" -ForegroundColor Green
}

# Step 2: Clean Maven cache
Write-Host "`n[2/5] 🧹 Running Maven clean..." -ForegroundColor Cyan
mvn clean -q
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Maven clean successful" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Maven clean had warnings (continuing...)" -ForegroundColor Yellow
}

# Step 3: Download latest dependencies
Write-Host "`n[3/5] 📦 Updating dependencies..." -ForegroundColor Cyan
mvn dependency:resolve -U -q
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Dependencies updated" -ForegroundColor Green
}

# Step 4: Compile with annotation processing
Write-Host "`n[4/5] ⚙️  Compiling with Lombok annotation processing..." -ForegroundColor Cyan
mvn compile -DskipTests

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ COMPILATION FAILED" -ForegroundColor Red
    Write-Host "`nPossible issues:" -ForegroundColor Yellow
    Write-Host "  1. Lombok not installed in your IDE"
    Write-Host "  2. Stale Java compiler cache"
    Write-Host "  3. Conflicting Java versions"
    
    Write-Host "`nTry these fixes:" -ForegroundColor Cyan
    Write-Host "  • Restart your computer" -ForegroundColor White
    Write-Host "  • Run: mvn clean install -U -X" -ForegroundColor White
    Write-Host "  • Check Java version: java -version" -ForegroundColor White
    
    exit 1
}

# Step 5: Verify compilation
Write-Host "`n[5/5] ✅ Verifying compilation..." -ForegroundColor Cyan
if (Test-Path "target/classes") {
    $classCount = (Get-ChildItem -Path "target/classes" -Recurse -Filter "*.class" | Measure-Object).Count
    Write-Host "   ✅ Compiled $classCount class files" -ForegroundColor Green
} else {
    Write-Host "   ❌ No class files found" -ForegroundColor Red
    exit 1
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ COMPILATION SUCCESSFUL!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan

Write-Host "`nNext step:" -ForegroundColor Yellow
Write-Host "  mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
