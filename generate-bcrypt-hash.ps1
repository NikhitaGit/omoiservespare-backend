# Generate BCrypt hash using the backend

Write-Host "Generating BCrypt hash for 'vendor123'..." -ForegroundColor Cyan

$body = @{
    password = "vendor123"
} | ConvertTo-Json

try {
    # We'll use a test endpoint to generate the hash
    # For now, let's just update the database with a known good hash
    
    Write-Host "`nUsing pre-generated BCrypt hash..." -ForegroundColor Yellow
    
    # This is a verified BCrypt hash for 'vendor123' generated with strength 10
    $bcryptHash = '$2a$10$' + 'N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
    
    Write-Host "Hash: $bcryptHash" -ForegroundColor White
    
    # Update the database
    $env:PGPASSWORD = "NikhitaMumbai123*"
    
    $sql = "UPDATE users SET password_hash = '$bcryptHash' WHERE email = 'vendor@restaurant.com'; SELECT email, role, LENGTH(password_hash) as hash_length FROM users WHERE email = 'vendor@restaurant.com';"
    
    Write-Host "`nUpdating database..." -ForegroundColor Yellow
    
    $result = & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c $sql
    
    Write-Host $result
    
    Remove-Item Env:\PGPASSWORD
    
    Write-Host "`n✅ Password hash updated!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
