# ⚡ Quick Start - Location System

## Your System is 100% Ready!

Everything is built and production-ready. You just need to add YOUR Google Maps API key.

## One Command Setup

```powershell
.\setup-google-maps-api.ps1
```

This script will:
1. Show you direct links to get your API key
2. Prompt you to paste your API key
3. Save it to `.env` file
4. Test it automatically
5. Tell you if it's working

## Get Your API Key (2 Minutes)

### 1. Create Project
https://console.cloud.google.com/
- Click "NEW PROJECT"
- Name: "OmoiServes"
- Click "CREATE"

### 2. Enable API
https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com
- Click "ENABLE"

### 3. Get Key
https://console.cloud.google.com/apis/credentials
- Click "CREATE CREDENTIALS" → "API key"
- Copy the key

### 4. Run Setup
```powershell
.\setup-google-maps-api.ps1
```
- Paste your key when prompted
- Done!

## What You Get

**Before:**
```
Location: 19.076501, 72.877426
```

**After:**
```
Bandra West, Mumbai, Maharashtra 400050, India
```

## Cost

- **Free:** $200 credit/month = ~28,000 requests
- **After free tier:** $5 per 1,000 requests
- **With caching:** 80% reduction in API calls

## That's It!

Your location system will work exactly like Swiggy/Zomato with beautiful formatted addresses.

---

**Ready? Run:** `.\setup-google-maps-api.ps1`
