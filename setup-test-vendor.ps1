# Setup Test Vendor with Proper Password

Write-Host "Setting up test vendor..." -ForegroundColor Cyan

# PostgreSQL connection details
$env:PGPASSWORD = "NikhitaMumbai123*"
$dbName = "omoiservespare_db"
$user = "postgres"

# Run the SQL script
Write-Host "`nExecuting SQL script..." -ForegroundColor Yellow

& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U $user -d $dbName -f create-test-vendor.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Test vendor created successfully!" -ForegroundColor Green
    Write-Host "`nTest Credentials:" -ForegroundColor Cyan
    Write-Host "Email: vendor@restaurant.com" -ForegroundColor White
    Write-Host "Password: vendor123" -ForegroundColor White
} else {
    Write-Host "`n❌ Failed to create test vendor" -ForegroundColor Red
}

# Clear password from environment
Remove-Item Env:\PGPASSWORD
