# Step-by-Step Admin Dashboard Test
# Run this in PowerShell (not as Administrator needed)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Admin Dashboard Backend Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if backend is running
Write-Host "[STEP 1] Checking if backend is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Backend is running!" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is NOT running on port 8080" -ForegroundColor Red
    Write-Host "Please start backend with: mvn spring-boot:run" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

# Step 2: Get login credentials
Write-Host ""
Write-Host "[STEP 2] Login to get JWT token" -ForegroundColor Yellow
Write-Host "Enter your credentials:" -ForegroundColor Cyan
$email = Read-Host "Email"
$password = Read-Host "Password" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Step 3: Login
Write-Host ""
Write-Host "[STEP 3] Logging in..." -ForegroundColor Yellow

$loginBody = @{
    email = $email
    password = $passwordPlain
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    
    if ($loginResponse.token) {
        Write-Host "✅ Login successful!" -ForegroundColor Green
        $token = $loginResponse.token
        Write-Host "Token: $($token.Substring(0, 50))..." -ForegroundColor Gray
    } else {
        Write-Host "❌ Login failed: No token received" -ForegroundColor Red
        exit
    }
} catch {
    Write-Host "❌ Login failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "Hint: Check your email and password" -ForegroundColor Yellow
    } elseif ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "Hint: Invalid credentials" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

# Step 4: Test dashboard API
Write-Host ""
Write-Host "[STEP 4] Testing Admin Dashboard API..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $dashboard = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" -Method GET -Headers $headers -ErrorAction Stop
    
    Write-Host "✅ Dashboard API works!" -ForegroundColor Green
    Write-Host ""
    
    # Display results
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Dashboard Data" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    if ($dashboard.kpis) {
        Write-Host ""
        Write-Host "📊 KPIs:" -ForegroundColor Yellow
        Write-Host "   Today Revenue:  ₹$($dashboard.kpis.todayRevenue)" -ForegroundColor White
        Write-Host "   Total Revenue:  ₹$($dashboard.kpis.totalRevenue)" -ForegroundColor White
        Write-Host "   Total Orders:   $($dashboard.kpis.totalOrders)" -ForegroundColor White
        Write-Host "   Customers:      $($dashboard.kpis.customers)" -ForegroundColor White
        Write-Host "   Growth:         $($dashboard.kpis.todayRevenueGrowth)%" -ForegroundColor White
    }
    
    if ($dashboard.trendingItems -and $dashboard.trendingItems.Count -gt 0) {
        Write-Host ""
        Write-Host "🔥 Trending Items:" -ForegroundColor Yellow
        for ($i = 0; $i -lt [Math]::Min(3, $dashboard.trendingItems.Count); $i++) {
            $item = $dashboard.trendingItems[$i]
            Write-Host "   $($i+1). $($item.name) - ₹$($item.revenue) ($($item.quantitySold) sold)" -ForegroundColor White
        }
    }
    
    if ($dashboard.revenueSeries) {
        Write-Host ""
        Write-Host "📈 Revenue Series:" -ForegroundColor Yellow
        Write-Host "   Data points: $($dashboard.revenueSeries.Count)" -ForegroundColor White
    }
    
    if ($dashboard.topSoldToday) {
        Write-Host ""
        Write-Host "⭐ Top Sold Today:" -ForegroundColor Yellow
        foreach ($item in $dashboard.topSoldToday | Select-Object -First 3) {
            Write-Host "   - $($item.name): $($item.qty) units" -ForegroundColor White
        }
    }
    
    if ($dashboard.categoryDistribution) {
        Write-Host ""
        Write-Host "🍽️ Category Distribution:" -ForegroundColor Yellow
        foreach ($cat in $dashboard.categoryDistribution) {
            Write-Host "   - $($cat.category): $($cat.count) items ($([Math]::Round($cat.percentage, 1))%)" -ForegroundColor White
        }
    }
    
    if ($dashboard.sessions) {
        Write-Host ""
        Write-Host "👥 Sessions:" -ForegroundColor Yellow
        Write-Host "   Total: $($dashboard.sessions.totalSessions)" -ForegroundColor White
        Write-Host "   Live:  $($dashboard.sessions.liveVisitors)" -ForegroundColor White
    }
    
    if ($dashboard.insights -and $dashboard.insights.Count -gt 0) {
        Write-Host ""
        Write-Host "💡 Insights:" -ForegroundColor Yellow
        foreach ($insight in $dashboard.insights) {
            Write-Host "   - $insight" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "✅ All tests passed!" -ForegroundColor Green
    Write-Host "Backend is working correctly!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Dashboard API failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "Hint: Token expired or invalid" -ForegroundColor Yellow
    } elseif ($_.Exception.Response.StatusCode -eq 500) {
        Write-Host "Hint: Backend error - check backend logs" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Press Enter to exit..."
$null = Read-Host
