# ✅ Admin Dashboard - Vendor Access Fixed

## Problem

Vendors couldn't access the admin dashboard due to:
1. **CORS blocking** - Frontend on port 5174 but CORS only allowed 5173
2. **Role restriction** - Dashboard only allowed ADMIN role, not VENDOR

## Fixes Applied

### 1. CORS Configuration (SecurityConfig.java)

**Before:**
```java
config.setAllowedOrigins(List.of("http://localhost:5173"));
```

**After:**
```java
config.setAllowedOrigins(List.of("http://localhost:5173", "http://localhost:5174"));
```

### 2. Admin Dashboard Access (AdminDashboardController.java)

**Before:**
```java
@RequireRole(Role.ADMIN)  // ❌ Only ADMIN
public ResponseEntity<AdminDashboardDTO> getDashboard(...)
```

**After:**
```java
@RequireRole({Role.ADMIN, Role.VENDOR})  // ✅ Both ADMIN and VENDOR
public ResponseEntity<AdminDashboardDTO> getDashboard(...)
```

## Who Can Access Admin Dashboard Now?

✅ **ADMIN** - Full access
✅ **VENDOR** - Full access
❌ **USER** - No access (403 Forbidden)

## How to Apply

### Step 1: Restart Backend

```cmd
mvn spring-boot:run
```

Or if already running, stop (Ctrl+C) and restart.

### Step 2: Clear Browser Data

1. Press F12
2. Application tab → Clear site data
3. Close DevTools (F12)
4. Refresh page (F5)

### Step 3: Login as Vendor

1. Go to http://localhost:5174/login
2. Login with vendor credentials
3. Navigate to Admin Dashboard
4. Should work now!

## Testing

### Test as Vendor:

```powershell
# Login as vendor
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{
    "companyName": "YourCompany",
    "email": "vendor@company.com",
    "phoneNumber": "+1234567890",
    "accountType": "PERSONAL"
  }'

# Get OTP from backend console, then verify
curl -X POST http://localhost:8080/api/auth/verify-otp `
  -H "Content-Type: application/json" `
  -H "X-Device-Id: test-device-123" `
  -d '{
    "email": "vendor@company.com",
    "otp": "1234"
  }'

# Access dashboard (use token from verify-otp response)
curl http://localhost:8080/api/admin/dashboard?range=week `
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## What Changed in Files

### SecurityConfig.java
- Line 75: Added port 5174 to allowed origins

### AdminDashboardController.java
- Line 49: Changed from `@RequireRole(Role.ADMIN)` to `@RequireRole({Role.ADMIN, Role.VENDOR})`
- Line 41: Updated comment from "ADMIN ONLY" to "ADMIN & VENDOR ACCESS"

## Expected Behavior

### Before Fix:
- Vendor login → Navigate to dashboard → CORS error
- Frontend shows: "Failed to load dashboard. Please try again."
- Console shows: "Access to XMLHttpRequest blocked by CORS policy"

### After Fix:
- Vendor login → Navigate to dashboard → Dashboard loads successfully
- Shows revenue, orders, trending items, etc.
- Real-time updates via WebSocket

## Troubleshooting

### Still getting CORS error?

1. Check backend is running on port 8080
2. Check frontend is on port 5173 or 5174
3. Restart backend after changes
4. Clear browser cache

### Still getting 403 Forbidden?

1. Check you're logged in as VENDOR or ADMIN (not USER)
2. Check token is valid (not expired)
3. Check browser console for token value
4. Try logging out and logging in again

### Dashboard shows "No data available"?

1. Check if there are orders in the database
2. Try different date ranges (Today, This Week, etc.)
3. Check backend console for errors

---

**Vendors can now access the admin dashboard!** 🎉
