# Debug Render Login Issue
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Debugging Render Login 400 Error" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://omoiservespare-backend.onrender.com"

Write-Host "Test 1: Health Check" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/api/auth/health" -Method GET
    Write-Host "✅ Health check passed: $health" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 2: Check Mock HR Data" -ForegroundColor Yellow
try {
    $hrData = Invoke-RestMethod -Uri "$baseUrl/api/hr/mock/data" -Method GET
    Write-Host "✅ HR Mock data loaded" -ForegroundColor Green
    Write-Host "Companies available:" -ForegroundColor Cyan
    $hrData.companies | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
} catch {
    Write-Host "⚠️  Could not fetch HR data (may not be exposed): $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Test 3: Login with EXACT company name from mock data" -ForegroundColor Yellow
Write-Host "Using: 'Omoiservespare Pvt Ltd'" -ForegroundColor Gray

$loginBody = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "niketa.j@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Write-Host ""
Write-Host "Request Body:" -ForegroundColor Cyan
Write-Host $loginBody -ForegroundColor White

try {
    $response = Invoke-RestMethod `
        -Uri "$baseUrl/api/auth/user/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host ""
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
    
} catch {
    Write-Host ""
    Write-Host "❌ Login failed with 400 Bad Request" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error Details:" -ForegroundColor Yellow
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor White
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor White
    
    if ($_.ErrorDetails.Message) {
        Write-Host ""
        Write-Host "Server Response:" -ForegroundColor Yellow
        try {
            $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
            $errorResponse | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
        } catch {
            Write-Host $_.ErrorDetails.Message -ForegroundColor White
        }
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Possible Issues:" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Company name mismatch" -ForegroundColor Yellow
Write-Host "   Mock HR has: 'Omoiservespare Pvt Ltd'" -ForegroundColor White
Write-Host "   You sent: Check if exact match" -ForegroundColor White
Write-Host ""
Write-Host "2. Email not in mock HR database" -ForegroundColor Yellow
Write-Host "   niketa.j@omoikaneinnovations.com must exist in MockHRDataService" -ForegroundColor White
Write-Host ""
Write-Host "3. Validation error" -ForegroundColor Yellow
Write-Host "   Email format or company name blank" -ForegroundColor White
Write-Host ""
Write-Host "Next: Check Render logs for actual error message" -ForegroundColor Cyan
Write-Host "Go to: https://dashboard.render.com/" -ForegroundColor White
Write-Host "Look for: 'User/Admin login failed:'" -ForegroundColor White
Write-Host ""
