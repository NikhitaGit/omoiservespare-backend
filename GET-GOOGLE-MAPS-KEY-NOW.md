# 🚀 Get Google Maps API Key in 2 Minutes

## Why You Need to Do This Yourself

I cannot add the API key for you because:
- ✅ API keys are tied to YOUR Google account
- ✅ YOU control the billing and costs
- ✅ YOU own the security and restrictions
- ✅ It's YOUR production application

**But don't worry - it takes only 2 minutes!**

## Quick Setup (2 Minutes)

### Step 1: Open Google Cloud Console (30 seconds)
Click this link: https://console.cloud.google.com/

- Sign in with your Google account
- Click "Select a project" → "NEW PROJECT"
- Name: "OmoiServes" → Click "CREATE"

### Step 2: Enable Geocoding API (30 seconds)
Click this direct link: https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com

- Make sure your project is selected at the top
- Click the blue "ENABLE" button
- Wait 5 seconds for it to enable

### Step 3: Create API Key (30 seconds)
Click this direct link: https://console.cloud.google.com/apis/credentials

- Click "CREATE CREDENTIALS" → "API key"
- Copy the API key (it looks like: `AIzaSyD...`)
- Click "CLOSE" (we'll restrict it later)

### Step 4: Add to Your App (30 seconds)
Run this command in PowerShell:
```powershell
.\setup-google-maps-api.ps1
```

When prompted, paste your API key and press Enter.

**DONE! Your location system is now production-ready!**

## What Happens After Setup

### Before:
```
Location: 19.076501, 72.877426
```

### After:
```
Bandra West, Mumbai, Maharashtra 400050, India
```

## Cost Information

### Free Tier:
- **$200 credit per month** from Google
- Equals **~28,000 location requests**
- Perfect for testing and small production

### Example Usage:
- 100 users per day = 100 requests
- 30 days = 3,000 requests
- **Cost: $0** (within free tier!)

### After Free Tier:
- $5 per 1,000 requests
- Still very affordable!

## Security (Do This After Testing)

Once your app is working, secure your API key:

1. Go to: https://console.cloud.google.com/apis/credentials
2. Click on your API key
3. Under "API restrictions":
   - Select "Restrict key"
   - Check only "Geocoding API"
4. Under "Application restrictions":
   - Select "HTTP referrers"
   - Add: `localhost:*` (for testing)
   - Add: `yourdomain.com/*` (for production)
5. Click "SAVE"

## Alternative: Use Without API Key

If you really don't want to set up Google Maps API right now, the system will work but show coordinates instead of addresses. You can add the API key later anytime.

## Need Help?

### Issue: Don't have a Google account
**Solution:** Create one at https://accounts.google.com/signup

### Issue: Don't have a credit card
**Solution:** Google Cloud requires a credit card for verification, but you won't be charged within the free tier

### Issue: Worried about costs
**Solution:** Set up billing alerts:
1. Go to: https://console.cloud.google.com/billing
2. Click "Budgets & alerts"
3. Create alert at $10, $50, $100

## Why This is Worth It

✅ **Professional addresses** like Swiggy/Zomato
✅ **Better user experience** - users see real locations
✅ **Production-ready** - works exactly like big apps
✅ **Free for most usage** - $200 credit per month
✅ **Takes only 2 minutes** - one-time setup

## Ready? Let's Do This!

1. Click: https://console.cloud.google.com/
2. Create project
3. Enable Geocoding API
4. Create API key
5. Run: `.\setup-google-maps-api.ps1`
6. Paste your key
7. **DONE!**

---

**Your location system is already built and ready. It just needs YOUR API key to show beautiful addresses!**
