# 📍 Location API Test Script
# Tests all location endpoints

$baseUrl = "http://localhost:8080"
$token = Read-Host "Enter your JWT token"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "`n🧪 Testing Location API..." -ForegroundColor Cyan

# Test 1: Save Current Location
Write-Host "`n1️⃣ Testing: Save Current Location" -ForegroundColor Yellow
$currentLocationBody = @{
    type = "CURRENT"
    title = "Home"
    latitude = 19.0760
    longitude = 72.8777
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/location" `
        -Method POST `
        -Headers $headers `
        -Body $currentLocationBody
    Write-Host "✅ Current location saved successfully" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 5)
    $savedId = $response.data.id
} catch {
    Write-Host "❌ Failed to save current location" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Start-Sleep -Seconds 2

# Test 2: Save Manual Address
Write-Host "`n2️⃣ Testing: Save Manual Address" -ForegroundColor Yellow
$manualAddressBody = @{
    type = "MANUAL"
    title = "Work"
    address = "Bandra Kurla Complex, Mumbai, Maharashtra 400051"
    phoneNumber = "+91-9876543211"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/location" `
        -Method POST `
        -Headers $headers `
        -Body $manualAddressBody
    Write-Host "✅ Manual address saved successfully" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "❌ Failed to save manual address" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Start-Sleep -Seconds 2

# Test 3: Get All Addresses
Write-Host "`n3️⃣ Testing: Get All Addresses" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/location" `
        -Method GET `
        -Headers $headers
    Write-Host "✅ Retrieved all addresses" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "❌ Failed to get addresses" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Start-Sleep -Seconds 2

# Test 4: Get Default Address
Write-Host "`n4️⃣ Testing: Get Default Address" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/location/default" `
        -Method GET `
        -Headers $headers
    Write-Host "✅ Retrieved default address" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "❌ Failed to get default address" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Start-Sleep -Seconds 2

# Test 5: Set Address as Default (if we have a saved ID)
if ($savedId) {
    Write-Host "`n5️⃣ Testing: Set Address as Default" -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/location/$savedId/default" `
            -Method PUT `
            -Headers $headers
        Write-Host "✅ Set address as default" -ForegroundColor Green
        Write-Host ($response | ConvertTo-Json -Depth 5)
    } catch {
        Write-Host "❌ Failed to set default address" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    
    Start-Sleep -Seconds 2
    
    # Test 6: Update Address
    Write-Host "`n6️⃣ Testing: Update Address" -ForegroundColor Yellow
    $updateBody = @{
        type = "MANUAL"
        title = "Home (Updated)"
        address = "Updated Address, Mumbai, Maharashtra"
        phoneNumber = "+91-9876543212"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/location/$savedId" `
            -Method PUT `
            -Headers $headers `
            -Body $updateBody
        Write-Host "✅ Address updated successfully" -ForegroundColor Green
        Write-Host ($response | ConvertTo-Json -Depth 5)
    } catch {
        Write-Host "❌ Failed to update address" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    
    Start-Sleep -Seconds 2
    
    # Test 7: Delete Address
    Write-Host "`n7️⃣ Testing: Delete Address" -ForegroundColor Yellow
    $confirm = Read-Host "Do you want to delete the test address? (y/n)"
    if ($confirm -eq "y") {
        try {
            $response = Invoke-RestMethod -Uri "$baseUrl/api/location/$savedId" `
                -Method DELETE `
                -Headers $headers
            Write-Host "✅ Address deleted successfully" -ForegroundColor Green
            Write-Host ($response | ConvertTo-Json -Depth 5)
        } catch {
            Write-Host "❌ Failed to delete address" -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }
}

Write-Host "`n✅ Location API testing complete!" -ForegroundColor Cyan
Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Set up Google Maps API key in .env file"
Write-Host "2. Restart Spring Boot application"
Write-Host "3. Integrate with your frontend LocationPicker component"
