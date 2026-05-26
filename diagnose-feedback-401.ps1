# Diagnostic Script for 401 Unauthorized Error

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Feedback 401 Error Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Check if backend is running" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/me" -Method Get -ErrorAction Stop
    Write-Host "✗ Backend requires authentication (expected)" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✓ Backend is running and requires authentication" -ForegroundColor Green
    } else {
        Write-Host "✗ Backend may not be running on port 8080" -ForegroundColor Red
        Write-Host "  Start backend with: mvnw spring-boot:run" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Step 2: Test with your JWT token" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
Write-Host "Please paste your JWT token (from browser localStorage):"
$token = Read-Host "Token"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "✗ No token provided" -ForegroundColor Red
    Write-Host ""
    Write-Host "To get your token:" -ForegroundColor Yellow
    Write-Host "1. Open browser DevTools (F12)" -ForegroundColor White
    Write-Host "2. Go to Console tab" -ForegroundColor White
    Write-Host "3. Run: localStorage.getItem('token')" -ForegroundColor White
    Write-Host "4. Copy the value (without quotes)" -ForegroundColor White
    exit
}

Write-Host ""
Write-Host "Testing API with your token..." -ForegroundColor Yellow

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/feedback?page=0&size=20" `
        -Method Get `
        -Headers $headers
    
    Write-Host "✓ SUCCESS! Feedback API is working" -ForegroundColor Green
    Write-Host ""
    Write-Host "Feedback data received:" -ForegroundColor Green
    Write-Host "  Total feedback: $($response.totalElements)" -ForegroundColor White
    Write-Host "  Total pages: $($response.totalPages)" -ForegroundColor White
    Write-Host "  Current page: $($response.number)" -ForegroundColor White
    Write-Host ""
    
    if ($response.content.Count -gt 0) {
        Write-Host "First feedback entry:" -ForegroundColor Green
        $first = $response.content[0]
        Write-Host "  ID: $($first.id)" -ForegroundColor White
        Write-Host "  User: $($first.userEmail)" -ForegroundColor White
        Write-Host "  Rating: $($first.rating)" -ForegroundColor White
        Write-Host "  Status: $($first.status)" -ForegroundColor White
        Write-Host "  Comments: $($first.comments)" -ForegroundColor White
    } else {
        Write-Host "No feedback entries found" -ForegroundColor Yellow
        Write-Host "Submit some feedback first!" -ForegroundColor Yellow
    }
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    if ($statusCode -eq 401) {
        Write-Host "✗ 401 Unauthorized - Token is invalid or expired" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solutions:" -ForegroundColor Yellow
        Write-Host "1. Login again to get a fresh token" -ForegroundColor White
        Write-Host "2. Check if token is complete (should start with 'eyJ')" -ForegroundColor White
        Write-Host "3. Verify you copied the entire token" -ForegroundColor White
    }
    elseif ($statusCode -eq 403) {
        Write-Host "✗ 403 Forbidden - User is not PROFESSIONAL" -ForegroundColor Red
        Write-Host ""
        Write-Host "Only PROFESSIONAL account types can view feedback" -ForegroundColor Yellow
        Write-Host "Your account type may be PERSONAL" -ForegroundColor Yellow
    }
    else {
        Write-Host "✗ Error: $statusCode" -ForegroundColor Red
        Write-Host "  Message: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnostic Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
