# ✅ Complete Authentication Fix

## Problem
Getting **500 Internal Server Error** because the frontend was calling the old `/api/auth/login` endpoint which no longer exists after we switched to UnifiedAuthController.

## Root Cause
The old `AuthController` was removed/disabled, but the frontend `authApi.js` was still calling `/api/auth/login` instead of the new `/api/auth/user/login` endpoint.

## Solution
Updated `authApi.js` to use the correct UnifiedAuth endpoints:
- `/api/auth/user/login` - for User/Admin login (sends OTP)
- `/api/auth/verify-otp` - for OTP verification

## Fixed File

Copy this file to your React project:

**frontend-integration/authApi.js** → **your-react-app/src/api/authApi.js**

## Complete Flow

### 1. User/Admin Login (Port 5173)
```
User enters: Company + Email/Phone
  ↓
Frontend calls: POST /api/auth/user/login
  ↓
Backend validates and sends OTP
  ↓
User redirected to OTP page
```

### 2. OTP Verification
```
User enters: 4-digit OTP
  ↓
Frontend calls: POST /api/auth/verify-otp
  ↓
Backend validates OTP
  ↓
Returns JWT token
  ↓
User redirected to /home
```

### 3. Vendor Login (Port 5174)
```
Vendor enters: Email + Password
  ↓
Frontend calls: POST /api/auth/vendor/login
  ↓
Backend validates credentials
  ↓
Returns JWT token immediately
  ↓
Vendor redirected to /monitor
```

## Quick Fix Steps

1. **Copy the fixed file**:
   ```powershell
   Copy-Item frontend-integration\authApi.js your-react-app\src\api\authApi.js
   ```

2. **Restart React dev server**:
   ```
   Ctrl+C (stop)
   npm run dev (start)
   ```

3. **Clear browser cache**:
   ```
   Ctrl+Shift+R (hard refresh)
   ```

4. **Test login**:
   - Go to http://localhost:5173/login
   - Enter:
     - Company: `Omoiservespare Pvt Ltd`
     - Email: `nikita.a@omoikaneinnovations.com`
   - Click "Log In"
   - Check backend console for OTP
   - Enter OTP and verify

## Test Credentials

### User/Admin (OTP Login - Port 5173)
- **Company**: Omoiservespare Pvt Ltd
- **Email**: nikita.a@omoikaneinnovations.com
- **Phone**: +91-9876543210
- **OTP**: Check backend logs (look for: `OTP for nikita.a@omoikaneinnovations.com: XXXX`)

### Vendor (Password Login - Port 5174)
- **Email**: vendor@restaurant.com
- **Password**: vendor123

## API Endpoints Reference

### UnifiedAuthController Endpoints:
```
POST /api/auth/user/login       - User/Admin login (sends OTP)
POST /api/auth/vendor/login     - Vendor login (password)
POST /api/auth/verify-otp       - Verify OTP
POST /api/auth/refresh          - Refresh token
GET  /api/auth/health           - Health check
```

### Old Endpoints (REMOVED):
```
❌ POST /api/auth/login          - No longer exists
❌ POST /api/auth/verify-otp     - Now uses UnifiedAuthController
```

## Expected Responses

### Login Request:
```json
{
  "success": true,
  "message": "OTP sent successfully to your email",
  "otpRequired": true
}
```

### OTP Verification:
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "eyJ...",
  "refreshToken": "...",
  "userId": 1,
  "email": "nikita.a@omoikaneinnovations.com",
  "role": "ADMIN",
  "companyName": "Omoiservespare Pvt Ltd",
  "phoneNumber": "+91-9876543210"
}
```

### Vendor Login:
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "eyJ...",
  "refreshToken": "...",
  "userId": 12,
  "email": "vendor@restaurant.com",
  "role": "VENDOR",
  "vendorStatus": "APPROVED",
  "restaurantName": "Test Restaurant"
}
```

## Troubleshooting

### Error 500 on /api/auth/login
**Cause**: Using old endpoint
**Fix**: Update authApi.js to use `/api/auth/user/login`

### Error 400 on OTP verification
**Cause**: Wrong data format or expired OTP
**Fix**: 
- Use the OTP from backend logs
- Request new OTP if expired (5 min timeout)
- Ensure sending `{email, otp}` format

### "Invalid or expired OTP"
**Cause**: Wrong OTP or timeout
**Fix**: 
- Check backend logs for correct OTP
- OTP expires after 5 minutes
- Request new login to get fresh OTP

### Token not saved
**Cause**: Response format mismatch
**Fix**: 
- Check if `result.accessToken` exists
- Verify localStorage.setItem is called
- Check browser console for errors

## Verification Checklist

- [ ] Backend running on port 8080
- [ ] Frontend running on port 5173 (User) or 5174 (Vendor)
- [ ] authApi.js updated with new endpoints
- [ ] React dev server restarted
- [ ] Browser cache cleared
- [ ] Can request OTP successfully
- [ ] OTP appears in backend logs
- [ ] OTP verification returns JWT token
- [ ] Token saved to localStorage
- [ ] Redirect to /home works

## Files Changed

1. **frontend-integration/authApi.js** - Updated endpoints
2. **Backend**: No changes needed (UnifiedAuthController already exists)

## Next Steps

1. ✅ Copy fixed authApi.js to your React project
2. ✅ Restart React dev server
3. ✅ Test User/Admin login flow
4. ✅ Test Vendor login flow
5. ⏭️ Test protected routes with JWT
6. ⏭️ Implement token refresh
7. ⏭️ Add proper error handling
8. ⏭️ Configure email service for OTP delivery

## Success Criteria

✅ User can login with company + email
✅ OTP is generated and logged
✅ OTP verification returns JWT token
✅ Token is saved to localStorage
✅ User is redirected to /home
✅ Vendor can login with email + password
✅ Vendor is redirected to /monitor
