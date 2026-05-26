# Test Vendor Login Endpoint

$deviceId = [guid]::NewGuid().ToString()

Write-Host "Testing Vendor Login..." -ForegroundColor Cyan
Write-Host "Device ID: $deviceId" -ForegroundColor Yellow

$body = @{
    email = "vendor@restaurant.com"
    password = "vendor123"
} | ConvertTo-Json

Write-Host "`nRequest Body:" -ForegroundColor Yellow
Write-Host $body

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/vendor/login" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Device-Id" = $deviceId
        } `
        -Body $body `
        -ErrorAction Stop

    Write-Host "`n✅ Login Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`n❌ Login Failed!" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try to read the response body
    try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "`nResponse Body:" -ForegroundColor Yellow
        Write-Host $responseBody
    } catch {
        if ($_.ErrorDetails.Message) {
            Write-Host "`nError Details:" -ForegroundColor Yellow
            Write-Host $_.ErrorDetails.Message
        }
    }
}
