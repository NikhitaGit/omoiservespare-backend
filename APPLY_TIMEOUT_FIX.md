# 🔧 Apply Timeout Fix to Your Frontend

## Problem Found

Your `axiosInstance.js` has:
```javascript
timeout: 10000, // 10 seconds - TOO SHORT!
```

This is causing all your API calls to timeout after 10 seconds.

## Solution: 3 Simple Changes

### Change 1: Update axiosInstance.js

**Find this line:**
```javascript
timeout: 10000,
```

**Change it to:**
```javascript
timeout: 30000, // 30 seconds
```

**Location:** Line 13 in your `axiosInstance.js`

---

### Change 2: Update canteenApi.js

**Replace your entire file with this:**

```javascript
import api from "./axiosInstance";

/* 🏪 FETCH ALL CANTEENS (Public) */
export const fetchCanteens = async () => {
  try {
    const res = await api.get("/api/canteens", {
      timeout: 30000, // 30-second timeout
    });
    return res.data;
  } catch (error) {
    console.error("Error fetching canteens:", error);
    throw error;
  }
};

/* 📋 FETCH MENU BY CANTEEN (Public / Protected later) */
export const fetchMenu = async (canteenId) => {
  try {
    const res = await api.get(`/api/menu/${canteenId}`, {
      timeout: 30000, // 30-second timeout
    });
    return res.data;
  } catch (error) {
    console.error(`Error fetching menu for canteen ${canteenId}:`, error);
    throw error;
  }
};
```

---

### Change 3: Update couponApi.js

**Add `timeout: 30000` to each API call:**

```javascript
import api from "./axiosInstance";

export const getAllCoupons = async () => {
  try {
    const response = await api.get("/api/coupons", {
      timeout: 30000, // ADD THIS
    });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch coupons:", error);
    throw error;
  }
};

export const getAvailableCoupons = async (orderValue, restaurantId = null) => {
  try {
    const params = { orderValue };
    if (restaurantId) {
      params.restaurantId = restaurantId;
    }

    const response = await api.get("/api/coupons/available", {
      params,
      timeout: 30000, // ADD THIS
    });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch available coupons:", error);
    throw error;
  }
};

export const validateCoupon = async (
  couponCode,
  orderValue,
  restaurantId = null
) => {
  try {
    const response = await api.post(
      "/api/coupons/validate",
      {
        couponCode,
        orderValue,
        restaurantId,
      },
      {
        timeout: 30000, // ADD THIS
      }
    );
    return response.data;
  } catch (error) {
    console.error("Failed to validate coupon:", error);
    throw error;
  }
};
```

---

## Quick Copy-Paste Option

I've created fixed versions of all your files:

1. **axiosInstance_TIMEOUT_FIXED.js** - Copy to your `axiosInstance.js`
2. **canteenApi_TIMEOUT_FIXED.js** - Copy to your `canteenApi.js`
3. **couponApi_TIMEOUT_FIXED.js** - Copy to your `couponApi.js`

**Location:** `frontend-integration/` folder

---

## After Making Changes

1. **Save all files**
2. **Restart your frontend:**
   ```bash
   npm start
   # or
   yarn start
   ```
3. **Clear browser cache:**
   - Press F12
   - Right-click refresh button
   - Select "Empty Cache and Hard Reload"

4. **Test:**
   - Load canteens page
   - Apply a coupon
   - Should work without timeout!

---

## What Changed?

### Before:
```javascript
timeout: 10000, // 10 seconds - times out!
```

### After:
```javascript
timeout: 30000, // 30 seconds - enough time
```

---

## Summary

**3 files to update:**
1. ✅ `axiosInstance.js` - Change line 13: `timeout: 10000` → `timeout: 30000`
2. ✅ `canteenApi.js` - Add `timeout: 30000` to both functions
3. ✅ `couponApi.js` - Add `timeout: 30000` to all 3 functions

**Then restart your frontend and test!**

---

**This is the ONLY change needed** - your backend is already working fine!
