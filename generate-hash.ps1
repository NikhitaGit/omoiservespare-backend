# Generate BCrypt hash using backend utility

Write-Host "Generating BCrypt hash for 'vendor123'..." -ForegroundColor Cyan

$body = @{
    password = "vendor123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/util/hash-password" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body

    Write-Host "`n✅ Hash Generated!" -ForegroundColor Green
    Write-Host "Password: $($response.password)" -ForegroundColor White
    Write-Host "Hash: $($response.hash)" -ForegroundColor Yellow
    Write-Host "Length: $($response.length)" -ForegroundColor White
    
    # Now update the database
    Write-Host "`nUpdating database..." -ForegroundColor Cyan
    
    $env:PGPASSWORD = "NikhitaMumbai123*"
    
    $sql = "UPDATE users SET password_hash = '$($response.hash)' WHERE email = 'vendor@restaurant.com';"
    
    & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c $sql
    
    Remove-Item Env:\PGPASSWORD
    
    Write-Host "`n✅ Database updated!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
