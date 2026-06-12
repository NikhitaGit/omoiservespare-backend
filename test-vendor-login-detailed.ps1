# Detailed Vendor Login Test

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Detailed Vendor Login Test" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$email = "vendor@restaurant.com"
$password = "vendor123"
$deviceId = [guid]::NewGuid().ToString()

Write-Host "Test 1: Direct backend API call" -ForegroundColor Yellow
Write-Host "Email: $email" -ForegroundColor Gray
Write-Host "Password: $password" -ForegroundColor Gray
Write-Host "Device ID: $deviceId" -ForegroundColor Gray
Write-Host ""

$loginBody = @{
    email = $email
    password = $password
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Cyan
Write-Host $loginBody
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/vendor/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json" `
        -Headers @{
            "X-Device-ID" = $deviceId
            "X-Device-Name" = "PowerShell Test"
        } `
        -UseBasicParsing

    Write-Host "✓ Success! Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 5
    
} catch {
    Write-Host "✗ Failed! Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error Message:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host ""
    
    if ($_.ErrorDetails.Message) {
        Write-Host "Error Details:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message
    }
    
    Write-Host ""
    Write-Host "Full Exception:" -ForegroundColor Red
    Write-Host ($_ | Format-List * -Force | Out-String)
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Checking backend logs..." -ForegroundColor Yellow
Write-Host "Look for 'Vendor login attempt' or error messages" -ForegroundColor Gray
Write-Host "================================" -ForegroundColor Cyan
