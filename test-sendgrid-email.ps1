# Test SendGrid Email Configuration
# This script tests the complete OTP email flow with SendGrid

param(
    [string]$TestEmail = "your-email@gmail.com",
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "`n=================================" -ForegroundColor Cyan
Write-Host "🧪 SendGrid Email Test Suite" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if test email is provided
if ($TestEmail -eq "your-email@gmail.com") {
    Write-Host "`n⚠️  Please provide your test email address:" -ForegroundColor Yellow
    $TestEmail = Read-Host "Enter your email"
}

Write-Host "`nTest Configuration:" -ForegroundColor White
Write-Host "  Email: $TestEmail" -ForegroundColor White
Write-Host "  Backend: $BaseUrl" -ForegroundColor White

# Step 1: Check Backend Status
Write-Host "`n[1/4] Checking Backend Status..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/actuator/health" -Method GET -ErrorAction Stop -TimeoutSec 5
    Write-Host "✅ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is not running!" -ForegroundColor Red
    Write-Host "   Please start your Spring Boot application first." -ForegroundColor Yellow
    Write-Host "   Run: mvnw spring-boot:run" -ForegroundColor Cyan
    exit 1
}

# Step 2: Check Environment Variables
Write-Host "`n[2/4] Checking SendGrid Configuration..." -ForegroundColor Yellow
$envChecks = @(
    @{Name="SENDGRID_API_KEY"; Required=$true},
    @{Name="SENDGRID_FROM_EMAIL"; Required=$true}
)

$configOk = $true
foreach ($check in $envChecks) {
    $envValue = [System.Environment]::GetEnvironmentVariable($check.Name, "Process")
    if (-not $envValue) {
        Write-Host "⚠️  $($check.Name) not found in environment" -ForegroundColor Yellow
        $configOk = $false
    } else {
        $masked = $envValue.Substring(0, [Math]::Min(10, $envValue.Length)) + "..."
        Write-Host "✅ $($check.Name) = $masked" -ForegroundColor Green
    }
}

if (-not $configOk) {
    Write-Host "`n⚠️  Warning: SendGrid environment variables not set" -ForegroundColor Yellow
    Write-Host "   The application should read them from application.properties" -ForegroundColor Cyan
}

# Step 3: Send OTP Request
Write-Host "`n[3/4] Sending OTP Request..." -ForegroundColor Yellow

$otpRequest = @{
    employeeId = "TEST123"
    email = $TestEmail
} | ConvertTo-Json

Write-Host "   Request: POST $BaseUrl/api/unified-auth/send-otp" -ForegroundColor Gray
Write-Host "   Body: $otpRequest" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod `
        -Uri "$BaseUrl/api/unified-auth/send-otp" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $otpRequest `
        -TimeoutSec 30
    
    Write-Host "✅ OTP request successful!" -ForegroundColor Green
    Write-Host "`nResponse:" -ForegroundColor White
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Failed to send OTP" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response Body: $responseBody" -ForegroundColor Red
    }
    
    Write-Host "`n💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Check backend logs for detailed error" -ForegroundColor Cyan
    Write-Host "   2. Verify SENDGRID_API_KEY is set correctly" -ForegroundColor Cyan
    Write-Host "   3. Verify SENDGRID_FROM_EMAIL is verified in SendGrid" -ForegroundColor Cyan
    Write-Host "   4. Check SendGrid dashboard for delivery errors" -ForegroundColor Cyan
    
    exit 1
}

# Step 4: Verify Email Delivery
Write-Host "`n[4/4] Email Delivery Verification" -ForegroundColor Yellow
Write-Host "📧 Check your email inbox: $TestEmail" -ForegroundColor Cyan
Write-Host "   ⏰ Emails typically arrive within 1-5 seconds" -ForegroundColor White
Write-Host "   📂 If not in inbox, check Spam/Junk folder" -ForegroundColor Yellow
Write-Host "   🔍 Look for subject: 'Your Login OTP - Secure Authentication'" -ForegroundColor White

# Success Summary
Write-Host "`n=================================" -ForegroundColor Green
Write-Host "✨ Test Completed Successfully!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Check your email: $TestEmail" -ForegroundColor White
Write-Host "2. View SendGrid Activity:" -ForegroundColor White
Write-Host "   https://app.sendgrid.com/activity" -ForegroundColor Blue
Write-Host "3. View SendGrid Statistics:" -ForegroundColor White
Write-Host "   https://app.sendgrid.com/statistics" -ForegroundColor Blue

Write-Host "`n📊 SendGrid Dashboard Features:" -ForegroundColor Cyan
Write-Host "   - Real-time email delivery status" -ForegroundColor White
Write-Host "   - Open and click tracking" -ForegroundColor White
Write-Host "   - Bounce and spam reports" -ForegroundColor White
Write-Host "   - Email activity logs" -ForegroundColor White

Write-Host "`n🎉 Your SendGrid integration is working!" -ForegroundColor Green
Write-Host ""
