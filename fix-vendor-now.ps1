# Quick vendor login fix

Write-Host "Fixing vendor login..." -ForegroundColor Cyan

# Generate hash
$body = @{ password = "vendor123" } | ConvertTo-Json

try {
    $hash = Invoke-RestMethod -Uri "http://localhost:8080/api/util/hash-password" -Method POST -Headers @{"Content-Type"="application/json"} -Body $body
    
    Write-Host "Hash generated: $($hash.hash)" -ForegroundColor Yellow
    
    # Update database
    $env:PGPASSWORD = "NikhitaMumbai123*"
    $sql = "UPDATE users SET password_hash = '$($hash.hash)' WHERE email = 'vendor@restaurant.com';"
    
    psql -U postgres -d omoiservespare_db -c $sql
    
    Remove-Item Env:\PGPASSWORD
    
    # Test login
    Write-Host "`nTesting login..." -ForegroundColor Cyan
    
    $loginBody = @{ email = "vendor@restaurant.com"; password = "vendor123" } | ConvertTo-Json
    $deviceId = [guid]::NewGuid().ToString()
    
    $result = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/vendor/login" -Method POST -Headers @{"Content-Type"="application/json";"X-Device-Id"=$deviceId} -Body $loginBody
    
    Write-Host "Success: $($result.success)" -ForegroundColor Green
    Write-Host "Role: $($result.role)" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
