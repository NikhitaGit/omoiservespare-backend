# 🔧 Frontend Timeout Fix Guide

## Problem Identified

The timeout errors you're seeing are coming from the **frontend**, not the backend. The browser console shows:
```
AxiosError: timeout of 10000ms exceeded
at async fetchCanteens (canteenApi.js:5:15)
```

## Root Cause

Your frontend API calls have a **10-second timeout** (10000ms), which is too short when:
- Backend is starting up
- Database queries are slow
- Network is slow
- Kafka/Redis are initializing

## Solution: Increase Frontend Timeouts

### Files Created:

1. ✅ **canteenApi.js** - With 30-second timeout
2. ✅ **couponApi.js** - With 30-second timeout  
3. ✅ **CanteenList_FIXED.jsx** - With better error handling

## Step-by-Step Fix

### Step 1: Copy the API Files

Copy these files to your frontend project:

```bash
# From backend project to your frontend
frontend-integration/canteenApi.js    → your-frontend/src/api/canteenApi.js
frontend-integration/couponApi.js     → your-frontend/src/api/couponApi.js
frontend-integration/CanteenList_FIXED.jsx → your-frontend/src/pages/CanteenList.jsx
```

### Step 2: Update Your CanteenList Component

Replace your current `CanteenList.jsx` with `CanteenList_FIXED.jsx`

**Key improvements:**
- ✅ Better error handling
- ✅ Retry button on errors
- ✅ Loading states
- ✅ Search with "no results" message

### Step 3: Create API Files (if missing)

If you don't have `canteenApi.js` in your frontend, create it:

**Location:** `your-frontend/src/api/canteenApi.js`

```javascript
import api from './axiosInstance';

export const fetchCanteens = async () => {
  try {
    const response = await api.get('/api/canteens', {
      timeout: 30000, // 30 seconds
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching canteens:', error);
    throw error;
  }
};
```

### Step 4: Update Coupon API Calls

If you have coupon-related API calls, make sure they use the new `couponApi.js`:

```javascript
import { validateCoupon } from '../api/couponApi';

// In your Cart component
const handleApplyCoupon = async () => {
  try {
    const result = await validateCoupon(couponCode, orderTotal);
    if (result.valid) {
      setDiscount(result.discount);
      setMessage(result.message);
    } else {
      setError(result.message);
    }
  } catch (error) {
    setError('Failed to apply coupon. Please try again.');
  }
};
```

## What Changed?

### Before (10s timeout):
```javascript
// Default axios timeout or hardcoded 10000ms
const response = await api.get('/api/canteens');
// Times out after 10 seconds
```

### After (30s timeout):
```javascript
const response = await api.get('/api/canteens', {
  timeout: 30000, // 30 seconds
});
// More time for backend to respond
```

## Additional Improvements

### 1. Global Axios Timeout (Optional)

Update `axiosInstance.js` to set a default timeout:

```javascript
const api = axios.create({
  baseURL: 'http://localhost:8080',
  timeout: 30000, // 30 seconds default
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});
```

### 2. Loading Indicators

The fixed CanteenList shows proper loading states:
- "Loading canteens..." while fetching
- Error message with retry button on failure
- "No canteens available" when empty

### 3. Error Handling

Better error messages:
```javascript
catch (err) {
  setError(err.message || "Failed to load. Please try again.");
}
```

## Testing

### Test 1: Normal Load
1. Open your app
2. Navigate to canteens page
3. Should load within 2-5 seconds

### Test 2: Slow Backend
1. Restart backend (slow startup)
2. Try loading canteens immediately
3. Should wait up to 30 seconds before timeout

### Test 3: Coupon Validation
1. Add items to cart
2. Apply coupon code
3. Should validate within 2-5 seconds

## Troubleshooting

### Still Getting Timeouts?

1. **Check backend is running:**
   ```powershell
   curl http://localhost:8080/actuator/health
   ```

2. **Check network tab in browser:**
   - F12 → Network tab
   - Look for failed requests
   - Check response times

3. **Increase timeout further:**
   ```javascript
   timeout: 60000, // 60 seconds
   ```

4. **Check backend logs:**
   - Look for slow queries
   - Check for Kafka/Redis connection issues

### Backend Taking Too Long?

If backend consistently takes > 10 seconds:

1. **Start Kafka first** (if using Kafka):
   ```powershell
   .\start-kafka-quick.ps1
   ```

2. **Use no-kafka profile** (faster startup):
   ```powershell
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=no-kafka,no-redis
   ```

3. **Check database connection:**
   - Verify PostgreSQL is running
   - Check connection pool settings

## Summary

### Files to Update in Your Frontend:

1. ✅ `src/api/canteenApi.js` - Add 30s timeout
2. ✅ `src/api/couponApi.js` - Add 30s timeout
3. ✅ `src/pages/CanteenList.jsx` - Better error handling
4. ✅ `src/api/axiosInstance.js` - Optional: add default timeout

### Expected Results:

- ✅ No more 10-second timeouts
- ✅ Better error messages
- ✅ Retry functionality
- ✅ Smoother user experience

---

**Status:** ✅ Frontend timeout fix ready
**Impact:** Resolves timeout errors in canteen loading and coupon validation
