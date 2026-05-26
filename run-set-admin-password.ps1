# Automated Admin Password Setup
# Sets password for admin@company.com to: admin123

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SET ADMIN PASSWORD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if psql is available
try {
    $null = Get-Command psql -ErrorAction Stop
} catch {
    Write-Host "ERROR: psql not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install PostgreSQL or add it to PATH" -ForegroundColor Yellow
    Write-Host "Typical location: C:\Program Files\PostgreSQL\16\bin" -ForegroundColor Gray
    exit 1
}

# Check if SQL file exists
if (-not (Test-Path "set-admin-password.sql")) {
    Write-Host "ERROR: set-admin-password.sql not found" -ForegroundColor Red
    exit 1
}

Write-Host "This will set admin password to: admin123" -ForegroundColor Yellow
Write-Host ""

# Get PostgreSQL password
$pgPassword = Read-Host "Enter PostgreSQL password for user 'postgres'" -AsSecureString
$pgPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pgPassword))

# Set environment variable
$env:PGPASSWORD = $pgPasswordPlain

Write-Host ""
Write-Host "Connecting to database..." -ForegroundColor Yellow

try {
    # Run SQL file
    $output = psql -U postgres -d omoiservespare -f set-admin-password.sql 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Admin password has been set!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Login Credentials:" -ForegroundColor White
        Write-Host "  Email: admin@company.com" -ForegroundColor Gray
        Write-Host "  Password: admin123" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Test login with:" -ForegroundColor Yellow
        Write-Host "  .\test-admin-login.ps1" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "ERROR: Failed to set password" -ForegroundColor Red
        Write-Host ""
        Write-Host "Output:" -ForegroundColor Yellow
        Write-Host $output -ForegroundColor Gray
        Write-Host ""
        Write-Host "Troubleshooting:" -ForegroundColor Yellow
        Write-Host "1. Make sure admin exists: .\create-first-admin.ps1" -ForegroundColor Gray
        Write-Host "2. Check database name in application.properties" -ForegroundColor Gray
        Write-Host "3. Verify PostgreSQL is running" -ForegroundColor Gray
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clear password from environment
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
