# Test Admin Dashboard API

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Admin Dashboard API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if application is running
Write-Host "[1/4] Checking if application is running..." -ForegroundColor Yellow
try {
    $port = netstat -ano | findstr ":8080"
    if ($port) {
        Write-Host "Application is running on port 8080" -ForegroundColor Green
    } else {
        Write-Host "Application is not running. Please start it first." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error checking application status" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/4] Testing Health Endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard/health" -Method GET
    Write-Host "Health check passed: $response" -ForegroundColor Green
} catch {
    Write-Host "Health check failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/4] Testing Dashboard API (This Week)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" -Method GET
    Write-Host "Dashboard API response received!" -ForegroundColor Green
    Write-Host ""
    Write-Host "KPIs:" -ForegroundColor Cyan
    Write-Host "  Today Revenue: Rs.$($response.kpis.todayRevenue)" -ForegroundColor White
    Write-Host "  Total Revenue: Rs.$($response.kpis.totalRevenue)" -ForegroundColor White
    Write-Host "  Total Orders: $($response.kpis.totalOrders)" -ForegroundColor White
    Write-Host "  Customers: $($response.kpis.customers)" -ForegroundColor White
    Write-Host ""
    Write-Host "Trending Items: $($response.trendingItems.Count)" -ForegroundColor Cyan
    Write-Host "Revenue Series: $($response.revenueSeries.Count) data points" -ForegroundColor Cyan
    Write-Host "Insights: $($response.insights.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "Dashboard API failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[4/4] Testing Different Ranges..." -ForegroundColor Yellow

$ranges = @("today", "month", "year")
foreach ($range in $ranges) {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=$range" -Method GET
        Write-Host "  $range : OK (Revenue: Rs.$($response.kpis.totalRevenue))" -ForegroundColor Green
    } catch {
        Write-Host "  $range : FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WebSocket Testing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test WebSocket real-time updates:" -ForegroundColor Yellow
Write-Host "1. Open browser console" -ForegroundColor White
Write-Host "2. Run this code:" -ForegroundColor White
Write-Host ""
Write-Host "const socket = new SockJS('http://localhost:8080/ws');" -ForegroundColor Gray
Write-Host "const stompClient = Stomp.over(socket);" -ForegroundColor Gray
Write-Host "stompClient.connect({}, () => {" -ForegroundColor Gray
Write-Host "  console.log('Connected to WebSocket');" -ForegroundColor Gray
Write-Host "  stompClient.subscribe('/topic/admin/dashboard', (message) => {" -ForegroundColor Gray
Write-Host "    console.log('Dashboard update:', JSON.parse(message.body));" -ForegroundColor Gray
Write-Host "  });" -ForegroundColor Gray
Write-Host "});" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Place an order from your app" -ForegroundColor White
Write-Host "4. Watch the console for real-time updates!" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "API Endpoints" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "GET http://localhost:8080/api/admin/dashboard" -ForegroundColor White
Write-Host "GET http://localhost:8080/api/admin/dashboard?range=today" -ForegroundColor White
Write-Host "GET http://localhost:8080/api/admin/dashboard?range=week" -ForegroundColor White
Write-Host "GET http://localhost:8080/api/admin/dashboard?range=month" -ForegroundColor White
Write-Host "GET http://localhost:8080/api/admin/dashboard?range=year" -ForegroundColor White
Write-Host "GET http://localhost:8080/api/admin/dashboard?start=2026-04-01&end=2026-04-23" -ForegroundColor White
Write-Host ""

Write-Host "Admin Dashboard API is ready!" -ForegroundColor Green
Write-Host ""
