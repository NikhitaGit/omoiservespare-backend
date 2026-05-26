# 🗺️ Setup Google Maps API - Get Readable Addresses

## Why You Need This

Currently, your location shows coordinates like `19.076501, 72.877426` instead of readable addresses like:
```
Bandra West, Mumbai, Maharashtra, India
```

This is because the Google Maps API key is not configured.

## Step 1: Get Google Maps API Key

### 1.1 Go to Google Cloud Console
Open: https://console.cloud.google.com/

### 1.2 Create or Select Project
- Click "Select a project" at the top
- Click "NEW PROJECT"
- Name it: "OmoiServes Location System"
- Click "CREATE"

### 1.3 Enable Geocoding API
1. Go to: https://console.cloud.google.com/apis/library
2. Search for "Geocoding API"
3. Click on it
4. Click "ENABLE"

### 1.4 Create API Key
1. Go to: https://console.cloud.google.com/apis/credentials
2. Click "CREATE CREDENTIALS" → "API key"
3. Copy the API key (looks like: `AIzaSyD...`)

### 1.5 Restrict API Key (IMPORTANT for Security!)
1. Click on the API key you just created
2. Under "API restrictions":
   - Select "Restrict key"
   - Check only "Geocoding API"
3. Under "Application restrictions":
   - Select "IP addresses"
   - Add your server IP (or `0.0.0.0/0` for testing only!)
4. Click "SAVE"

## Step 2: Configure API Key

### 2.1 Update .env File
Open `.env` file and replace:
```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

With your actual API key:
```env
GOOGLE_MAPS_API_KEY=AIzaSyD...your_actual_key_here
```

### 2.2 Restart Backend
```powershell
# Stop current backend (Ctrl+C)
mvn spring-boot:run
```

## Step 3: Test It!

### 3.1 Use the Test Script
```powershell
.\setup-google-maps-api.ps1
```

This will:
- Prompt you for your API key
- Save it to `.env`
- Test the API key
- Show you a sample address

### 3.2 Test in Your App
1. Open your React app
2. Go to location picker
3. Click "Use current location"
4. You should now see:
   ```
   Bandra West, Mumbai, Maharashtra 400050, India
   ```
   Instead of coordinates!

## What You'll Get

### Before (Without API Key):
```
Location: 19.076501, 72.877426
```

### After (With API Key):
```
📍 Formatted Address:
Bandra West, Mumbai, Maharashtra 400050, India

📋 Detailed Components:
- Area: Bandra West
- City: Mumbai
- State: Maharashtra
- Country: India
- Postal Code: 400050
```

## Address Format Examples

### Mumbai:
```
Andheri West, Mumbai, Maharashtra 400053, India
```

### Delhi:
```
Connaught Place, New Delhi, Delhi 110001, India
```

### Bangalore:
```
Koramangala, Bengaluru, Karnataka 560034, India
```

## Pricing Information

### Free Tier:
- **$200 credit per month** (Google Cloud free tier)
- This equals approximately **28,000 geocoding requests**
- More than enough for testing and small-scale production

### After Free Tier:
- **$5 per 1,000 requests**
- Set up billing alerts to avoid surprises!

### How to Set Billing Alerts:
1. Go to: https://console.cloud.google.com/billing
2. Click "Budgets & alerts"
3. Create alert at $50, $100, $150

## Troubleshooting

### Issue: "REQUEST_DENIED" Error
**Cause:** API key not enabled or Geocoding API not enabled
**Solution:**
1. Go to https://console.cloud.google.com/apis/library
2. Search "Geocoding API"
3. Click "ENABLE"

### Issue: Still showing coordinates
**Cause:** Backend not restarted or API key not saved
**Solution:**
1. Check `.env` file has correct API key
2. Restart backend: `mvn spring-boot:run`
3. Clear browser cache

### Issue: "API key not valid"
**Cause:** API key restrictions too strict
**Solution:**
1. Go to API key settings
2. Temporarily remove all restrictions
3. Test again
4. Add restrictions back gradually

## Security Best Practices

### ✅ DO:
- Restrict API key to only Geocoding API
- Set up IP address restrictions
- Monitor usage regularly
- Set up billing alerts
- Rotate API keys every 90 days

### ❌ DON'T:
- Share API key publicly
- Commit API key to Git (use .env)
- Leave unrestricted API keys
- Ignore billing alerts

## Monitoring Usage

### Check Usage in Code:
The backend logs API usage:
```
📊 Google Maps API usage: 100/2500 requests today
```

### Check Usage in Console:
1. Go to: https://console.cloud.google.com/google/maps-apis/metrics
2. View requests per day
3. Monitor costs

## Alternative: Use Without API Key

If you don't want to set up Google Maps API, the system will fallback to showing coordinates. But for production, you MUST have readable addresses!

## Files Modified

The system already has enhanced address parsing:
- ✅ `GoogleMapsService.java` - Parses area, city, state, country
- ✅ Caching system - Reduces API calls
- ✅ Rate limiting - Prevents exceeding limits
- ✅ Fallback handling - Works even if API fails

## Next Steps

1. ✅ Get Google Maps API key
2. ✅ Add it to `.env` file
3. ✅ Restart backend
4. ✅ Test location picker
5. ✅ See beautiful formatted addresses!

---

**Status:** Ready to configure! Follow Step 1 to get your API key.
