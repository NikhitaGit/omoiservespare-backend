# Feedback Real-time Diagnostic Script
Write-Host "=== FEEDBACK SYSTEM DIAGNOSTIC ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if backend is running
Write-Host "1. Checking backend status..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/canteens" -Method GET -UseBasicParsing
    Write-Host "   ✓ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend is NOT running on port 8080" -ForegroundColor Red
    Write-Host "   Please start the backend first: mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 2: Login as PROFESSIONAL user
Write-Host "2. Testing login as PROFESSIONAL user..." -ForegroundColor Yellow
$loginBody = @{
    email = "admin@omoikaneinnovations.com"
    deviceId = "test-device-123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/send-otp" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody
    
    Write-Host "   ✓ OTP sent successfully" -ForegroundColor Green
    Write-Host "   Check backend logs for OTP code" -ForegroundColor Cyan
} catch {
    Write-Host "   ✗ Failed to send OTP: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Step 3: Check database for existing feedback
Write-Host "3. Checking database for feedback records..." -ForegroundColor Yellow
Write-Host "   Run this SQL query in your PostgreSQL:" -ForegroundColor Cyan
Write-Host "   SELECT id, user_id, company_name, rating, status, created_at FROM feedback ORDER BY created_at DESC LIMIT 10;" -ForegroundColor White

Write-Host ""

# Step 4: Test feedback submission (requires token)
Write-Host "4. To test feedback submission:" -ForegroundColor Yellow
Write-Host "   a) Login to your frontend" -ForegroundColor Cyan
Write-Host "   b) Open browser console (F12)" -ForegroundColor Cyan
Write-Host "   c) Check localStorage for 'token' or 'authToken'" -ForegroundColor Cyan
Write-Host "   d) Submit feedback through the UI" -ForegroundColor Cyan
Write-Host "   e) Check Network tab for API response" -ForegroundColor Cyan

Write-Host ""

# Step 5: Common issues
Write-Host "5. Common Issues & Solutions:" -ForegroundColor Yellow
Write-Host "   Issue: 'Failed to load feedback'" -ForegroundColor Red
Write-Host "   Solution: User must be PROFESSIONAL account type" -ForegroundColor Green
Write-Host ""
Write-Host "   Issue: 401 Unauthorized" -ForegroundColor Red
Write-Host "   Solution: Check token in localStorage matches key in frontend code" -ForegroundColor Green
Write-Host ""
Write-Host "   Issue: 403 Forbidden" -ForegroundColor Red
Write-Host "   Solution: Only PROFESSIONAL users can view feedback dashboard" -ForegroundColor Green
Write-Host ""
Write-Host "   Issue: Feedback not saving" -ForegroundColor Red
Write-Host "   Solution: Check backend logs for errors, verify database connection" -ForegroundColor Green

Write-Host ""
Write-Host "=== DIAGNOSTIC COMPLETE ===" -ForegroundColor Cyan
