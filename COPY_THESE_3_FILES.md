# ✅ Copy These 3 Files to Fix Coupon Timeout

## Quick Fix (5 Minutes)

### Step 1: Copy Files

From `frontend-integration/` folder, copy these 3 files to your frontend:

```
axiosInstance_FINAL.js  →  your-frontend/src/api/axiosInstance.js
couponApi_FINAL.js      →  your-frontend/src/api/couponApi.js
canteenApi_FINAL.js     →  your-frontend/src/api/canteenApi.js
```

### Step 2: Restart Frontend

```bash
# Stop current frontend (Ctrl+C in terminal)
npm start
```

### Step 3: Clear Browser Cache

1. Press F12
2. Right-click refresh button
3. Click "Empty Cache and Hard Reload"

### Step 4: Test

Try applying a coupon in your cart.

---

## What Changed?

**Timeout increased from 30s to 60s:**
- `axiosInstance.js` - Line 13: `timeout: 60000`
- `couponApi.js` - All API calls: `timeout: 60000`
- `canteenApi.js` - All API calls: `timeout: 60000`

---

## Why 60 Seconds?

Your backend is taking longer than 30 seconds because:
- Redis is running (adds latency)
- Kafka might be initializing
- Database queries on first request
- Cold start delays

60 seconds gives enough time for everything to initialize.

---

## If Still Not Working

### Check Backend is Running
```powershell
curl http://localhost:8080/api/coupons
```

### Check Browser Console
Press F12 and look for errors

### Check Network Tab
F12 → Network → Try coupon → Look for `/api/coupons/validate`

---

**This is the FINAL fix - just copy these 3 files!**
