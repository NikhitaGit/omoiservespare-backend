# Quick Test: Create Orders via API
# This creates test orders through your backend API

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Create Test Orders for Dashboard" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"

# Step 1: Login
Write-Host "[STEP 1] Login to get JWT token" -ForegroundColor Yellow
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
    Write-Host "✅ Login successful!" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Step 2: Check current dashboard data
Write-Host ""
Write-Host "[STEP 2] Checking current dashboard data..." -ForegroundColor Yellow
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=today" -Headers $headers
    Write-Host "Current Today Revenue: ₹$($dashboard.kpis.todayRevenue)" -ForegroundColor Gray
    Write-Host "Current Total Orders: $($dashboard.kpis.totalOrders)" -ForegroundColor Gray
} catch {
    Write-Host "⚠️ Could not fetch dashboard" -ForegroundColor Yellow
}

# Step 3: Get available canteens and menu items
Write-Host ""
Write-Host "[STEP 3] Fetching canteens and menu items..." -ForegroundColor Yellow

try {
    # Get canteens
    $canteens = Invoke-RestMethod -Uri "$baseUrl/api/canteens" -Headers $headers
    if ($canteens.Count -eq 0) {
        Write-Host "❌ No canteens found. Please create a canteen first." -ForegroundColor Red
        exit
    }
    $canteenId = $canteens[0].id
    Write-Host "Using canteen: $($canteens[0].name) (ID: $canteenId)" -ForegroundColor Gray
    
    # Get menu items for this canteen
    $menuItems = Invoke-RestMethod -Uri "$baseUrl/api/canteens/$canteenId/menu" -Headers $headers
    if ($menuItems.Count -eq 0) {
        Write-Host "❌ No menu items found. Please add menu items first." -ForegroundColor Red
        exit
    }
    Write-Host "Found $($menuItems.Count) menu items" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Error fetching data: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Step 4: Create test orders
Write-Host ""
Write-Host "[STEP 4] Creating test orders..." -ForegroundColor Yellow

$ordersCreated = 0

# Create 3 test orders
for ($i = 1; $i -le 3; $i++) {
    Write-Host "Creating order $i..." -ForegroundColor Gray
    
    # Select random items
    $selectedItems = $menuItems | Get-Random -Count ([Math]::Min(2, $menuItems.Count))
    
    $orderItems = @()
    $totalAmount = 0
    
    foreach ($item in $selectedItems) {
        $qty = Get-Random -Minimum 1 -Maximum 4
        $orderItems += @{
            itemId = $item.id
            quantity = $qty
            price = $item.price
        }
        $totalAmount += $item.price * $qty
    }
    
    $orderBody = @{
        canteenId = $canteenId
        items = $orderItems
        totalAmount = $totalAmount
        paymentMethod = "WALLET"
    } | ConvertTo-Json -Depth 3
    
    try {
        # Create order
        $order = Invoke-RestMethod -Uri "$baseUrl/api/orders" -Method POST -Body $orderBody -Headers $headers
        Write-Host "  Order created: ID $($order.id)" -ForegroundColor Green
        
        # Mark as PAID (you might need to call payment confirmation endpoint)
        # This depends on your API structure
        # Example: Invoke-RestMethod -Uri "$baseUrl/api/orders/$($order.id)/confirm-payment" -Method POST -Headers $headers
        
        $ordersCreated++
        Start-Sleep -Seconds 1
        
    } catch {
        Write-Host "  ⚠️ Failed to create order: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Created $ordersCreated test orders" -ForegroundColor Green

# Step 5: Check updated dashboard
Write-Host ""
Write-Host "[STEP 5] Checking updated dashboard..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=today" -Headers $headers
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Updated Dashboard Data" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Today Revenue:  ₹$($dashboard.kpis.todayRevenue)" -ForegroundColor White
    Write-Host "Total Orders:   $($dashboard.kpis.totalOrders)" -ForegroundColor White
    Write-Host "Customers:      $($dashboard.kpis.customers)" -ForegroundColor White
    Write-Host ""
    
    if ($dashboard.trendingItems.Count -gt 0) {
        Write-Host "Trending Items:" -ForegroundColor Yellow
        foreach ($item in $dashboard.trendingItems | Select-Object -First 3) {
            Write-Host "  - $($item.name): ₹$($item.revenue)" -ForegroundColor White
        }
    }
    
} catch {
    Write-Host "❌ Could not fetch updated dashboard" -ForegroundColor Red
}

Write-Host ""
Write-Host "Done! Refresh your admin dashboard page to see the data." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
