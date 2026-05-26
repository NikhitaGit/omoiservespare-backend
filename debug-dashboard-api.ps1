# Debug Dashboard API Response
# This will show exactly what the backend is returning

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Debug Dashboard API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"

# Step 1: Login
Write-Host "[STEP 1] Login" -ForegroundColor Yellow
$email = Read-Host "Email"
$password = Read-Host "Password" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

$loginBody = @{
    email = $email
    password = $passwordPlain
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ Login successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
}

# Step 2: Call dashboard API
Write-Host ""
Write-Host "[STEP 2] Calling Dashboard API" -ForegroundColor Yellow
Write-Host "URL: $baseUrl/api/admin/dashboard?range=week" -ForegroundColor Gray

try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=week" -Headers $headers
    
    Write-Host "✅ API call successful" -ForegroundColor Green
    Write-Host ""
    
    # Display full response
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Full API Response" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ($dashboard | ConvertTo-Json -Depth 5) -ForegroundColor White
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Parsed Data" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    if ($dashboard.kpis) {
        Write-Host ""
        Write-Host "KPIs:" -ForegroundColor Yellow
        Write-Host "  todayRevenue: $($dashboard.kpis.todayRevenue)" -ForegroundColor White
        Write-Host "  totalRevenue: $($dashboard.kpis.totalRevenue)" -ForegroundColor White
        Write-Host "  totalOrders: $($dashboard.kpis.totalOrders)" -ForegroundColor White
        Write-Host "  customers: $($dashboard.kpis.customers)" -ForegroundColor White
        Write-Host "  todayRevenueGrowth: $($dashboard.kpis.todayRevenueGrowth)" -ForegroundColor White
    } else {
        Write-Host "❌ No KPIs in response" -ForegroundColor Red
    }
    
    if ($dashboard.trendingItems) {
        Write-Host ""
        Write-Host "Trending Items: $($dashboard.trendingItems.Count)" -ForegroundColor Yellow
        foreach ($item in $dashboard.trendingItems | Select-Object -First 3) {
            Write-Host "  - $($item.name): ₹$($item.revenue) ($($item.quantitySold) sold)" -ForegroundColor White
        }
    } else {
        Write-Host "❌ No trending items in response" -ForegroundColor Red
    }
    
    if ($dashboard.revenueSeries) {
        Write-Host ""
        Write-Host "Revenue Series: $($dashboard.revenueSeries.Count) data points" -ForegroundColor Yellow
    }
    
    if ($dashboard.topSoldToday) {
        Write-Host ""
        Write-Host "Top Sold Today: $($dashboard.topSoldToday.Count) items" -ForegroundColor Yellow
    }
    
    if ($dashboard.categoryDistribution) {
        Write-Host ""
        Write-Host "Categories: $($dashboard.categoryDistribution.Count)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ API call failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Database Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run this SQL in PostgreSQL to verify data:" -ForegroundColor Yellow
Write-Host ""
Write-Host "SELECT COUNT(*), SUM(total_amount) FROM orders WHERE status = 'PAID';" -ForegroundColor Gray
Write-Host "SELECT * FROM orders WHERE status = 'PAID' ORDER BY created_at DESC LIMIT 5;" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
