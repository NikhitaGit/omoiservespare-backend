# 🗺️ Google Maps API Setup Guide

## Step-by-Step Instructions

### 1️⃣ Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a project** → **New Project**
3. Enter project name: `omoiservespare-location`
4. Click **Create**

---

### 2️⃣ Enable Required APIs

1. In the Google Cloud Console, go to **APIs & Services** → **Library**
2. Search for and enable these APIs:
   - **Geocoding API** (Required for address ↔ coordinates conversion)
   - **Maps JavaScript API** (Optional, for frontend map display)
   - **Places API** (Optional, for address autocomplete)

---

### 3️⃣ Create API Key

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **API key**
3. Copy the generated API key
4. Click **Edit API key** to configure restrictions

---

### 4️⃣ Restrict API Key (Recommended)

#### Application Restrictions
- **HTTP referrers (web sites)**: For frontend usage
  - Add: `http://localhost:5173/*`
  - Add: `http://localhost:5174/*`
  - Add your production domain

- **IP addresses (web servers)**: For backend usage
  - Add your server IP address
  - For local development: `127.0.0.1`

#### API Restrictions
- Select **Restrict key**
- Choose:
  - ✅ Geocoding API
  - ✅ Maps JavaScript API (if using frontend maps)
  - ✅ Places API (if using autocomplete)

---

### 5️⃣ Configure Environment Variable

#### Windows (PowerShell)
```powershell
# Temporary (current session only)
$env:GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"

# Permanent (system-wide)
[System.Environment]::SetEnvironmentVariable("GOOGLE_MAPS_API_KEY", "YOUR_API_KEY_HERE", "User")
```

#### Windows (CMD)
```cmd
set GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

#### Linux/Mac
```bash
# Temporary
export GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"' >> ~/.bashrc
source ~/.bashrc
```

---

### 6️⃣ Update .env File

Create or update `.env` file in your project root:

```properties
GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

**⚠️ Important**: Add `.env` to `.gitignore` to avoid committing secrets!

```gitignore
# .gitignore
.env
```

---

### 7️⃣ Verify Configuration

#### Check if API key is loaded
```powershell
# PowerShell
echo $env:GOOGLE_MAPS_API_KEY

# CMD
echo %GOOGLE_MAPS_API_KEY%
```

#### Test API key with curl
```bash
curl "https://maps.googleapis.com/maps/api/geocode/json?address=Mumbai&key=YOUR_API_KEY_HERE"
```

Expected response:
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

---

## 💰 Pricing & Quotas

### Free Tier
- **$200 free credit** per month
- **28,000 free requests** per month for Geocoding API
- Equivalent to ~900 requests per day

### Pricing After Free Tier
- **Geocoding API**: $5 per 1,000 requests
- **Reverse Geocoding**: $5 per 1,000 requests
- **Places API**: $17 per 1,000 requests

### Cost Optimization Tips
1. **Cache results** - Store geocoded addresses in database
2. **Rate limiting** - Limit requests per user
3. **Batch requests** - Combine multiple lookups
4. **Set billing alerts** - Get notified at $50, $100, $150

---

## 🔒 Security Best Practices

### 1. Use Separate Keys
- **Frontend key**: Restricted to HTTP referrers
- **Backend key**: Restricted to IP addresses

### 2. Enable API Restrictions
- Only enable APIs you actually use
- Disable unused APIs

### 3. Monitor Usage
- Set up billing alerts
- Review usage reports weekly
- Check for unusual spikes

### 4. Rotate Keys Regularly
- Rotate API keys every 90 days
- Use key management service for production

### 5. Never Commit Keys
```gitignore
# .gitignore
.env
.env.local
.env.production
application-local.properties
```

---

## 🧪 Testing Without API Key

The system includes fallback behavior when API key is not configured:

### Reverse Geocoding Fallback
```
Input: lat=19.0760, lng=72.8777
Output: "Location: 19.076000, 72.877700"
```

### Forward Geocoding Fallback
```
Input: "123 Main Street, Mumbai"
Output: lat=19.0760, lng=72.8777 (Mumbai default)
```

This allows you to test the system without Google Maps API initially.

---

## 🐛 Troubleshooting

### Error: "REQUEST_DENIED"
- **Cause**: API key is invalid or API is not enabled
- **Solution**: Verify API key and enable Geocoding API

### Error: "OVER_QUERY_LIMIT"
- **Cause**: Exceeded free tier quota
- **Solution**: Enable billing or implement caching

### Error: "INVALID_REQUEST"
- **Cause**: Missing or invalid parameters
- **Solution**: Check lat/lng format or address string

### Error: "ZERO_RESULTS"
- **Cause**: Address not found or invalid coordinates
- **Solution**: Validate user input before sending

### Error: "UNKNOWN_ERROR"
- **Cause**: Server-side error
- **Solution**: Retry the request after a delay

---

## 📊 Monitoring Dashboard

### View API Usage
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Dashboard**
3. Select **Geocoding API**
4. View:
   - Requests per day
   - Errors per day
   - Latency metrics

### Set Up Billing Alerts
1. Go to **Billing** → **Budgets & alerts**
2. Click **CREATE BUDGET**
3. Set budget amount: $50 (or your limit)
4. Set alert thresholds: 50%, 90%, 100%
5. Add email notifications

---

## 🚀 Production Deployment

### Environment Variables
```bash
# Production server
export GOOGLE_MAPS_API_KEY="prod_api_key_here"
export GOOGLE_MAPS_API_KEY_FRONTEND="frontend_api_key_here"
```

### Docker Configuration
```dockerfile
# Dockerfile
ENV GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}
```

### Kubernetes Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: google-maps-secret
type: Opaque
stringData:
  api-key: YOUR_API_KEY_HERE
```

---

## ✅ Checklist

- [ ] Created Google Cloud project
- [ ] Enabled Geocoding API
- [ ] Created API key
- [ ] Configured API restrictions
- [ ] Set environment variable
- [ ] Updated .env file
- [ ] Added .env to .gitignore
- [ ] Tested API key with curl
- [ ] Set up billing alerts
- [ ] Restarted Spring Boot application

---

## 📚 Additional Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Geocoding API Guide](https://developers.google.com/maps/documentation/geocoding)
- [API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [Pricing Calculator](https://mapsplatform.google.com/pricing/)

---

## 🎉 You're Ready!

Once configured, your location system will:
- ✅ Convert GPS coordinates to addresses
- ✅ Convert addresses to GPS coordinates
- ✅ Provide accurate location data
- ✅ Work seamlessly with your frontend

**Happy coding!** 🚀
