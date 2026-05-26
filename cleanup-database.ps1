# =====================================================
# Cleanup Failed Migration - PowerShell Script
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔧 DATABASE CLEANUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will clean up the failed migration V11" -ForegroundColor Yellow
Write-Host ""

# Get database credentials
Write-Host "Enter your PostgreSQL credentials:" -ForegroundColor White
$dbUser = Read-Host "Username (default: postgres)"
if ([string]::IsNullOrWhiteSpace($dbUser)) {
    $dbUser = "postgres"
}

$dbName = Read-Host "Database name (default: omoiservespare_db)"
if ([string]::IsNullOrWhiteSpace($dbName)) {
    $dbName = "omoiservespare_db"
}

Write-Host ""
Write-Host "Connecting to database..." -ForegroundColor Gray

# SQL commands to clean up
$sqlCommands = @"
-- Delete failed migration
DELETE FROM flyway_schema_history WHERE version = '11';

-- Drop vendors table if exists
DROP TABLE IF EXISTS vendors CASCADE;

-- Drop trigger function if exists
DROP FUNCTION IF EXISTS update_vendors_updated_at() CASCADE;

-- Show remaining migrations
SELECT version, description, success FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;
"@

# Save to temp file
$tempFile = [System.IO.Path]::GetTempFileName() + ".sql"
$sqlCommands | Out-File -FilePath $tempFile -Encoding UTF8

try {
    # Run psql command
    Write-Host "Executing cleanup commands..." -ForegroundColor Yellow
    $result = psql -U $dbUser -d $dbName -f $tempFile 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Database cleanup successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Output:" -ForegroundColor White
        Write-Host $result -ForegroundColor Gray
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "🎉 READY TO RESTART!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Next step: Run your application" -ForegroundColor Yellow
        Write-Host "   mvn spring-boot:run" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ Cleanup failed" -ForegroundColor Red
        Write-Host ""
        Write-Host "Error:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        Write-Host ""
        Write-Host "Troubleshooting:" -ForegroundColor Yellow
        Write-Host "1. Make sure PostgreSQL is running" -ForegroundColor Gray
        Write-Host "2. Check username and database name" -ForegroundColor Gray
        Write-Host "3. Verify you have permission to delete records" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Manual cleanup:" -ForegroundColor Yellow
        Write-Host "   psql -U $dbUser -d $dbName" -ForegroundColor Cyan
        Write-Host "   DELETE FROM flyway_schema_history WHERE version = '11';" -ForegroundColor Cyan
        Write-Host "   DROP TABLE IF EXISTS vendors CASCADE;" -ForegroundColor Cyan
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error running psql" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure psql is installed and in your PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative: Use pgAdmin" -ForegroundColor Yellow
    Write-Host "1. Open pgAdmin" -ForegroundColor Gray
    Write-Host "2. Connect to database: $dbName" -ForegroundColor Gray
    Write-Host "3. Open Query Tool" -ForegroundColor Gray
    Write-Host "4. Run: cleanup-failed-migration.sql" -ForegroundColor Gray
    Write-Host ""
} finally {
    # Clean up temp file
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "For more help, see: QUICK_FIX_STEPS.md" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
