Write-Host "=== Complete Feedback Flow Verification ===" -ForegroundColor Cyan

# Configuration
$email = Read-Host "Enter your test user email (e.g., test@example.com)"
$password = Read-Host "Enter password" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

Write-Host "`n=== Step 1: Login ===" -ForegroundColor Yellow
$loginBody = @{
    email = $email
    password = $passwordPlain
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    $token = $loginResponse.token
    Write-Host "✓ Login successful!" -ForegroundColor Green
    Write-Host "User: $email" -ForegroundColor White
    Write-Host "Token: $($token.Substring(0, 30))..." -ForegroundColor Gray
} catch {
    Write-Host "✗ Login failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit
}

Write-Host "`n=== Step 2: Submit Feedback ===" -ForegroundColor Yellow
$feedbackBody = @{
    rating = 5
    comments = "Test feedback submitted at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
} | ConvertTo-Json

Write-Host "Payload: $feedbackBody" -ForegroundColor Gray

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
    Write-Host "Feedback ID: $($feedbackResponse.id)" -ForegroundColor White
    Write-Host "Rating: $($feedbackResponse.rating)" -ForegroundColor White
    Write-Host "Comments: $($feedbackResponse.comments)" -ForegroundColor White
    Write-Host "Status: $($feedbackResponse.status)" -ForegroundColor White
    Write-Host "Company: $($feedbackResponse.companyName)" -ForegroundColor White
    
    $feedbackId = $feedbackResponse.id
} catch {
    Write-Host "✗ Feedback submission failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
    exit
}

Write-Host "`n=== Step 3: Retrieve Feedback List ===" -ForegroundColor Yellow
try {
    $feedbackList = Invoke-RestMethod -Uri "http://localhost:8080/api/feedback" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "✓ Retrieved feedback list!" -ForegroundColor Green
    Write-Host "Total feedback count: $($feedbackList.totalElements)" -ForegroundColor White
    Write-Host "Current page size: $($feedbackList.content.Count)" -ForegroundColor White
    
    if ($feedbackList.content.Count -gt 0) {
        Write-Host "`nLatest feedback entries:" -ForegroundColor Cyan
        $feedbackList.content | Select-Object -First 5 | ForEach-Object {
            Write-Host "  ID: $($_.id) | Rating: $($_.rating) | Status: $($_.status) | Date: $($_.createdAt)" -ForegroundColor White
        }
        
        # Check if our submitted feedback is in the list
        $ourFeedback = $feedbackList.content | Where-Object { $_.id -eq $feedbackId }
        if ($ourFeedback) {
            Write-Host "`n✓ Our submitted feedback (ID: $feedbackId) is in the list!" -ForegroundColor Green
        } else {
            Write-Host "`n✗ Our submitted feedback (ID: $feedbackId) is NOT in the list!" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ No feedback found in the list!" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to retrieve feedback list!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 403) {
            Write-Host "`nNote: You need PROFESSIONAL account type to view feedback list" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Step 4: Test CSV Export ===" -ForegroundColor Yellow
try {
    $csvResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/feedback/export/csv" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "✓ CSV export successful!" -ForegroundColor Green
    Write-Host "File size: $($csvResponse.Content.Length) bytes" -ForegroundColor White
    
    # Save to file
    $csvPath = "feedback_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    [System.IO.File]::WriteAllBytes($csvPath, $csvResponse.Content)
    Write-Host "Saved to: $csvPath" -ForegroundColor Green
    
    # Show first few lines
    $csvContent = [System.Text.Encoding]::UTF8.GetString($csvResponse.Content)
    $lines = $csvContent -split "`n" | Select-Object -First 5
    Write-Host "`nCSV Preview:" -ForegroundColor Cyan
    $lines | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
} catch {
    Write-Host "✗ CSV export failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== Step 5: Test Excel Export ===" -ForegroundColor Yellow
try {
    $excelResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/feedback/export/excel" `
        -Method GET `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "✓ Excel export successful!" -ForegroundColor Green
    Write-Host "File size: $($excelResponse.Content.Length) bytes" -ForegroundColor White
    
    # Save to file
    $excelPath = "feedback_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').xlsx"
    [System.IO.File]::WriteAllBytes($excelPath, $excelResponse.Content)
    Write-Host "Saved to: $excelPath" -ForegroundColor Green
} catch {
    Write-Host "✗ Excel export failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "1. Login: ✓" -ForegroundColor Green
Write-Host "2. Submit Feedback: ✓" -ForegroundColor Green
Write-Host "3. Retrieve List: Check above" -ForegroundColor Yellow
Write-Host "4. CSV Export: Check above" -ForegroundColor Yellow
Write-Host "5. Excel Export: Check above" -ForegroundColor Yellow

Write-Host "`n=== Database Check ===" -ForegroundColor Cyan
Write-Host "Run this SQL query to verify in database:" -ForegroundColor White
Write-Host "SELECT * FROM feedback WHERE id = $feedbackId;" -ForegroundColor Cyan
Write-Host "`nOr check all recent feedback:" -ForegroundColor White
Write-Host "SELECT * FROM feedback ORDER BY created_at DESC LIMIT 10;" -ForegroundColor Cyan

Write-Host "`n=== Important Notes ===" -ForegroundColor Yellow
Write-Host "- To VIEW feedback list, you need PROFESSIONAL account type" -ForegroundColor White
Write-Host "- Regular users can SUBMIT feedback but cannot VIEW the list" -ForegroundColor White
Write-Host "- Check your user's account_type in the database" -ForegroundColor White
