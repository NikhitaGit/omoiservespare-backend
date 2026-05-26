# 🎯 Final Frontend Fix - Copy These Exact Files

## The Issue

Your coupon validation is timing out at 30 seconds. This is a **frontend-only fix**.

## Solution: 3 Files to Update

### File 1: axiosInstance.js

**Replace your entire `axiosInstance.js` with this:**

```javascript
import axios from "axios";

function getDeviceId() {
  let deviceId = localStorage.getItem("deviceId");
  if (!deviceId) {
    deviceId = crypto.randomUUID();
    localStorage.setItem("deviceId", deviceId);
  }
  return deviceId;
}

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 60000, // 60 seconds - INCREASED
  withCredentials: true
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  config.headers["X-Device-Id"] = getDeviceId();
  return config;
});

let isRefreshing = false;
let refreshPromise = null;

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (!error.response) {
      return Promise.reject(error);
    }

    const { status } = error.response;
    const originalRequest = error.config;
    const isUnauthorized = status === 401;
    const isRefreshCall = originalRequest?.url?.includes("/api/auth/refresh");
    const isApiCall = originalRequest?.url?.startsWith("/api");

    if (isUnauthorized && isRefreshCall) {
      localStorage.removeItem("token");
      localStorage.removeItem("deviceId");
      localStorage.removeItem("userEmail");
      localStorage.removeItem("companyName");
      localStorage.removeItem("phoneNumber");
      localStorage.removeItem("accountType");
      window.location.href = "/login";
      return Promise.reject(error);
    }

    if (isUnauthorized && isApiCall && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        if (!isRefreshing) {
          isRefreshing = true;
          refreshPromise = api
            .post("/api/auth/refresh")
            .then((res) => {
              const newToken = res.data.accessToken;
              localStorage.setItem("token", newToken);
              return newToken;
            })
            .finally(() => {
              isRefreshing = false;
              refreshPromise = null;
            });
        }

        const newAccessToken = await refreshPromise;
        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        localStorage.removeItem("token");
        localStorage.removeItem("deviceId");
        localStorage.removeItem("userEmail");
        localStorage.removeItem("companyName");
        localStorage.removeItem("phoneNumber");
        localStorage.removeItem("accountType");
        window.location.href = "/login";
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

---

### File 2: couponApi.js

**Replace your entire `couponApi.js` with this:**

```javascript
import api from "./axiosInstance";

export const getAllCoupons = async () => {
  try {
    const response = await api.get("/api/coupons", {
      timeout: 60000, // 60 seconds
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
      timeout: 60000, // 60 seconds
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
        timeout: 60000, // 60 seconds
      }
    );
    return response.data;
  } catch (error) {
    console.error("Failed to validate coupon:", error);
    // Return a user-friendly error
    if (error.code === 'ECONNABORTED') {
      throw new Error("Request timed out. Please try again.");
    }
    throw error;
  }
};
```

---

### File 3: canteenApi.js

**Replace your entire `canteenApi.js` with this:**

```javascript
import api from "./axiosInstance";

export const fetchCanteens = async () => {
  try {
    const res = await api.get("/api/canteens", {
      timeout: 60000, // 60 seconds
    });
    return res.data;
  } catch (error) {
    console.error("Error fetching canteens:", error);
    throw error;
  }
};

export const fetchMenu = async (canteenId) => {
  try {
    const res = await api.get(`/api/menu/${canteenId}`, {
      timeout: 60000, // 60 seconds
    });
    return res.data;
  } catch (error) {
    console.error(`Error fetching menu for canteen ${canteenId}:`, error);
    throw error;
  }
};
```

---

## Steps to Apply

1. **Open your frontend project**

2. **Replace these 3 files:**
   - `src/api/axiosInstance.js`
   - `src/api/couponApi.js`
   - `src/api/canteenApi.js`

3. **Save all files**

4. **Restart your frontend:**
   ```bash
   # Stop current frontend (Ctrl+C)
   npm start
   # or
   yarn start
   ```

5. **Clear browser cache:**
   - Press F12
   - Right-click refresh button
   - Select "Empty Cache and Hard Reload"

6. **Test coupon validation**

---

## What Changed?

### Main Change: Timeout Increased
- **Before:** 30 seconds (30000ms)
- **After:** 60 seconds (60000ms)

### Why 60 Seconds?
- Backend might be slow on first request (cold start)
- Redis/Kafka initialization takes time
- Database queries might be slow
- 60 seconds gives enough time for everything

---

## If Still Not Working

### Check Backend Logs
Look in your backend terminal for errors when you try to apply coupon.

### Check Network Tab
1. Press F12 in browser
2. Go to Network tab
3. Try applying coupon
4. Look for `/api/coupons/validate` request
5. Check if it's:
   - Pending (still waiting)
   - Failed (red)
   - Success (green)

### Test Backend Directly
```powershell
# Test if backend is responding
curl http://localhost:8080/api/coupons
```

---

## Summary

**3 files to update:**
1. ✅ `axiosInstance.js` - 60-second timeout
2. ✅ `couponApi.js` - 60-second timeout + error handling
3. ✅ `canteenApi.js` - 60-second timeout

**Then:**
- Restart frontend
- Clear browser cache
- Test coupons

**This is a frontend-only fix - no backend changes needed!**
