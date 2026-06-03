# Deploy to Render - Quick Script
# This script commits and pushes your Render deployment fixes

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Render Deployment - Final Fix" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Changes being committed:" -ForegroundColor Yellow
Write-Host "  ✓ RedisConfig.java - Made Redis optional" -ForegroundColor Green
Write-Host "  ✓ OmoiservespareApplication.java - Disabled Vault" -ForegroundColor Green
Write-Host "  ✓ application.properties - Updated config" -ForegroundColor Green
Write-Host ""

# Check git status
Write-Host "Checking git status..." -ForegroundColor Yellow
git status --short

Write-Host ""
$confirm = Read-Host "Do you want to commit and push these changes? (y/n)"

if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    Write-Host ""
    Write-Host "Staging files..." -ForegroundColor Yellow
    git add src/main/java/com/omoikaneinnovations/omoiservespare/config/RedisConfig.java
    git add src/main/java/com/omoikaneinnovations/omoiservespare/OmoiservespareApplication.java
    git add src/main/resources/application.properties
    
    Write-Host "Committing changes..." -ForegroundColor Yellow
    git commit -m "Fix: Disable Redis and Vault for Render deployment

- Made Redis optional with environment variables
- Disabled Vault autoconfiguration
- Cart falls back to in-memory storage
- Ready for Render deployment"
    
    Write-Host ""
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  ✓ Changes pushed successfully!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Go to your Render dashboard" -ForegroundColor White
    Write-Host "  2. Watch the build logs" -ForegroundColor White
    Write-Host "  3. Wait 5-10 minutes for deployment" -ForegroundColor White
    Write-Host "  4. Test: https://your-app.onrender.com/actuator/health" -ForegroundColor White
    Write-Host ""
    Write-Host "Expected result: " -ForegroundColor Cyan -NoNewline
    Write-Host '{"status":"UP"}' -ForegroundColor Green
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    Write-Host "Run this script again when ready to deploy." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "For more details, see:" -ForegroundColor Cyan
Write-Host "  - FINAL_RENDER_FIX.md" -ForegroundColor White
Write-Host "  - VAULT_FIX_FOR_RENDER.md" -ForegroundColor White
Write-Host "  - REDIS_FIX_SUMMARY.md" -ForegroundColor White
Write-Host ""
