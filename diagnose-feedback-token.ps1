# Diagnose Feedback Token Issue
Write-Host "=== FEEDBACK TOKEN DIAGNOSTIC ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Check if backend is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -ErrorAction Stop
    Write-Host "✓ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend is NOT running on port 8080" -ForegroundColor Red
    Write-Host "  Start it with: .\mvnw.cmd spring-boot:run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Step 2: Test login to get a valid token..." -ForegroundColor Yellow
$loginBody = @{
    email = "nikita.a@omoikaneinnovations.com"
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/send-otp" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✓ OTP sent successfully" -ForegroundColor Green
    Write-Host "  Check your email or console for OTP" -ForegroundColor Cyan
    
    $otp = Read-Host "Enter the OTP you received"
    
    $verifyBody = @{
        email = "nikita.a@omoikaneinnovations.com"
        otp = $otp
        accountType = "PROFESSIONAL"
    } | ConvertTo-Json
    
    $tokenResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" -Method POST -Body $verifyBody -ContentType "application/json"
    $token = $tokenResponse.token
    
    Write-Host "✓ Token received: $($token.Substring(0,20))..." -ForegroundColor Green
    
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3: Test feedback API with token..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $feedbackResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/feedback?page=0&size=20" -Method GET -Headers $headers
    Write-Host "✓ Feedback API works!" -ForegroundColor Green
    Write-Host "  Total feedback: $($feedbackResponse.totalElements)" -ForegroundColor Cyan
    Write-Host "  Content count: $($feedbackResponse.content.Count)" -ForegroundColor Cyan
    
    if ($feedbackResponse.content.Count -gt 0) {
        Write-Host ""
        Write-Host "Sample feedback:" -ForegroundColor Cyan
        $feedbackResponse.content[0] | Format-List
    }
    
} catch {
    Write-Host "✗ Feedback API failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Step 4: Test CSV export..." -ForegroundColor Yellow
try {
    $csvResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/feedback/export/csv" -Method GET -Headers $headers
    Write-Host "✓ CSV export works!" -ForegroundColor Green
    Write-Host "  File size: $($csvResponse.Content.Length) bytes" -ForegroundColor Cyan
} catch {
    Write-Host "✗ CSV export failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Step 5: Test Excel export..." -ForegroundColor Yellow
try {
    $excelResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/feedback/export/excel" -Method GET -Headers $headers
    Write-Host "✓ Excel export works!" -ForegroundColor Green
    Write-Host "  File size: $($excelResponse.Content.Length) bytes" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Excel export failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== DIAGNOSTIC COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Your frontend needs to store the token with one of these keys:" -ForegroundColor Yellow
Write-Host "  - localStorage.setItem('token', tokenValue)" -ForegroundColor Cyan
Write-Host "  - localStorage.setItem('authToken', tokenValue)" -ForegroundColor Cyan
Write-Host "  - localStorage.setItem('jwt', tokenValue)" -ForegroundColor Cyan
Write-Host ""
Write-Host "The token should be: $token" -ForegroundColor Green
