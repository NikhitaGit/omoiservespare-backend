# Set Password for Existing Admin
# Use this to migrate admin from OTP to password-based auth

$baseUrl = "http://localhost:8080"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SET ADMIN PASSWORD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will set a password for the existing admin account" -ForegroundColor Yellow
Write-Host "Admin email: admin@company.com" -ForegroundColor Gray
Write-Host ""

$password = Read-Host "Enter new password for admin" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

if ($passwordPlain.Length -lt 6) {
    Write-Host "Password must be at least 6 characters" -ForegroundColor Red
    exit 1
}

# You'll need to create an endpoint for this or update directly in database
Write-Host ""
Write-Host "To set password, run this SQL in PostgreSQL:" -ForegroundColor Yellow
Write-Host ""
Write-Host "UPDATE users" -ForegroundColor Gray
Write-Host "SET password_hash = crypt('$passwordPlain', gen_salt('bf'))" -ForegroundColor Gray
Write-Host "WHERE email = 'admin@company.com';" -ForegroundColor Gray
Write-Host ""
Write-Host "Or use pgAdmin to update the password_hash column" -ForegroundColor Gray
Write-Host ""
Write-Host "After setting password, test login:" -ForegroundColor Yellow
Write-Host ".\test-admin-login.ps1" -ForegroundColor Gray
