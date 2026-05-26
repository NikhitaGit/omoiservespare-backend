# 🎯 Visual Guide: Timeout Fix

## The ONE Line Causing All Problems

### File: `axiosInstance.js` (Line 13)

```diff
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
- timeout: 10000,
+ timeout: 30000,
  withCredentials: true
});
```

**That's it!** Change `10000` to `30000`

---

## Additional Safety: Add Timeouts to API Calls

### File: `canteenApi.js`

```diff
export const fetchCanteens = async () => {
+ try {
-   const res = await api.get("/api/canteens");
+   const res = await api.get("/api/canteens", {
+     timeout: 30000,
+   });
    return res.data;
+ } catch (error) {
+   console.error("Error fetching canteens:", error);
+   throw error;
+ }
};
```

### File: `couponApi.js`

```diff
export const validateCoupon = async (couponCode, orderValue, restaurantId = null) => {
  try {
    const response = await api.post(
      "/api/coupons/validate",
      {
        couponCode,
        orderValue,
        restaurantId,
-     }
+     },
+     {
+       timeout: 30000,
+     }
    );
    return response.data;
  } catch (error) {
    console.error("Failed to validate coupon:", error);
    throw error;
  }
};
```

---

## Test Checklist

After making changes:

- [ ] Changed `timeout: 10000` to `timeout: 30000` in `axiosInstance.js`
- [ ] Added timeout to `fetchCanteens()` in `canteenApi.js`
- [ ] Added timeout to `fetchMenu()` in `canteenApi.js`
- [ ] Added timeout to all functions in `couponApi.js`
- [ ] Saved all files
- [ ] Restarted frontend (`npm start`)
- [ ] Cleared browser cache (F12 → Hard Reload)
- [ ] Tested loading canteens
- [ ] Tested applying coupon

---

## Expected Result

✅ **Before:** Timeout after 10 seconds  
✅ **After:** Works smoothly, waits up to 30 seconds

---

**Copy the fixed files from `frontend-integration/` folder if you want the complete solution!**
