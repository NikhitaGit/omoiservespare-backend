# Test script for Company Feedback System
# This script tests the complete feedback flow including submission, retrieval, and export

$baseUrl = "http://localhost:8080"
$frontendUrl = "http://localhost:5173"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Company Feedback System Test Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Submit feedback as regular user
Write-Host "Test 1: Submit Feedback (Regular User)" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
Write-Host "Please provide a JWT token for a regular user:"
$userToken = Read-Host "JWT Token"

$feedbackData = @{
    rating = 5
    comments = "Great application! Very user-friendly and efficient."
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/feedback" `
        -Method Post `
        -Headers @{
            "Authorization" = "Bearer $userToken"
            "Content-Type" = "application/json"
        } `
        -Body $feedbackData
    
    Write-Host "✓ Feedback submitted successfully!" -ForegroundColor Green
    Write-Host "  Feedback ID: $($response.id)" -ForegroundColor Green
    Write-Host "  Rating: $($response.rating)" -ForegroundColor Green
    Write-Host "  Status: $($response.status)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Failed to submit feedback" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 2: Get feedback list as PROFESSIONAL user
Write-Host "Test 2: Get Feedback List (PROFESSIONAL User)" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
Write-Host "Please provide a JWT token for a PROFESSIONAL user:"
$adminToken = Read-Host "JWT Token"

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/feedback?page=0&size=10" `
        -Method Get `
        -Headers @{
            "Authorization" = "Bearer $adminToken"
        }
    
    Write-Host "✓ Feedback retrieved successfully!" -ForegroundColor Green
    Write-Host "  Total feedback: $($response.totalElements)" -ForegroundColor Green
    Write-Host "  Page size: $($response.size)" -ForegroundColor Green
    Write-Host "  Current page: $($response.number)" -ForegroundColor Green
    
    if ($response.content.Count -gt 0) {
        Write-Host "  First feedback:" -ForegroundColor Green
        Write-Host "    ID: $($response.content[0].id)" -ForegroundColor Green
        Write-Host "    Rating: $($response.content[0].rating)" -ForegroundColor Green
        Write-Host "    Status: $($response.content[0].status)" -ForegroundColor Green
    }
    Write-Host ""
} catch {
    Write-Host "✗ Failed to retrieve feedback" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 3: Test access control (PERSONAL user trying to access admin endpoint)
Write-Host "Test 3: Access Control Test (PERSONAL User)" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/feedback" `
        -Method Get `
        -Headers @{
            "Authorization" = "Bearer $userToken"
        }
    
    Write-Host "✗ Access control failed - PERSONAL user should not access this endpoint" -ForegroundColor Red
    Write-Host ""
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "✓ Access control working correctly - 403 Forbidden" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "✗ Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test 4: Mark feedback as reviewed
Write-Host "Test 4: Mark Feedback as Reviewed" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
Write-Host "Enter feedback ID to mark as reviewed:"
$feedbackId = Read-Host "Feedback ID"

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/feedback/$feedbackId/review" `
        -Method Put `
        -Headers @{
            "Authorization" = "Bearer $adminToken"
        }
    
    Write-Host "✓ Feedback marked as reviewed!" -ForegroundColor Green
    Write-Host "  Status: $($response.status)" -ForegroundColor Green
    Write-Host "  Reviewed At: $($response.reviewedAt)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Failed to mark as reviewed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 5: Export to CSV
Write-Host "Test 5: Export to CSV" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow

try {
    $csvFile = "feedback_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    Invoke-RestMethod -Uri "$baseUrl/api/feedback/export/csv" `
        -Method Get `
        -Headers @{
            "Authorization" = "Bearer $adminToken"
        } `
        -OutFile $csvFile
    
    Write-Host "✓ CSV exported successfully!" -ForegroundColor Green
    Write-Host "  File: $csvFile" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Failed to export CSV" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 6: Export to Excel
Write-Host "Test 6: Export to Excel" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow

try {
    $excelFile = "feedback_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').xlsx"
    Invoke-RestMethod -Uri "$baseUrl/api/feedback/export/excel" `
        -Method Get `
        -Headers @{
            "Authorization" = "Bearer $adminToken"
        } `
        -OutFile $excelFile
    
    Write-Host "✓ Excel exported successfully!" -ForegroundColor Green
    Write-Host "  File: $excelFile" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Failed to export Excel" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 7: Filter by status
Write-Host "Test 7: Filter Feedback by Status" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/feedback?status=NEW&page=0&size=10" `
        -Method Get `
        -Headers @{
            "Authorization" = "Bearer $adminToken"
        }
    
    Write-Host "✓ Filtered feedback retrieved (NEW status)!" -ForegroundColor Green
    Write-Host "  Total NEW feedback: $($response.totalElements)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Failed to filter feedback" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Script Completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Check the exported CSV and Excel files" -ForegroundColor White
Write-Host "2. Test the frontend integration at $frontendUrl" -ForegroundColor White
Write-Host "3. Verify multi-tenant data isolation" -ForegroundColor White
Write-Host ""
