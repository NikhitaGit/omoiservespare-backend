# 📁 VISUAL GUIDE - WHERE TO COPY FILES

## Your Project Structure

```
your-workspace/
├── backend/                          ← You are here
│   └── frontend-integration/         ← Fixed files are here
│       ├── axiosInstance.js         ✅ COPY THIS
│       ├── authApi.js               ✅ COPY THIS
│       └── OtpVerification.jsx      ✅ COPY THIS
│
└── frontend/                         ← Your React project
    └── src/
        ├── api/
        │   ├── axiosInstance.js     ← REPLACE with fixed version
        │   └── authApi.js           ← REPLACE with fixed version
        └── components/
            └── OtpVerification.jsx  ← REPLACE with fixed version
```

## Copy Commands

### If frontend is in same parent folder:

```cmd
cd your-frontend-folder
copy ..\backend\frontend-integration\axiosInstance.js src\api\
copy ..\backend\frontend-integration\authApi.js src\api\
copy ..\backend\frontend-integration\OtpVerification.jsx src\components\
```

### If frontend is in different location:

```cmd
cd C:\path\to\your\frontend
copy C:\path\to\backend\frontend-integration\axiosInstance.js src\api\
copy C:\path\to\backend\frontend-integration\authApi.js src\api\
copy C:\path\to\backend\frontend-integration\OtpVerification.jsx src\components\
```

## What Each File Does

### 1. axiosInstance.js
**Location:** `src/api/axiosInstance.js`

**What it does:**
- Creates axios instance with base URL
- Adds token to ALL API requests automatically
- Handles 401 errors (auto-logout)
- Enables cookies (withCredentials)

**Key features:**
```javascript
// Request interceptor - adds token
config.headers.Authorization = `Bearer ${token}`;

// Response interceptor - handles 401
if (error.response.status === 401) {
  localStorage.clear();
  window.location.href = '/login';
}
```

### 2. authApi.js
**Location:** `src/api/authApi.js`

**What it does:**
- Exports `loginUser()` and `verifyOtp()` functions
- Adds `X-Device-Id` header (required by backend)
- Generates unique device ID
- Logs API responses for debugging

**Key features:**
```javascript
// Adds required header
headers: {
  'X-Device-Id': getDeviceId()
}

// Creates device ID
function getDeviceId() {
  let deviceId = localStorage.getItem('deviceId');
  if (!deviceId) {
    deviceId = 'device-' + Math.random().toString(36).substr(2, 9) + '-' + Date.now();
    localStorage.setItem('deviceId', deviceId);
  }
  return deviceId;
}
```

### 3. OtpVerification.jsx
**Location:** `src/components/OtpVerification.jsx`

**What it does:**
- Handles OTP input (4 digits)
- Validates OTP with backend
- Checks if accessToken exists before saving
- Saves token + user info to localStorage
- Better error handling and logging

**Key features:**
```javascript
// Validates token exists
if (result && result.accessToken) {
  localStorage.setItem("token", result.accessToken);
  // Save user info
  localStorage.setItem("userEmail", result.email);
  localStorage.setItem("companyName", result.companyName);
  // ... etc
  navigate("/home");
} else {
  console.error("No accessToken in response:", result);
  alert("Login failed: No access token received");
}
```

## After Copying

1. **Clear browser data:**
   - F12 → Application → Clear site data

2. **Restart frontend:**
   ```bash
   npm start
   ```

3. **Test login:**
   - Login with company name + email
   - Enter 4-digit OTP from backend console
   - Should redirect to /home
   - Navigate to other pages - should work!

## Troubleshooting

### If files don't exist in your frontend:

**Create the folders first:**
```cmd
cd your-frontend
mkdir src\api
mkdir src\components
```

**Then copy:**
```cmd
copy ..\backend\frontend-integration\axiosInstance.js src\api\
copy ..\backend\frontend-integration\authApi.js src\api\
copy ..\backend\frontend-integration\OtpVerification.jsx src\components\
```

### If you get "file not found":

**Check your current directory:**
```cmd
cd
```

**Navigate to frontend:**
```cmd
cd C:\full\path\to\your\frontend
```

**Then copy with full paths:**
```cmd
copy C:\full\path\to\backend\frontend-integration\axiosInstance.js src\api\
copy C:\full\path\to\backend\frontend-integration\authApi.js src\api\
copy C:\full\path\to\backend\frontend-integration\OtpVerification.jsx src\components\
```

## Verification

After copying, check that files exist:

```cmd
dir src\api\axiosInstance.js
dir src\api\authApi.js
dir src\components\OtpVerification.jsx
```

All 3 should show file size and date.

---

**Just copy the 3 files and your login will work!** 🚀
