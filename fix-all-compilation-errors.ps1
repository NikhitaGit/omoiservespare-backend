# Fix All Compilation Errors
Write-Host "🔧 Fixing all compilation errors..." -ForegroundColor Cyan

# Clean Maven cache
Write-Host "`n1️⃣ Cleaning Maven build..." -ForegroundColor Yellow
mvn clean

# Verify Lombok is in pom.xml
Write-Host "`n2️⃣ Verifying Lombok dependency..." -ForegroundColor Yellow
$pomContent = Get-Content "pom.xml" -Raw
if ($pomContent -notmatch "lombok") {
    Write-Host "❌ Lombok not found in pom.xml" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Lombok dependency found" -ForegroundColor Green

# Try compilation
Write-Host "`n3️⃣ Attempting compilation..." -ForegroundColor Yellow
mvn compile -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Compilation successful!" -ForegroundColor Green
    Write-Host "`nRun: mvn spring-boot:run" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Compilation failed. Check errors above." -ForegroundColor Red
    Write-Host "`nTry running: mvn clean install -U" -ForegroundColor Yellow
}
