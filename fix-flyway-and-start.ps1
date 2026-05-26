# =====================================================
# Fix Flyway Migration and Start Application
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIXING FLYWAY MIGRATION ISSUE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Database connection details
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "omoiservespare"
$DB_USER = "postgres"
$DB_PASSWORD = "root"

Write-Host "Step 1: Deleting failed migration record from Flyway..." -ForegroundColor Yellow

# Delete the failed migration record
$deleteQuery = "DELETE FROM flyway_schema_history WHERE version = '12';"

$env:PGPASSWORD = $DB_PASSWORD
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c $deleteQuery

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Failed migration record deleted successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to delete migration record" -ForegroundColor Red
    Write-Host "You may need to run this manually in PostgreSQL:" -ForegroundColor Yellow
    Write-Host "DELETE FROM flyway_schema_history WHERE version = '12';" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "Step 2: Verifying vendors table exists..." -ForegroundColor Yellow

$checkQuery = "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'vendors';"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c $checkQuery

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STARTING SPRING BOOT APPLICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Start the application
mvn spring-boot:run

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "If the application started successfully:" -ForegroundColor Green
Write-Host "- Backend: http://localhost:8080" -ForegroundColor White
Write-Host "- Frontend: http://localhost:5173/login" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
