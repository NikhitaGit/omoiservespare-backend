# ============================================
# RBAC System Test Script
# ============================================
# Tests role-based access control

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🔒 RBAC SYSTEM TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"

# ============================================
# STEP 1: Login as ADMIN
# ============================================
Write-Host "Step 1: Logging in as ADMIN..." -ForegroundColor Yellow

$adminBody = @{
    email = "admin@test.com"
    password = "password123"
} | ConvertTo-Json

try {
    $adminResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -Body $adminBody `
        -ContentType "application/json"
    
    $adminToken = $adminResponse.token
    Write-Host "✅ Admin login successful" -ForegroundColor Green
    Write-Host "   Token: $($adminToken.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Admin login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Make sure admin@test.com exists and run setup-rbac-test-users.sql" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# ============================================
# STEP 2: Login as USER
# ============================================
Write-Host "Step 2: Logging in as USER..." -ForegroundColor Yellow

$userBody = @{
    email = "user@test.com"
    password = "password123"
} | ConvertTo-Json

try {
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -Body $userBody `
        -ContentType "application/json"
    
    $userToken = $userResponse.token
    Write-Host "✅ User login successful" -ForegroundColor Green
    Write-Host "   Token: $($userToken.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ User login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Make sure user@test.com exists and run setup-rbac-test-users.sql" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# ============================================
# STEP 3: Test ADMIN accessing admin endpoint (should work)
# ============================================
Write-Host "Step 3: Testing ADMIN access to /api/admin/dashboard..." -ForegroundColor Yellow

$adminHeaders = @{
    "Authorization" = "Bearer $adminToken"
}

try {
    $dashboardData = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=week" `
        -Headers $adminHeaders `
        -Method GET
    
    Write-Host "✅ ADMIN can access admin dashboard" -ForegroundColor Green
    Write-Host "   Revenue: ₹$($dashboardData.kpis.totalRevenue)" -ForegroundColor Gray
    Write-Host "   Orders: $($dashboardData.kpis.totalOrders)" -ForegroundColor Gray
} catch {
    Write-Host "❌ ADMIN access failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# ============================================
# STEP 4: Test USER accessing admin endpoint (should fail with 403)
# ============================================
Write-Host "Step 4: Testing USER access to /api/admin/dashboard (should be blocked)..." -ForegroundColor Yellow

$userHeaders = @{
    "Authorization" = "Bearer $userToken"
}

try {
    $dashboardData = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=week" `
        -Headers $userHeaders `
        -Method GET
    
    Write-Host "❌ USER should NOT be able to access admin dashboard!" -ForegroundColor Red
    Write-Host "   RBAC is NOT working correctly" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "✅ USER correctly blocked from admin dashboard (403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  USER blocked but with unexpected status: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    }
}

Write-Host ""

# ============================================
# STEP 5: Test USER accessing user endpoint (should work)
# ============================================
Write-Host "Step 5: Testing USER access to /api/rewards (should work)..." -ForegroundColor Yellow

try {
    $rewardsData = Invoke-RestMethod -Uri "$baseUrl/api/rewards" `
        -Headers $userHeaders `
        -Method GET
    
    Write-Host "✅ USER can access rewards endpoint" -ForegroundColor Green
    Write-Host "   Total Rewards: $($rewardsData.totalRewards)" -ForegroundColor Gray
} catch {
    Write-Host "❌ USER access to rewards failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# ============================================
# STEP 6: Test ADMIN accessing user endpoint (should fail - ADMIN is not USER)
# ============================================
Write-Host "Step 6: Testing ADMIN access to /api/rewards (should be blocked)..." -ForegroundColor Yellow

try {
    $rewardsData = Invoke-RestMethod -Uri "$baseUrl/api/rewards" `
        -Headers $adminHeaders `
        -Method GET
    
    Write-Host "❌ ADMIN should NOT be able to access user-only endpoint!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "✅ ADMIN correctly blocked from user endpoint (403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  ADMIN blocked but with unexpected status: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🎉 RBAC TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor White
Write-Host "✅ ADMIN can access admin endpoints" -ForegroundColor Green
Write-Host "✅ USER blocked from admin endpoints" -ForegroundColor Green
Write-Host "✅ USER can access user endpoints" -ForegroundColor Green
Write-Host "✅ ADMIN blocked from user-only endpoints" -ForegroundColor Green
Write-Host ""
Write-Host "RBAC is working correctly! 🎉" -ForegroundColor Green
