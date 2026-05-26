# Admin Dashboard Backend Testing Script
# Tests all endpoints and functionality

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Admin Dashboard Backend Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$testsPassed = 0
$testsFailed = 0

# Function to print test result
function Test-Result {
    param($testName, $success, $details = "")
    if ($success) {
        Write-Host "[PASS] $testName" -ForegroundColor Green
        if ($details) { Write-Host "       $details" -ForegroundColor Gray }
        $script:testsPassed++
    } else {
        Write-Host "[FAIL] $testName" -ForegroundColor Red
        if ($details) { Write-Host "       $details" -ForegroundColor Yellow }
        $script:testsFailed++
    }
}

# Test 1: Check if backend is running
Write-Host "`n[TEST 1] Backend Server Status" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/admin/dashboard/health" -Method GET -UseBasicParsing
    Test-Result "Backend is running" ($response.StatusCode -eq 200) "Status: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Test-Result "Backend is running" $false "Cannot connect to $baseUrl"
    Write-Host "ERROR: Make sure backend is running with 'mvn spring-boot:run'" -ForegroundColor Red
    exit 1
}

# Test 2: Login and get JWT token
Write-Host "`n[TEST 2] Authentication & JWT Token" -ForegroundColor Yellow
Write-Host "----------------------------------------"
Write-Host "Enter admin credentials:" -ForegroundColor Cyan
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
    
    if ($token) {
        Test-Result "Login successful" $true "Token received (length: $($token.Length))"
        Write-Host "Token: $($token.Substring(0, 50))..." -ForegroundColor Gray
    } else {
        Test-Result "Login successful" $false "No token in response"
        exit 1
    }
} catch {
    Test-Result "Login successful" $false $_.Exception.Message
    Write-Host "ERROR: Login failed. Check credentials." -ForegroundColor Red
    exit 1
}

# Create headers with JWT token
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 3: Dashboard endpoint - Today
Write-Host "`n[TEST 3] Dashboard API - Today Range" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=today" -Method GET -Headers $headers
    
    Test-Result "Dashboard API responds" $true "Data received"
    
    # Check KPIs
    if ($dashboard.kpis) {
        Test-Result "KPIs present" $true "Revenue: ₹$($dashboard.kpis.todayRevenue)"
        Write-Host "       Today Revenue: ₹$($dashboard.kpis.todayRevenue)" -ForegroundColor Gray
        Write-Host "       Total Revenue: ₹$($dashboard.kpis.totalRevenue)" -ForegroundColor Gray
        Write-Host "       Total Orders: $($dashboard.kpis.totalOrders)" -ForegroundColor Gray
        Write-Host "       Customers: $($dashboard.kpis.customers)" -ForegroundColor Gray
    } else {
        Test-Result "KPIs present" $false "No KPIs in response"
    }
    
    # Check trending items
    if ($dashboard.trendingItems) {
        Test-Result "Trending items present" $true "Count: $($dashboard.trendingItems.Count)"
        if ($dashboard.trendingItems.Count -gt 0) {
            Write-Host "       Top item: $($dashboard.trendingItems[0].name) (₹$($dashboard.trendingItems[0].revenue))" -ForegroundColor Gray
        }
    } else {
        Test-Result "Trending items present" $false "No trending items"
    }
    
    # Check revenue series
    if ($dashboard.revenueSeries) {
        Test-Result "Revenue series present" $true "Data points: $($dashboard.revenueSeries.Count)"
    } else {
        Test-Result "Revenue series present" $false "No revenue series"
    }
    
} catch {
    Test-Result "Dashboard API responds" $false $_.Exception.Message
}

# Test 4: Dashboard endpoint - Week
Write-Host "`n[TEST 4] Dashboard API - Week Range" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=week" -Method GET -Headers $headers
    
    Test-Result "Week range works" $true "Data received"
    Write-Host "       Total Revenue (week): ₹$($dashboard.kpis.totalRevenue)" -ForegroundColor Gray
    Write-Host "       Total Orders (week): $($dashboard.kpis.totalOrders)" -ForegroundColor Gray
    
} catch {
    Test-Result "Week range works" $false $_.Exception.Message
}

# Test 5: Dashboard endpoint - Month
Write-Host "`n[TEST 5] Dashboard API - Month Range" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=month" -Method GET -Headers $headers
    
    Test-Result "Month range works" $true "Data received"
    Write-Host "       Total Revenue (month): ₹$($dashboard.kpis.totalRevenue)" -ForegroundColor Gray
    Write-Host "       Total Orders (month): $($dashboard.kpis.totalOrders)" -ForegroundColor Gray
    
} catch {
    Test-Result "Month range works" $false $_.Exception.Message
}

# Test 6: Check data structure completeness
Write-Host "`n[TEST 6] Data Structure Validation" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=week" -Method GET -Headers $headers
    
    # Check all required fields
    $requiredFields = @(
        "kpis",
        "trendingItems",
        "revenueSeries",
        "topSoldToday",
        "leastSoldToday",
        "categoryDistribution",
        "sessions",
        "customerRate"
    )
    
    foreach ($field in $requiredFields) {
        if ($dashboard.$field -ne $null) {
            Test-Result "Field '$field' exists" $true
        } else {
            Test-Result "Field '$field' exists" $false "Missing in response"
        }
    }
    
} catch {
    Test-Result "Data structure validation" $false $_.Exception.Message
}

# Test 7: Check without JWT token (should fail)
Write-Host "`n[TEST 7] Security - JWT Required" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/admin/dashboard?range=week" -Method GET -UseBasicParsing
    Test-Result "Endpoint requires JWT" $false "Endpoint accessible without token (security issue!)"
} catch {
    if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 403) {
        Test-Result "Endpoint requires JWT" $true "401/403 returned without token (correct)"
    } else {
        Test-Result "Endpoint requires JWT" $false "Unexpected error: $($_.Exception.Message)"
    }
}

# Test 8: Database connection check
Write-Host "`n[TEST 8] Database Connection" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=today" -Method GET -Headers $headers
    
    if ($dashboard.kpis.totalOrders -ge 0) {
        Test-Result "Database connected" $true "Query executed successfully"
    } else {
        Test-Result "Database connected" $false "Invalid data returned"
    }
} catch {
    Test-Result "Database connected" $false $_.Exception.Message
}

# Test 9: Performance check
Write-Host "`n[TEST 9] Performance Test" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=week" -Method GET -Headers $headers
    $stopwatch.Stop()
    
    $responseTime = $stopwatch.ElapsedMilliseconds
    
    if ($responseTime -lt 1000) {
        Test-Result "Response time < 1s" $true "$responseTime ms"
    } elseif ($responseTime -lt 2000) {
        Test-Result "Response time < 2s" $true "$responseTime ms (acceptable)"
    } else {
        Test-Result "Response time" $false "$responseTime ms (too slow)"
    }
} catch {
    Test-Result "Performance test" $false $_.Exception.Message
}

# Test 10: Full response structure
Write-Host "`n[TEST 10] Complete Response Sample" -ForegroundColor Yellow
Write-Host "----------------------------------------"
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/api/admin/dashboard?range=week" -Method GET -Headers $headers
    
    Write-Host "Sample Dashboard Response:" -ForegroundColor Cyan
    Write-Host ($dashboard | ConvertTo-Json -Depth 3) -ForegroundColor Gray
    
    Test-Result "Full response retrieved" $true "See above for complete structure"
} catch {
    Test-Result "Full response retrieved" $false $_.Exception.Message
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor Red
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✅ All tests passed! Admin Dashboard backend is working correctly." -ForegroundColor Green
} else {
    Write-Host "❌ Some tests failed. Please check the errors above." -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
