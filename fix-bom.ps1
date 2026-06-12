# Fix BOM in UnifiedAuthService.java
$file = "src\main\java\com\omoikaneinnovations\omoiservespare\service\UnifiedAuthService.java"

# Read content
$content = Get-Content $file -Raw

# Remove BOM if present
if ($content[0] -eq [char]0xFEFF) {
    $content = $content.Substring(1)
    Write-Host "BOM found and removed" -ForegroundColor Yellow
}

# Write without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Resolve-Path $file).Path, $content, $utf8NoBom)

Write-Host "✅ File encoding fixed (UTF-8 without BOM)" -ForegroundColor Green

# Clean and recompile
Write-Host "`nCleaning target folder..." -ForegroundColor Cyan
mvn clean

Write-Host "`nStarting application..." -ForegroundColor Cyan
mvn spring-boot:run
