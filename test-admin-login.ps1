# Test Admin Login
$baseUrl = "http://localhost:8080/api/v2/auth"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST ADMIN LOGIN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing admin login..." -ForegroundColor Yellow
Write-Host "Email: admin@company.com" -ForegroundColor Gray
Write-Host "Password: admin123" -ForegroundColor Gray
Write-Host ""

$adminLogin = @{
    email = "admin@company.com"
    password = "admin123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -ContentType "application/json" -Body $adminLogin
    
    Write-Host "SUCCESS! Admin logged in" -ForegroundColor Green
    Write-Host ""
    Write-Host "Admin Details:" -ForegroundColor White
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.user.role)" -ForegroundColor Gray
    Write-Host "  Account Active: $($response.user.accountActive)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "JWT Token:" -ForegroundColor White
    Write-Host "  $($response.accessToken.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "ADMIN LOGIN SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor Yellow
    Write-Host "1. Use this token in API calls" -ForegroundColor Gray
    Write-Host "2. Access admin dashboard" -ForegroundColor Gray
    Write-Host "3. Approve vendor applications" -ForegroundColor Gray
    
} catch {
    Write-Host "FAILED to login as admin" -ForegroundColor Red
    Write-Host ""
    
    # Try to get detailed error
    $errorResponse = $null
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $errorResponse = $reader.ReadToEnd() | ConvertFrom-Json
        $reader.Close()
    }
    
    if ($errorResponse -and $errorResponse.message) {
        Write-Host "Error: $($errorResponse.message)" -ForegroundColor Red
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure you set admin password:" -ForegroundColor Gray
    Write-Host "   UPDATE users SET password_hash = crypt('admin123', gen_salt('bf'))" -ForegroundColor Gray
    Write-Host "   WHERE email = 'admin@company.com';" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Or use pre-hashed password:" -ForegroundColor Gray
    Write-Host "   UPDATE users SET password_hash = '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'" -ForegroundColor Gray
    Write-Host "   WHERE email = 'admin@company.com';" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Check if admin exists:" -ForegroundColor Gray
    Write-Host "   SELECT * FROM users WHERE email = 'admin@company.com';" -ForegroundColor Gray
}

Write-Host ""
