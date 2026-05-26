# Quick Run Script for OmoiServeSpare Application
# This script runs the Spring Boot application

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting OmoiServeSpare Application" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if MongoDB is running (optional for helpdesk)
Write-Host "Checking MongoDB status..." -ForegroundColor Yellow
try {
    $mongoService = Get-Service -Name MongoDB -ErrorAction SilentlyContinue
    if ($mongoService -and $mongoService.Status -eq 'Running') {
        Write-Host "✅ MongoDB is running" -ForegroundColor Green
    } else {
        Write-Host "⚠️  MongoDB is not running (needed for helpdesk system)" -ForegroundColor Yellow
        Write-Host "To start MongoDB: net start MongoDB" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  MongoDB status unknown" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting Spring Boot application..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

# Run the application
mvn spring-boot:run

Write-Host ""
Write-Host "Application stopped." -ForegroundColor Yellow
