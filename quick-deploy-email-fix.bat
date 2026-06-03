@echo off
echo ================================================
echo   Deploying Email Fix to Render
echo ================================================
echo.

git add src/main/java/com/omoikaneinnovations/omoiservespare/service/EmailService.java
git add src/main/java/com/omoikaneinnovations/omoiservespare/service/AuthService.java
git add src/main/java/com/omoikaneinnovations/omoiservespare/service/EmailTestService.java

git commit -m "Fix: Make email sending synchronous for production debugging - Removed @Async annotation - Fixed logger references - Enhanced SMTP diagnostics"

git push origin main

echo.
echo ================================================
echo   Deployed! Wait 5-10 minutes for Render rebuild
echo ================================================
echo.
echo Next: Run test-email-render.ps1 to test
echo.
pause
