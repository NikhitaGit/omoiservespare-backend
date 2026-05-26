# 📋 Copy These 2 Files to Fix Login

## The Problem
❌ 400 Bad Request error when verifying OTP
❌ Missing `X-Device-Id` header in requests

## The Solution
✅ Updated 2 files to automatically add device ID to all requests

---

## File 1: axiosInstance.js

**Copy from:** `frontend-integration/axiosInstance.js`
**Copy to:** `<your-react-app>/src/api/axiosInstance.js`

**What changed:**
- Added device ID generation and storage
- Automatically adds `X-Device-Id` header to ALL requests
- No manual header management needed

---

## File 2: authApi.js

**Copy from:** `frontend-integration/authApi.js`
**Copy to:** `<your-react-app>/src/api/authApi.js`

**What changed:**
- Removed duplicate device ID logic
- Simplified OTP verification
- Relies on axiosInstance for headers

---

## Quick Copy Commands

### Windows PowerShell
```powershell
# Replace <your-react-app> with your actual frontend folder path
Copy-Item frontend-integration\axiosInstance.js <your-react-app>\src\api\
Copy-Item frontend-integration\authApi.js <your-react-app>\src\api\
```

### Manual Copy
1. Open `frontend-integration/axiosInstance.js`
2. Copy entire content
3. Paste into `<your-react-app>/src/api/axiosInstance.js`
4. Save

5. Open `frontend-integration/authApi.js`
6. Copy entire content
7. Paste into `<your-react-app>/src/api/authApi.js`
8. Save

---

## After Copying

### 1. Clear Browser Data (IMPORTANT!)
- Open DevTools (F12)
- Application tab → Clear storage
- Check all boxes → Clear site data

### 2. Restart Frontend
```bash
# Stop current dev server (Ctrl+C)
npm run dev
```

### 3. Test Login
1. Go to login page
2. Enter:
   - Company: `Omoiservespare Pvt Ltd`
   - Email: `nikita.a@omoikaneinnovations.com`
3. Click "Log In"
4. Check email for OTP
5. Enter OTP
6. Click "CONFIRM"
7. Should redirect to `/home` ✅

---

## Verify It's Working

### Check Console (F12)
You should see:
```
Created new device ID: <uuid>
Request headers: {X-Device-Id: "<uuid>", ...}
Token saved successfully as 'token'
```

### Check Network Tab
1. Look for `/api/auth/verify-otp` request
2. Request Headers should include: `X-Device-Id: <uuid>`
3. Response should include: `accessToken: "eyJ..."`

### Check localStorage
1. DevTools → Application → Local Storage
2. Should see:
   - `deviceId`: `<uuid>`
   - `token`: `eyJ...`
   - `userEmail`: `nikita.a@omoikaneinnovations.com`

---

## Still Getting Errors?

### 400 Bad Request
- Did you clear browser cache?
- Did you copy both files?
- Is backend running on port 8080?

### No OTP Received
- Check backend logs
- Verify email configuration
- Check spam folder

### Token Not Saved
- Check console for errors
- Verify response has `accessToken`
- Clear localStorage and try again

---

## Test Script Available

Run automated test:
```powershell
.\test-login-fix.ps1
```

This will:
1. Test login endpoint
2. Prompt for OTP
3. Test OTP verification
4. Verify token generation
5. Test protected endpoint access

---

**Status:** ✅ Ready to Copy
**Files to Copy:** 2
**Time Required:** 2 minutes
**Difficulty:** Easy
