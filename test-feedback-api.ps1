Write-Host "=== Testing Feedback API ===" -ForegroundColor Cyan

# Step 1: Login to get token
Write-Host "`n1. Logging in to get auth token..." -ForegroundColor Yellow
$loginBody = @{
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    $token = $loginResponse.token
    Write-Host "✓ Login successful! Token: $($token.Substring(0, 20))..." -ForegroundColor Green
} catch {
    Write-Host "✗ Login failed. Please create a test user first." -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nTo create a test user, signup first or use an existing user." -ForegroundColor Yellow
    exit
}

# Step 2: Submit feedback
Write-Host "`n2. Submitting feedback..." -ForegroundColor Yellow
$feedbackBody = @{
    rating = 5
    comments = "This is a test feedback from PowerShell script"
} | ConvertTo-Json

Write-Host "Request body: $feedbackBody" -ForegroundColor Gray

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $feedbackResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/feedback" `
        -Method POST `
        -Headers $headers `
        -Body $feedbackBody `
        -ErrorAction Stop
    
    Write-Host "✓ Feedback submitted successfully!" -ForegroundColor Green
    Write-Host "Feedback ID: $($feedbackResponse.id)" -ForegroundColor Green
    Write-Host "Rating: $($feedbackResponse.rating)" -ForegroundColor Green
    Write-Host "Comments: $($feedbackResponse.comments)" -ForegroundColor Green
    Write-Host "Status: $($feedbackResponse.status)" -ForegroundColor Green
} catch {
    Write-Host "✗ Feedback submission failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}

# Step 3: Verify in database
Write-Host "`n3. Checking database..." -ForegroundColor Yellow
Write-Host "Run this SQL query to verify:" -ForegroundColor White
Write-Host "SELECT * FROM feedback ORDER BY created_at DESC LIMIT 5;" -ForegroundColor Cyan

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
