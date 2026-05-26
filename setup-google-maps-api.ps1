# 🗺️ Google Maps API Setup Script
Write-Host "`n🗺️  Google Maps API Setup for Production" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "📋 Quick Setup Guide:" -ForegroundColor Yellow
Write-Host "1. Go to: https://console.cloud.google.com/" -ForegroundColor White
Write-Host "2. Create a new project (if you don't have one)" -ForegroundColor White
Write-Host "3. Enable 'Geocoding API'" -ForegroundColor White
Write-Host "4. Create an API key" -ForegroundColor White
Write-Host "5. Copy the API key and paste it below`n" -ForegroundColor White

Write-Host "💡 Direct Links:" -ForegroundColor Cyan
Write-Host "   Enable API: https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com" -ForegroundColor Gray
Write-Host "   Get API Key: https://console.cloud.google.com/apis/credentials`n" -ForegroundColor Gray

# Step 1: Check if API key already exists
Write-Host "📋 Step 1: Checking existing configuration..." -ForegroundColor Yellow

$envFile = ".env"
$currentKey = $null

if (Test-Path $envFile) {
    $content = Get-Content $envFile -Raw
    if ($content -match 'GOOGLE_MAPS_API_KEY=([^\r\n]+)') {
        $currentKey = $matches[1]
        if ($currentKey -and $currentKey -ne "your_google_maps_api_key_here") {
            Write-Host "✅ Found existing API key: $($currentKey.Substring(0, [Math]::Min(20, $currentKey.Length)))..." -ForegroundColor Green
            $replace = Read-Host "`nDo you want to replace it? (y/n)"
            if ($replace -ne "y") {
                Write-Host "`n✅ Keeping existing API key" -ForegroundColor Green
                exit 0
            }
        }
    }
}

# Step 2: Instructions for getting API key
Write-Host "`n📝 Step 2: Get your Google Maps API Key" -ForegroundColor Yellow
Write-Host "`nFollow these steps:" -ForegroundColor White
Write-Host "1. Go to: https://console.cloud.google.com/" -ForegroundColor Cyan
Write-Host "2. Create a new project or select existing" -ForegroundColor Cyan
Write-Host "3. Go to 'APIs & Services' → 'Library'" -ForegroundColor Cyan
Write-Host "4. Enable these APIs:" -ForegroundColor Cyan
Write-Host "   - Geocoding API (Required)" -ForegroundColor White
Write-Host "   - Maps JavaScript API (Optional)" -ForegroundColor White
Write-Host "5. Go to 'Credentials' → 'Create Credentials' → 'API key'" -ForegroundColor Cyan
Write-Host "6. Copy the API key" -ForegroundColor Cyan

Write-Host "`n⚠️  IMPORTANT: Restrict your API key for security!" -ForegroundColor Yellow
Write-Host "   - Application restrictions: HTTP referrers or IP addresses" -ForegroundColor White
Write-Host "   - API restrictions: Select only Geocoding API" -ForegroundColor White

# Step 3: Get API key from user
Write-Host "`n🔑 Step 3: Enter your API Key" -ForegroundColor Yellow
$apiKey = Read-Host "`nPaste your Google Maps API key here"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host "`n❌ No API key provided. Exiting..." -ForegroundColor Red
    exit 1
}

# Validate API key format (basic check)
if ($apiKey.Length -lt 30) {
    Write-Host "`n⚠️  Warning: API key seems too short. Are you sure it's correct?" -ForegroundColor Yellow
    $confirm = Read-Host "Continue anyway? (y/n)"
    if ($confirm -ne "y") {
        exit 1
    }
}

# Step 4: Update .env file
Write-Host "`n💾 Step 4: Updating .env file..." -ForegroundColor Yellow

if (Test-Path $envFile) {
    $content = Get-Content $envFile -Raw
    
    # Check if GOOGLE_MAPS_API_KEY exists
    if ($content -match 'GOOGLE_MAPS_API_KEY=') {
        # Replace existing key
        $content = $content -replace 'GOOGLE_MAPS_API_KEY=.*', "GOOGLE_MAPS_API_KEY=$apiKey"
        Write-Host "✅ Updated existing API key in .env" -ForegroundColor Green
    } else {
        # Add new key
        $content += "`nGOOGLE_MAPS_API_KEY=$apiKey"
        Write-Host "✅ Added new API key to .env" -ForegroundColor Green
    }
    
    Set-Content -Path $envFile -Value $content -NoNewline
} else {
    # Create new .env file
    $content = "GOOGLE_MAPS_API_KEY=$apiKey"
    Set-Content -Path $envFile -Value $content
    Write-Host "✅ Created new .env file with API key" -ForegroundColor Green
}

# Step 5: Set environment variable for current session
Write-Host "`n🔧 Step 5: Setting environment variable..." -ForegroundColor Yellow
$env:GOOGLE_MAPS_API_KEY = $apiKey
Write-Host "✅ Environment variable set for current session" -ForegroundColor Green

# Step 6: Test API key
Write-Host "`n🧪 Step 6: Testing API key..." -ForegroundColor Yellow

try {
    $testUrl = "https://maps.googleapis.com/maps/api/geocode/json?address=Mumbai&key=$apiKey"
    $response = Invoke-RestMethod -Uri $testUrl -Method Get -ErrorAction Stop
    
    if ($response.status -eq "OK") {
        Write-Host "✅ API key is valid and working!" -ForegroundColor Green
        Write-Host "`nTest result:" -ForegroundColor Cyan
        Write-Host "  Address: $($response.results[0].formatted_address)" -ForegroundColor White
        Write-Host "  Latitude: $($response.results[0].geometry.location.lat)" -ForegroundColor White
        Write-Host "  Longitude: $($response.results[0].geometry.location.lng)" -ForegroundColor White
    } elseif ($response.status -eq "REQUEST_DENIED") {
        Write-Host "❌ API key is invalid or API is not enabled" -ForegroundColor Red
        Write-Host "   Error: $($response.error_message)" -ForegroundColor Red
        Write-Host "`n   Please check:" -ForegroundColor Yellow
        Write-Host "   1. API key is correct" -ForegroundColor White
        Write-Host "   2. Geocoding API is enabled" -ForegroundColor White
        Write-Host "   3. Billing is enabled (if required)" -ForegroundColor White
    } else {
        Write-Host "⚠️  API key test returned status: $($response.status)" -ForegroundColor Yellow
        Write-Host "   Message: $($response.error_message)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Could not test API key (network error)" -ForegroundColor Yellow
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   The key has been saved, but please test it manually" -ForegroundColor Yellow
}

# Step 7: Set permanent environment variable (optional)
Write-Host "`n🔐 Step 7: Set permanent environment variable?" -ForegroundColor Yellow
Write-Host "This will set the API key as a system environment variable" -ForegroundColor White
$setPermanent = Read-Host "Set permanent environment variable? (y/n)"

if ($setPermanent -eq "y") {
    try {
        [System.Environment]::SetEnvironmentVariable("GOOGLE_MAPS_API_KEY", $apiKey, "User")
        Write-Host "✅ Permanent environment variable set" -ForegroundColor Green
        Write-Host "   (Will be available in new terminal sessions)" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Failed to set permanent environment variable" -ForegroundColor Red
        Write-Host "   You may need to run PowerShell as Administrator" -ForegroundColor Yellow
    }
}

# Step 8: Summary
Write-Host "`n📊 Setup Summary" -ForegroundColor Cyan
Write-Host "================`n" -ForegroundColor Cyan

Write-Host "✅ API key saved to .env file" -ForegroundColor Green
Write-Host "✅ Environment variable set for current session" -ForegroundColor Green
if ($setPermanent -eq "y") {
    Write-Host "✅ Permanent environment variable set" -ForegroundColor Green
}

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Restart your Spring Boot application" -ForegroundColor White
Write-Host "   mvn spring-boot:run" -ForegroundColor Cyan
Write-Host "`n2. Test the location API" -ForegroundColor White
Write-Host "   .\test-location-api.ps1" -ForegroundColor Cyan
Write-Host "`n3. Monitor your API usage at:" -ForegroundColor White
Write-Host "   https://console.cloud.google.com/google/maps-apis/metrics" -ForegroundColor Cyan

Write-Host "`n💰 Pricing Information:" -ForegroundColor Yellow
Write-Host "   Free tier: $200 credit/month (~28,000 requests)" -ForegroundColor WhitegroundColor White
Write-Host "   After free tier: $5 per 1,000 requests" -ForegroundColor White
Write-Host "   Set up billing alerts to avoid surprises!" -ForegroundColor Cyan

Write-Host "`n🔒 Security Recommendations:" -ForegroundColor Yellow
Write-Host "   1. Restrict API key to specific IPs or domains" -ForegroundColor White
Write-Host "   2. Enable only required APIs (Geocoding API)" -ForegroundColor White
Write-Host "   3. Set up billing alerts" -ForegroundColor White
Write-Host "   4. Monitor usage regularly" -ForegroundColor White
Write-Host "   5. Rotate API keys every 90 days" -ForegroundColor White

Write-Host "`n✅ Google Maps API setup complete!" -ForegroundColor Green
Write-Host "`n🚀 Your location system is now production-ready!" -ForegroundColor Cyan
