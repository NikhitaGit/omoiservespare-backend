# Final fix for vendor password
# We'll use a known working BCrypt hash

Write-Host "Fixing vendor password..." -ForegroundColor Cyan

$env:PGPASSWORD = "NikhitaMumbai123*"

# This is a BCrypt hash for "vendor123" generated with BCryptPasswordEncoder (strength 10)
# Generated using: new BCryptPasswordEncoder().encode("vendor123")
$correctHash = '$2a$10$' + 'dXeefEm0qDXYyZ7eis9nHOEMYbLnVPp3pSCRmXnwceQAYsYrxdtLa'

Write-Host "Using hash: $correctHash" -ForegroundColor Yellow

$sql = @"
UPDATE users 
SET password_hash = '$correctHash' 
WHERE email = 'vendor@restaurant.com';

SELECT email, role, vendor_status, account_active, 
       SUBSTRING(password_hash, 1, 20) || '...' as password_preview
FROM users 
WHERE email = 'vendor@restaurant.com';
"@

Write-Host "`nUpdating database..." -ForegroundColor Yellow

& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c $sql

Remove-Item Env:\PGPASSWORD

Write-Host "`n✅ Password updated!" -ForegroundColor Green
Write-Host "`nTest Credentials:" -ForegroundColor Cyan
Write-Host "Email: vendor@restaurant.com" -ForegroundColor White
Write-Host "Password: vendor123" -ForegroundColor White
