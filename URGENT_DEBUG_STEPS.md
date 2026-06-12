# 🚨 URGENT: Debug Location 401 Issue

Your backend is running but NO authentication logs appear. Let's debug systematically.

## Step 1: Open Test Page

1. Open `test-location-with-token.html` in your browser
2. Click all three buttons:
   - "Check Token in LocalStorage"
   - "Test POST /api/location"
   - "Test Raw Fetch"

3. **Take a screenshot** of the results and share it with me

## Step 2: Check What You See

### If "NO TOKEN FOUND":
**Problem:** You're not logged in
**Solution:** Login to your React app first, then retest

### If "TOKEN EXPIRED":
**Problem:** Your token is expired
**Solution:** Login again to get a new token

### If Token Exists But API Returns 401:
**Problem:** Backend authentication is failing
**Action:** Check backend logs (should see JwtAuthFilter logs)

## Step 3: Check Backend Logs

When you click "Test Raw Fetch", you should see these logs in backend console:

```
🔐 JwtAuthFilter running for: POST /api/location
✅ Token found in Authorization header for path: /api/location
✅ Valid token - email: your@email.com
✅ Set currentUser attribute: userId=1
```

### If You Don't See These Logs:
- Backend is NOT receiving the request
- Check if React app is running on correct port
- Check browser console for CORS errors

### If You See "⚠️ No token found":
- Token is not being sent in Authorization header
- Check your React app's axiosInstance.js

### If You See "❌ Invalid token":
- Token is malformed or expired
- Login again to get fresh token

## Step 4: Check Your React App's axiosInstance

**Where is your axiosInstance.js?**

It should be in one of these locations:
- `src/api/axiosInstance.js`
- `src/utils/axiosInstance.js`  
- `src/config/axiosInstance.js`

**Open that file** and verify it looks EXACTLY like this:

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
  baseURL: import.meta.env.VITE_API_BASE_URL || "http://localhost:8080",
  timeout: 180000,
  withCredentials: true
});

api.interceptors.request.use((config) => {
  config.headers["X-Device-Id"] = getDeviceId();
  
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    // NO automatic redirect - just log and return error
    console.error("API Error:", error.response?.status, error.response?.data);
    return Promise.reject(error);
  }
);

export default api;
```

**If it's different → Replace it with the correct version**

## Step 5: Check React App Import

In your `LocationPicker.jsx` or wherever you're calling the location API, verify the import:

```javascript
import api from './api/axiosInstance';  // or wherever your file is

// Usage:
await api.post('/api/location', {
  type: 'MANUAL',
  latitude: lat,
  longitude: lng,
  address: 'Test'
});
```

## Step 6: Report Back

After running the test page, tell me:

1. **Token status:** Found / Expired / Missing
2. **API test result:** Success / 401 / Network Error
3. **Backend logs:** Did you see JwtAuthFilter logs? (Yes/No)
4. **React app location:** Where is your axiosInstance.js file?

---

## Quick Actions

### If Test Page Works But React App Doesn't:
→ Your React app is using a DIFFERENT axiosInstance file

### If Test Page Also Returns 401:
→ Backend authentication is broken (check SecurityConfig)

### If No Backend Logs Appear:
→ Request not reaching backend (CORS / network issue)

---

**Open test-location-with-token.html in browser and share results!**
