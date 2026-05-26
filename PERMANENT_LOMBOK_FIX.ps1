# Permanent Lombok Fix Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PERMANENT LOMBOK COMPILATION FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Stop any running Java processes
Write-Host "`n[1/6] Stopping any running Java processes..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Clean target directory
Write-Host "`n[2/6] Cleaning target directory..." -ForegroundColor Yellow
if (Test-Path "target") {
    Remove-Item -Path "target" -Recurse -Force
    Write-Host "Target directory cleaned" -ForegroundColor Green
}

# Step 3: Clear Maven cache for Lombok
Write-Host "`n[3/6] Clearing Lombok from Maven cache..." -ForegroundColor Yellow
$lombokCache = "$env:USERPROFILE\.m2\repository\org\projectlombok"
if (Test-Path $lombokCache) {
    Remove-Item -Path $lombokCache -Recurse -Force
    Write-Host "Lombok cache cleared" -ForegroundColor Green
}

# Step 4: Clear Maven compiler plugin cache
Write-Host "`n[4/6] Clearing compiler plugin cache..." -ForegroundColor Yellow
$compilerCache = "$env:USERPROFILE\.m2\repository\org\apache\maven\plugins\maven-compiler-plugin"
if (Test-Path $compilerCache) {
    Remove-Item -Path $compilerCache -Recurse -Force
    Write-Host "Compiler cache cleared" -ForegroundColor Green
}

# Step 5: Force download dependencies
Write-Host "`n[5/6] Downloading fresh dependencies..." -ForegroundColor Yellow
mvn dependency:purge-local-repository -DactFully=false -DreResolve=false
mvn dependency:resolve -U

# Step 6: Compile with verbose output
Write-Host "`n[6/6] Compiling with Lombok annotation processing..." -ForegroundColor Yellow
Write-Host "This may take a minute..." -ForegroundColor Gray
mvn clean compile -X -DskipTests 2>&1 | Select-String -Pattern "lombok|annotation|processor" | ForEach-Object {
    Write-Host $_ -ForegroundColor Gray
}

# Check result
Write-Host "`n========================================" -ForegroundColor Cyan
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS! Lombok is now working!" -ForegroundColor Green
    Write-Host "`nYou can now run: mvn spring-boot:run" -ForegroundColor Green
} else {
    Write-Host "COMPILATION STILL FAILING" -ForegroundColor Red
    Write-Host "`nTrying alternative fix..." -ForegroundColor Yellow
    
    # Alternative: Install Lombok agent
    Write-Host "`nDownloading Lombok JAR..." -ForegroundColor Yellow
    $lombokJar = "$env:USERPROFILE\.m2\repository\org\projectlombok\lombok\1.18.30\lombok-1.18.30.jar"
    
    if (Test-Path $lombokJar) {
        Write-Host "Lombok JAR found at: $lombokJar" -ForegroundColor Green
        Write-Host "`nIMPORTANT: You need to install Lombok in your IDE:" -ForegroundColor Yellow
        Write-Host "1. Run this command: java -jar `"$lombokJar`"" -ForegroundColor Cyan
        Write-Host "2. Select your IDE installation directory" -ForegroundColor Cyan
        Write-Host "3. Click 'Install/Update'" -ForegroundColor Cyan
        Write-Host "4. Restart your IDE" -ForegroundColor Cyan
    }
}

Write-Host "========================================" -ForegroundColor Cyan
