# Test Rewards API Endpoints
# Make sure the application is running on port 8080

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Rewards API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if application is running
Write-Host "[1/4] Checking if application is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/test/health" -Method GET -ErrorAction SilentlyContinue -TimeoutSec 2
    Write-Host "Application is running on port 8080" -ForegroundColor Green
} catch {
    # Try alternative check
    $port = netstat -ano | findstr ":8080"
    if ($port) {
        Write-Host "Application appears to be running on port 8080" -ForegroundColor Green
    } else {
        Write-Host "Application is not running. Please start it first." -ForegroundColor Red
        Write-Host "Run: mvn spring-boot:run" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "[2/4] Testing GET /api/rewards (All Rewards)" -ForegroundColor Yellow
Write-Host "Note: This requires authentication. You'll need a valid JWT token." -ForegroundColor Gray
Write-Host ""
Write-Host "Example curl command:" -ForegroundColor Cyan
Write-Host 'curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/api/rewards' -ForegroundColor White
Write-Host ""

Write-Host "[3/4] Testing GET /api/rewards/my-rewards (User Rewards)" -ForegroundColor Yellow
Write-Host "Example curl command:" -ForegroundColor Cyan
Write-Host 'curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/api/rewards/my-rewards' -ForegroundColor White
Write-Host ""

Write-Host "[4/4] Testing GET /api/rewards/progress (User Progress)" -ForegroundColor Yellow
Write-Host "Example curl command:" -ForegroundColor Cyan
Write-Host 'curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/api/rewards/progress' -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Kafka Event Flow Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test the complete reward flow:" -ForegroundColor Yellow
Write-Host "1. Place an order through your app" -ForegroundColor White
Write-Host "2. Update order status to DELIVERED" -ForegroundColor White
Write-Host "3. Check application logs for:" -ForegroundColor White
Write-Host "   - Published ORDER_COMPLETED event" -ForegroundColor Gray
Write-Host "   - Processing order completed event" -ForegroundColor Gray
Write-Host "   - Reward unlocked for user" -ForegroundColor Gray
Write-Host "4. Call /api/rewards/my-rewards to see unlocked rewards" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Database Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Connect to PostgreSQL and run:" -ForegroundColor Yellow
Write-Host "SELECT * FROM reward_rules;" -ForegroundColor White
Write-Host "SELECT * FROM user_reward_progress;" -ForegroundColor White
Write-Host "SELECT * FROM user_rewards;" -ForegroundColor White
Write-Host ""

Write-Host "Rewards system is ready!" -ForegroundColor Green
Write-Host ""
