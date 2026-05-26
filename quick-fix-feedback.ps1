Write-Host "=== Quick Fix for Feedback Access ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "The issue: Only PROFESSIONAL users can view feedback." -ForegroundColor Yellow
Write-Host "Solution: Change your account type to PROFESSIONAL" -ForegroundColor Yellow
Write-Host ""

$email = Read-Host "Enter your email address"

Write-Host ""
Write-Host "=== SQL Command to Run ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copy and paste this into your PostgreSQL client (psql, pgAdmin, DBeaver):" -ForegroundColor White
Write-Host ""
Write-Host "-- Connect to database" -ForegroundColor Gray
Write-Host "-- psql -U postgres -d omoiservespare_db" -ForegroundColor Gray
Write-Host ""
Write-Host "-- Check current account type" -ForegroundColor Green
Write-Host "SELECT email, account_type, company_name FROM users WHERE email = '$email';" -ForegroundColor Cyan
Write-Host ""
Write-Host "-- Change to PROFESSIONAL" -ForegroundColor Green
Write-Host "UPDATE users SET account_type = 'PROFESSIONAL' WHERE email = '$email';" -ForegroundColor Cyan
Write-Host ""
Write-Host "-- Verify the change" -ForegroundColor Green
Write-Host "SELECT email, account_type, company_name FROM users WHERE email = '$email';" -ForegroundColor Cyan
Write-Host ""
Write-Host "-- Check if feedback exists" -ForegroundColor Green
Write-Host "SELECT * FROM feedback ORDER BY created_at DESC LIMIT 5;" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== After Running SQL ===" -ForegroundColor Yellow
Write-Host "1. Logout from your app" -ForegroundColor White
Write-Host "2. Login again (to get new token with PROFESSIONAL role)" -ForegroundColor White
Write-Host "3. Navigate to admin feedback page" -ForegroundColor White
Write-Host "4. You should now see all feedback!" -ForegroundColor White
Write-Host ""

Write-Host "=== Alternative: Test with PowerShell ===" -ForegroundColor Yellow
Write-Host "After changing account type, run:" -ForegroundColor White
Write-Host ".\verify-feedback-flow.ps1" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== Need Help? ===" -ForegroundColor Yellow
Write-Host "Read: FEEDBACK_COMPLETE_SOLUTION.md" -ForegroundColor White
