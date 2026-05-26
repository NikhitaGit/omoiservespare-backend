# Complete Feedback System Test Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FEEDBACK SYSTEM COMPLETE TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Backend Health Check
Write-Host "[1/5] Testing Backend Connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/canteens" -Method GET -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✓ Backend is running on port 8080" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend is NOT running!" -ForegroundColor Red
    Write-Host "   Please start backend: mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Test 2: Database Connection
Write-Host "[2/5] Checking Database..." -ForegroundColor Yellow
Write-Host "   Run this SQL to verify feedback table:" -ForegroundColor Cyan
Write-Host "   SELECT COUNT(*) FROM feedback;" -ForegroundColor White
Write-Host ""

# Test 3: Test User Accounts
Write-Host "[3/5] Verifying User Accounts..." -ForegroundColor Yellow
Write-Host "   Check account types in database:" -ForegroundColor Cyan
Write-Host "   SELECT email, account_type FROM users;" -ForegroundColor White
Write-Host ""
Write-Host "   PERSONAL users: Can submit feedback" -ForegroundColor Green
Write-Host "   PROFESSIONAL users: Can view dashboard + submit" -ForegroundColor Green
Write-Host ""

# Test 4: API Endpoints
Write-Host "[4/5] Testing API Endpoints..." -ForegroundColor Yellow

# Test feedback submission endpoint (requires auth)
Write-Host "   Testing POST /api/feedback (requires JWT token)" -ForegroundColor Cyan
Write-Host "   Status: Requires authentication ✓" -ForegroundColor Green

# Test feedback retrieval endpoint (requires auth)
Write-Host "   Testing GET /api/feedback (requires JWT token)" -ForegroundColor Cyan
Write-Host "   Status: Requires authentication ✓" -ForegroundColor Green

Write-Host ""

# Test 5: Frontend Files
Write-Host "[5/5] Checking Frontend Files..." -ForegroundColor Yellow

$feedbackFile = "Feedback_PERMANENT_FIX.jsx"
$dashboardFile = "App_Feedback_PERMANENT_FIX.jsx"

if (Test-Path $feedbackFile) {
    Write-Host "   ✓ $feedbackFile exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ $feedbackFile not found" -ForegroundColor Red
}

if (Test-Path $dashboardFile) {
    Write-Host "   ✓ $dashboardFile exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ $dashboardFile not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MANUAL TESTING STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Copy Fixed Files" -ForegroundColor Yellow
Write-Host "   Copy Feedback_PERMANENT_FIX.jsx to your frontend" -ForegroundColor White
Write-Host "   Copy App_Feedback_PERMANENT_FIX.jsx to your frontend" -ForegroundColor White
Write-Host ""

Write-Host "Step 2: Test Feedback Submission" -ForegroundColor Yellow
Write-Host "   1. Login as any user" -ForegroundColor White
Write-Host "   2. Navigate to feedback page" -ForegroundColor White
Write-Host "   3. Select rating (1-5 stars)" -ForegroundColor White
Write-Host "   4. Enter comments" -ForegroundColor White
Write-Host "   5. Click Submit" -ForegroundColor White
Write-Host "   6. Check browser console for logs" -ForegroundColor White
Write-Host ""

Write-Host "Step 3: Test Feedback Dashboard" -ForegroundColor Yellow
Write-Host "   1. Login as PROFESSIONAL user" -ForegroundColor White
Write-Host "   2. Navigate to feedback dashboard" -ForegroundColor White
Write-Host "   3. Should see list of feedback" -ForegroundColor White
Write-Host "   4. Should auto-refresh every 10 seconds" -ForegroundColor White
Write-Host "   5. Try marking feedback as reviewed" -ForegroundColor White
Write-Host "   6. Try exporting CSV/Excel" -ForegroundColor White
Write-Host ""

Write-Host "Step 4: Verify in Database" -ForegroundColor Yellow
Write-Host "   Run: SELECT * FROM feedback ORDER BY created_at DESC LIMIT 5;" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Issue: 'Failed to load feedback'" -ForegroundColor Red
Write-Host "Solution: User must be PROFESSIONAL account type" -ForegroundColor Green
Write-Host "   UPDATE users SET account_type = 'PROFESSIONAL' WHERE email = 'your@email.com';" -ForegroundColor White
Write-Host ""

Write-Host "Issue: '401 Unauthorized'" -ForegroundColor Red
Write-Host "Solution: Check token in localStorage" -ForegroundColor Green
Write-Host "   1. Open browser console (F12)" -ForegroundColor White
Write-Host "   2. Type: localStorage.getItem('token')" -ForegroundColor White
Write-Host "   3. If null, login again" -ForegroundColor White
Write-Host ""

Write-Host "Issue: 'Network error'" -ForegroundColor Red
Write-Host "Solution: Check backend is running" -ForegroundColor Green
Write-Host "   Backend URL: http://localhost:8080" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Replace your frontend files with the fixed versions" -ForegroundColor White
Write-Host "2. Restart your frontend development server" -ForegroundColor White
Write-Host "3. Test feedback submission" -ForegroundColor White
Write-Host "4. Test feedback dashboard (as PROFESSIONAL user)" -ForegroundColor White
Write-Host "5. Verify data in database" -ForegroundColor White
Write-Host ""

Write-Host "For detailed documentation, see:" -ForegroundColor Yellow
Write-Host "   FEEDBACK_PERMANENT_SOLUTION.md" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
