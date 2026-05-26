# Test Location API Fix
Write-Host "`n🧪 Testing Location API Fix..." -ForegroundColor Cyan

# Get token (replace with your actual token)
$token = Read-Host "Enter your JWT token"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 1: Save current location
Write-Host "`n📍 Test 1: Saving current location..." -ForegroundColor Yellow
$currentLocationData = @{
    type = "CURRENT"
    title = "Current Location"
    latitude = 19.0760
    longitude = 72.8777
    phoneNumber = $null
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/location" `
        -Method Post `
        -Headers $headers `
        -Body $currentLocationData
    
    Write-Host "✅ Current location saved successfully!" -ForegroundColor Green
    Write-Host "Address: $($response.data.address)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Failed to save current location" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Test 2: Save manual address
Write-Host "`n📍 Test 2: Saving manual address..." -ForegroundColor Yellow
$manualAddressData = @{
    type = "MANUAL"
    title = "Home"
    address = "Bandra West, Mumbai, Maharashtra"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/location" `
        -Method Post `
        -Headers $headers `
        -Body $manualAddressData
    
    Write-Host "✅ Manual address saved successfully!" -ForegroundColor Green
    Write-Host "Coordinates: $($response.data.latitude), $($response.data.longitude)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Failed to save manual address" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Test 3: Get all addresses
Write-Host "`n📋 Test 3: Fetching all addresses..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/location" `
        -Method Get `
        -Headers $headers
    
    Write-Host "✅ Addresses fetched successfully!" -ForegroundColor Green
    Write-Host "Total addresses: $($response.data.Count)" -ForegroundColor Cyan
    
    foreach ($addr in $response.data) {
        Write-Host "`n  📍 $($addr.title)" -ForegroundColor White
        Write-Host "     $($addr.address)" -ForegroundColor Gray
        if ($addr.phoneNumber) {
            Write-Host "     Phone: $($addr.phoneNumber)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "❌ Failed to fetch addresses" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n✅ Location API tests complete!" -ForegroundColor Green
