# Test OTP verification endpoint

$deviceId = [guid]::NewGuid().ToString()

Write-Host "Testing OTP verification..." -ForegroundColor Cyan

# Test with the email from your screenshot
$body = @{
    email = "nikita.a@omoikaneinnovations.com"
    otp = "1234"
} | ConvertTo-Json

Write-Host "`nRequest:" -ForegroundColor Yellow
Write-Host $body

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Device-Id" = $deviceId
        } `
        -Body $body

    Write-Host "`n✅ Success!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "`n❌ Error!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    
    try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "`nResponse:" -ForegroundColor Yellow
        Write-Host $responseBody
    } catch {
        Write-Host "Could not read response body" -ForegroundColor Yellow
    }
}
