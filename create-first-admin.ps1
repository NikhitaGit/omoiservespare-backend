# Create First Admin Script
$baseUrl = "http://localhost:8080"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CREATE FIRST ADMIN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$adminData = @{
    email = "admin@company.com"
    phoneNumber = "+9876543210"
    fullName = "System Administrator"
    secretKey = "qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG"
} | ConvertTo-Json

Write-Host "Creating first admin..." -ForegroundColor Yellow
Write-Host "Email: admin@company.com" -ForegroundColor Gray
Write-Host "Phone: +9876543210" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/create-first" -Method POST -ContentType "application/json" -Body $adminData
    
    Write-Host "SUCCESS! First admin created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Admin Details:" -ForegroundColor White
    Write-Host "  Email: $($response.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.role)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "You can now login as admin!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Login with email: admin@company.com" -ForegroundColor Gray
    Write-Host "2. Use phone: +9876543210" -ForegroundColor Gray
    Write-Host "3. Verify OTP from console logs" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "FAILED to create admin" -ForegroundColor Red
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
        
        if ($errorResponse.message -match "already exists") {
            Write-Host ""
            Write-Host "Admin already created!" -ForegroundColor Yellow
            Write-Host "You can login with: admin@company.com" -ForegroundColor Gray
        }
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Troubleshooting:" -ForegroundColor Yellow
        Write-Host "1. Make sure application is running on port 8080" -ForegroundColor Gray
        Write-Host "2. Check if secret key matches application.properties" -ForegroundColor Gray
        Write-Host "3. Verify database is accessible" -ForegroundColor Gray
        Write-Host "4. Check Spring Boot logs for details" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "For more info, see: PRODUCTION_SIGNUP_QUICK_START.md" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
