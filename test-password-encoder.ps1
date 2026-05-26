# Test password encoder

Write-Host "Testing password encoder..." -ForegroundColor Cyan

# Get the current hash from database
$env:PGPASSWORD = "NikhitaMumbai123*"

$sql = "SELECT password_hash FROM users WHERE email = 'vendor@restaurant.com';"

$hash = & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -t -c $sql

Remove-Item Env:\PGPASSWORD

$hash = $hash.Trim()

Write-Host "Current hash in DB: $hash" -ForegroundColor Yellow

# Now test if the backend can verify it
$body = @{
    password = "vendor123"
    hash = $hash
} | ConvertTo-Json

Write-Host "`nTesting password verification..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/util/verify-password" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body

    Write-Host "`nResult:" -ForegroundColor Yellow
    Write-Host "Password: $($response.password)" -ForegroundColor White
    Write-Host "Matches: $($response.matches)" -ForegroundColor $(if ($response.matches) { "Green" } else { "Red" })
    
    if ($response.matches) {
        Write-Host "`n✅ Password encoder is working correctly!" -ForegroundColor Green
    } else {
        Write-Host "`n❌ Password does not match!" -ForegroundColor Red
    }
    
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure the backend is running and the utility endpoint is accessible" -ForegroundColor Yellow
}
