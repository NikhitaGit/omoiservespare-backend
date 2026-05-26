# 🗺️ Google Maps API - Production Setup Guide

## 🚀 Quick Setup (Automated)

Run the automated setup script:

```powershell
.\setup-google-maps-api.ps1
```

This script will:
1. ✅ Check existing configuration
2. ✅ Guide you through getting an API key
3. ✅ Update .env file
4. ✅ Set environment variables
5. ✅ Test the API key
6. ✅ Provide next steps

---

## 📋 Manual Setup (Step-by-Step)

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a project** → **New Project**
3. Enter project name: `omoiservespare-production`
4. Click **Create**
5. Wait for project creation (takes ~30 seconds)

### Step 2: Enable Required APIs

1. In the Google Cloud Console, go to **APIs & Services** → **Library**
2. Search for **"Geocoding API"**
3. Click on it and click **ENABLE**
4. (Optional) Search for **"Maps JavaScript API"** and enable it
5. Wait for APIs to be enabled

### Step 3: Create API Key

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **API key**
3. Copy the generated API key immediately
4. Click **Edit API key** to configure restrictions

### Step 4: Restrict API Key (CRITICAL for Production)

#### Application Restrictions

Choose one based on your deployment:

**Option A: HTTP Referrers (for web applications)**
```
http://localhost:5173/*
http://localhost:5174/*
https://yourdomain.com/*
https://www.yourdomain.com/*
```

**Option B: IP Addresses (for backend servers)**
```
Your production server IP address
127.0.0.1 (for local development)
```

#### API Restrictions

1. Select **Restrict key**
2. Check only these APIs:
   - ✅ **Geocoding API** (Required)
   - ✅ **Maps JavaScript API** (Optional, for frontend maps)
3. Click **Save**

### Step 5: Configure Environment

#### Update .env File

```bash
# Open .env file and update:
GOOGLE_MAPS_API_KEY=AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY
```

**⚠️ IMPORTANT**: Replace with your actual API key!

#### Set Environment Variable

**Windows PowerShell:**
```powershell
# Current session only
$env:GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"

# Permanent (system-wide)
[System.Environment]::SetEnvironmentVariable("GOOGLE_MAPS_API_KEY", "YOUR_API_KEY_HERE", "User")
```

**Windows CMD:**
```cmd
set GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

**Linux/Mac:**
```bash
# Current session
export GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"' >> ~/.bashrc
source ~/.bashrc
```

### Step 6: Test API Key

```powershell
# Test with curl
curl "https://maps.googleapis.com/maps/api/geocode/json?address=Mumbai&key=YOUR_API_KEY_HERE"
```

**Expected Response:**
```json
{
  "results": [
    {
      "formatted_address": "Mumbai, Maharashtra, India",
      "geometry": {
        "location": {
          "lat": 19.0760,
          "lng": 72.8777
        }
      }
    }
  ],
  "status": "OK"
}
```

**Possible Error Responses:**

| Status | Meaning | Solution |
|--------|---------|----------|
| `REQUEST_DENIED` | API key invalid or API not enabled | Check key and enable Geocoding API |
| `OVER_QUERY_LIMIT` | Exceeded quota | Enable billing or wait for quota reset |
| `INVALID_REQUEST` | Missing parameters | Check request format |
| `ZERO_RESULTS` | Address not found | Try different address |

### Step 7: Restart Application

```powershell
# Stop current application (Ctrl+C)
# Then restart
mvn spring-boot:run
```

Check logs for:
```
✅ Google Maps API configured
✅ Geocoding service ready
```

### Step 8: Test Location API

```powershell
.\test-location-api.ps1
```

---

## 🔒 Production Security Checklist

### API Key Security

- [ ] API key is restricted to specific IPs or domains
- [ ] Only required APIs are enabled (Geocoding API)
- [ ] API key is stored in environment variables (not in code)
- [ ] .env file is added to .gitignore
- [ ] API key is rotated every 90 days
- [ ] Separate keys for development and production

### Billing & Monitoring

- [ ] Billing is enabled on Google Cloud
- [ ] Billing alerts set at $50, $100, $150
- [ ] Daily quota limits configured
- [ ] Usage monitoring dashboard bookmarked
- [ ] Email notifications enabled for quota alerts

### Application Security

- [ ] Rate limiting implemented on location endpoints
- [ ] Geocoding results cached in database
- [ ] User authentication required for all endpoints
- [ ] Input validation on all address fields
- [ ] Error messages don't expose API key

---

## 💰 Cost Management

### Free Tier

- **$200 free credit** per month
- **28,000 free requests** per month for Geocoding API
- Equivalent to **~900 requests per day**

### Pricing After Free Tier

| API | Cost per 1,000 requests |
|-----|------------------------|
| Geocoding API | $5.00 |
| Reverse Geocoding | $5.00 |
| Places API | $17.00 |

### Cost Optimization Strategies

#### 1. Cache Geocoding Results
```java
@Cacheable(value = "geocode", key = "#address")
public Map<String, Double> geocode(String address) {
    // Implementation
}
```

#### 2. Store Results in Database
```sql
-- Save geocoded addresses to avoid repeated API calls
INSERT INTO geocode_cache (address, latitude, longitude, created_at)
VALUES ('Mumbai, India', 19.0760, 72.8777, NOW());
```

#### 3. Implement Rate Limiting
```java
@RateLimiter(name = "location", fallbackMethod = "rateLimitFallback")
public AddressResponse saveLocation(Long userId, LocationRequest request) {
    // Implementation
}
```

#### 4. Set Daily Quotas
```
Google Cloud Console → APIs & Services → Quotas
Set daily limit: 1,000 requests/day
```

#### 5. Monitor Usage
```
Google Cloud Console → APIs & Services → Metrics
Check daily usage and trends
```

---

## 📊 Monitoring & Alerts

### Set Up Billing Alerts

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Billing** → **Budgets & alerts**
3. Click **CREATE BUDGET**
4. Configure:
   - Budget name: `Google Maps API Budget`
   - Budget amount: `$50` (or your limit)
   - Alert thresholds: `50%, 90%, 100%`
   - Email notifications: Your email
5. Click **FINISH**

### Monitor API Usage

**Dashboard URL:**
```
https://console.cloud.google.com/google/maps-apis/metrics
```

**Key Metrics to Monitor:**
- Requests per day
- Errors per day
- Latency (p50, p95, p99)
- Quota usage percentage

### Set Up Slack/Email Alerts

```python
# Example: Send alert when usage exceeds 80%
if daily_usage > (daily_quota * 0.8):
    send_alert("Google Maps API usage at 80%")
```

---

## 🧪 Testing in Production

### Test Current Location Flow

```bash
curl -X POST http://your-domain.com/api/location \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CURRENT",
    "title": "Home",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "phoneNumber": "+91-9876543210"
  }'
```

### Test Manual Address Flow

```bash
curl -X POST http://your-domain.com/api/location \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "MANUAL",
    "title": "Work",
    "address": "Bandra Kurla Complex, Mumbai",
    "phoneNumber": "+91-9876543210"
  }'
```

### Verify Geocoding

```bash
# Check if address was geocoded correctly
curl -X GET http://your-domain.com/api/location \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🐛 Troubleshooting

### Issue: "REQUEST_DENIED"

**Cause**: API key is invalid or Geocoding API is not enabled

**Solution**:
1. Verify API key is correct
2. Check if Geocoding API is enabled
3. Ensure billing is enabled (if required)
4. Check API key restrictions

### Issue: "OVER_QUERY_LIMIT"

**Cause**: Exceeded free tier quota

**Solution**:
1. Enable billing on Google Cloud
2. Implement caching to reduce API calls
3. Set up rate limiting
4. Increase daily quota limit

### Issue: "ZERO_RESULTS"

**Cause**: Address not found or invalid

**Solution**:
1. Validate user input before sending to API
2. Provide address suggestions
3. Use more specific addresses
4. Handle gracefully with fallback

### Issue: API Key Not Working

**Checklist**:
- [ ] API key is correct (no extra spaces)
- [ ] Geocoding API is enabled
- [ ] API key restrictions are correct
- [ ] Billing is enabled (if required)
- [ ] Environment variable is set
- [ ] Application was restarted after setting key

---

## 🔄 Key Rotation

### When to Rotate

- Every 90 days (recommended)
- When key is compromised
- When team member leaves
- Before major deployment

### How to Rotate

1. Create new API key in Google Cloud Console
2. Update .env file with new key
3. Update environment variables
4. Restart application
5. Monitor for errors
6. Delete old key after 24 hours

---

## 📚 Additional Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Geocoding API Guide](https://developers.google.com/maps/documentation/geocoding)
- [API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [Pricing Calculator](https://mapsplatform.google.com/pricing/)
- [Support](https://developers.google.com/maps/support)

---

## ✅ Production Readiness Checklist

### Configuration
- [ ] API key obtained from Google Cloud
- [ ] API key restricted (IP or domain)
- [ ] Only required APIs enabled
- [ ] .env file updated
- [ ] Environment variables set
- [ ] Application restarted

### Security
- [ ] API key not in source code
- [ ] .env file in .gitignore
- [ ] Separate keys for dev/prod
- [ ] Rate limiting implemented
- [ ] Input validation enabled

### Monitoring
- [ ] Billing alerts configured
- [ ] Usage dashboard bookmarked
- [ ] Daily quota limits set
- [ ] Email notifications enabled
- [ ] Logging configured

### Testing
- [ ] API key tested with curl
- [ ] Current location flow tested
- [ ] Manual address flow tested
- [ ] Error handling verified
- [ ] Performance tested

### Documentation
- [ ] API key location documented
- [ ] Rotation schedule documented
- [ ] Team members trained
- [ ] Troubleshooting guide available

---

## 🎉 You're Production Ready!

Your Google Maps API is now configured for production use with:
- ✅ Secure API key with restrictions
- ✅ Billing alerts and monitoring
- ✅ Cost optimization strategies
- ✅ Error handling and fallbacks
- ✅ Complete documentation

**Your location system is ready to handle real users!** 🚀

---

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Google Maps API documentation
3. Check Google Cloud Console for errors
4. Monitor API usage dashboard
5. Contact Google Maps support if needed

**Happy geocoding!** 🗺️
