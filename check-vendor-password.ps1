# Check vendor password hash

$env:PGPASSWORD = "NikhitaMumbai123*"

Write-Host "Checking vendor password..." -ForegroundColor Cyan

$sql = "SELECT email, role, vendor_status, password_hash FROM users WHERE email = 'vendor@restaurant.com';"

& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c $sql

Remove-Item Env:\PGPASSWORD
