# Complete fix for vendor login
# This will generate a hash using the backend and update the database

Write-Host "🔧 Complete Vendor Login Fix" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Step 1: Generate hash using backend
Write-Host "Step 1: Generating BCrypt hash using backend..." -ForegroundColor Yellow

$body = @{
    password = "vendor123"
} | ConvertTo-Json

try {
    $hashResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/util/hash-password" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body `
        -ErrorAction Stop

    Write-Host "✅ Hash generated successfully!" -ForegroundColor Green
    Write-Host "Hash: $($hashResponse.hash)" -ForegroundColor White
    
    # Step 2: Update database
    Write-Host "`nStep 2: Updating database..." -ForegroundColor Yellow
    
    $env:PGPASSWORD = "NikhitaMumbai123*"
    
    $sql = "UPDATE users SET password_hash = '$($hashResponse.hash)' WHERE email = 'vendor@restaurant.com';"
    
    $psqlExe = Join-Path ${env:ProgramFiles} "PostgreSQL\16\bin\psql.exe"
    & $psqlExe -U postgres -d omoiservespare_db -c $sql | Out-Null
    
    Write-Host "✅ Database updated!" -ForegroundColor Green
    
    # Step 3: Verify the hash
    Write-Host "`nStep 3: Verifying password..." -ForegroundColor Yellow
    
    $verifyBody = @{
        password = "vendor123"
        hash = $hashResponse.hash
    } | ConvertTo-Json
    
    $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/util/verify-password" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $verifyBody `
        -ErrorAction Stop
    
    if ($verifyResponse.matches) {
        Write-Host "✅ Password verification successful!" -ForegroundColor Green
    } else {
        Write-Host "❌ Password verification failed!" -ForegroundColor Red
        exit 1
    }
    
    # Step 4: Test login
    Write-Host "`nStep 4: Testing vendor login..." -ForegroundColor Yellow
    
    $deviceId = [guid]::NewGuid().ToString()
    
    $loginBody = @{
        email = "vendor@restaurant.com"
        password = "vendor123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/vendor/login" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Device-Id" = $deviceId
        } `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "`nLogin Response:" -ForegroundColor Cyan
    Write-Host "Success: $($loginResponse.success)" -ForegroundColor White
    Write-Host "Email: $($loginResponse.email)" -ForegroundColor White
    Write-Host "Role: $($loginResponse.role)" -ForegroundColor White
    Write-Host "Vendor Status: $($loginResponse.vendorStatus)" -ForegroundColor White
    Write-Host "Access Token: $($loginResponse.accessToken.Substring(0, 50))..." -ForegroundColor White
    
    Write-Host "`n✅ ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "`nYou can now login at http://localhost:5174/login with:" -ForegroundColor Cyan
    Write-Host "Email: vendor@restaurant.com" -ForegroundColor White
    Write-Host "Password: vendor123" -ForegroundColor White
    
    Remove-Item Env:\PGPASSWORD
    
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            $reader.Close()
            Write-Host "`nResponse Body:" -ForegroundColor Yellow
            Write-Host $responseBody
        } catch {
            Write-Host "Could not read response body" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure the backend is running" -ForegroundColor White
    Write-Host "2. Check if the utility endpoint is accessible" -ForegroundColor White
    Write-Host "3. Verify SecurityConfig allows utility endpoints" -ForegroundColor White
    
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    exit 1
}
