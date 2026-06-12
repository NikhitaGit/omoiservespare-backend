# Fix Flyway Migration and Restart Application

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Fixing Flyway Migration V24" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Get database credentials from .env
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

$DB_HOST = $env:DB_HOST
$DB_PORT = $env:DB_PORT
$DB_NAME = $env:DB_NAME
$DB_USER = $env:DB_USER
$DB_PASSWORD = $env:DB_PASSWORD

Write-Host "Database Connection:" -ForegroundColor Yellow
Write-Host "  Host: $DB_HOST" -ForegroundColor Gray
Write-Host "  Port: $DB_PORT" -ForegroundColor Gray
Write-Host "  Database: $DB_NAME" -ForegroundColor Gray
Write-Host "  User: $DB_USER" -ForegroundColor Gray
Write-Host ""

Write-Host "Step 1: Cleaning up failed migration..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASSWORD
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f fix-flyway-migration.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Migration cleanup successful" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to clean up migration" -ForegroundColor Red
    Write-Host "Please run the SQL manually or check PostgreSQL connection" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Step 2: Starting application..." -ForegroundColor Yellow
Write-Host ""

mvnw.cmd spring-boot:run
