# Check if compilation was successful
if (Test-Path "target\classes") {
    Write-Host "Compilation successful! Classes directory exists." -ForegroundColor Green
} else {
    Write-Host "Compilation failed or not complete yet." -ForegroundColor Red
}
