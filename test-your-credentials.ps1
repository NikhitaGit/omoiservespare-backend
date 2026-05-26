Write-Host "============================================" -ForegroundColor Cyan
Write-Host "TESTING YOUR SPECIFIC CREDENTIALS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080"

# Your actual credentials from the form
$testCompany = "Omoiservespare Pvt Ltd"
$testEmail = "nikita@omoikaneinnovations.com"

Write-Host ""
Write-Host "Testing with your credentials:" -ForegroundColor Yellow
Write-Host "  Company: $testCompany"
Write-Host "  Email: $testEmail"
Write-Host ""

# Test login with your credentials
Write-Host "Testing login..." -ForegroundColor Green
Write-Host "-------------------------------------------"

$loginPayload = @{
    companyName = $testCompany
    email = $testEmail
    phoneNumber = ""
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginPayload -ContentType "application/json"
    Write-Host "SUCCESS: Login worked!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor White
    Write-Host ""
    Write-Host "Check your application console for the OTP code!" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: Login failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorBody = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorBody)
        $errorText = $reader.ReadToEnd()
        Write-Host "Error details: $errorText" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan