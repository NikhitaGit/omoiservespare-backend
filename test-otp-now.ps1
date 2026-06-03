# Quick OTP Test Script
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Testing OTP Email System" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$BASE_URL = "http://localhost:8080"

# Test data - CHANGE THIS TO YOUR EMAIL
$TEST_EMAIL = "lata.b@omoikaneinnovations.com"
$TEST_COMPANY = "Omoiservespare Pvt Ltd"
$TEST_PHONE = "+91-9876543210"

Write-Host "`n1. Testing backend health..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/api/auth/health" -Method Get -TimeoutSec 5
    Write-Host "✅ Backend is running: $health" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is not responding" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Requesting OTP for: $TEST_EMAIL" -ForegroundColor Yellow

$body = @{
    companyName = $TEST_COMPANY
    email = $TEST_EMAIL
    phoneNumber = $TEST_PHONE
} | ConvertTo-Json

Write-Host "Request body: $body" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod `
        -Uri "$BASE_URL/api/auth/user/login" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 30
    
    Write-Host "✅ OTP Request Successful!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json)" -ForegroundColor Gray
    
    Write-Host "`n================================" -ForegroundColor Cyan
    Write-Host "CHECK YOUR EMAIL INBOX!" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Email: $TEST_EMAIL" -ForegroundColor Yellow
    Write-Host "`nLook for:" -ForegroundColor Yellow
    Write-Host "  • Email from: aishushettar95@gmail.com" -ForegroundColor White
    Write-Host "  • Subject: Your Login OTP" -ForegroundColor White
    Write-Host "  • Professional HTML formatting" -ForegroundColor White
    Write-Host "  • 4-digit OTP code" -ForegroundColor White
    Write-Host "`n*** Check spam folder if not in inbox!" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ OTP Request Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Backend Logs:" -ForegroundColor Yellow
Write-Host "Check your Spring Boot console for:" -ForegroundColor White
Write-Host "  EMAIL SERVICE: OTP Send Initiated" -ForegroundColor Gray
Write-Host "  EMAIL SENT SUCCESSFULLY" -ForegroundColor Gray
Write-Host "================================" -ForegroundColor Cyan
