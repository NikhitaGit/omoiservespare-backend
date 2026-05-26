# Feedback 401 Error - Complete Fix Guide

## Problem Summary
- ✅ Feedback submission works (201 CREATED)
- ❌ Feedback list retrieval fails (401 Unauthorized)
- ❌ CSV/Excel downloads fail (401 Unauthorized)

## Root Cause
The frontend is not sending the JWT authentication token correctly when fetching feedback data.

## Solution Steps

### Step 1: Run Diagnostic Script
```powershell
.\diagnose-feedback-token.ps1
```

This will:
- Check if backend is running
- Test login and get a valid token
- Test all feedback endpoints
- Show you the exact token format needed

### Step 2: Update Your Frontend Component

Replace your current `App_Feedback.jsx` with `App_Feedback_COMPLETE_FIX.jsx`:

```bash
copy App_Feedback_COMPLETE_FIX.jsx src\main\frontend\src\components\App_Feedback.jsx
```

Or manually copy the content.

### Step 3: Verify Token Storage in Your Login Component

Your login component MUST store the token in localStorage after successful login:

```javascript
// After successful OTP verification
const response = await fetch("http://localhost:8080/api/auth/verify-otp", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email, otp, accountType })
});

const data = await response.json();

// CRITICAL: Store the token
localStorage.setItem("token", data.token);
// OR
localStorage.setItem("authToken", data.token);
// OR
localStorage.setItem("jwt", data.token);
```

### Step 4: Test the Fix

1. **Login first** as a PROFESSIONAL user:
   - Email: nikita.a@omoikaneinnovations.com
   - Account Type: PROFESSIONAL

2. **Check browser console** (F12):
   - Look for the debug info panel
   - Verify token is found
   - Check API response status

3. **Submit feedback** as any user to create test data

4. **View feedback** as PROFESSIONAL user:
   - Should see the feedback list
   - Should be able to mark as reviewed
   - Should be able to download CSV/Excel

## Common Issues & Solutions

### Issue 1: "No JWT token found"
**Solution:** Make sure you're logged in and the token is stored in localStorage.

Check in browser console:
```javascript
console.log(localStorage.getItem("token"));
console.log(localStorage.getItem("authToken"));
console.log(localStorage.getItem("jwt"));
```

### Issue 2: "401 Unauthorized" even with token
**Possible causes:**
1. Token expired (tokens expire after a certain time)
2. Token format incorrect (should start with "eyJ")
3. Backend not recognizing the token

**Solution:** 
- Logout and login again to get a fresh token
- Check backend logs for JWT validation errors

### Issue 3: "403 Forbidden"
**Cause:** User is not a PROFESSIONAL account type.

**Solution:** Only PROFESSIONAL users can view feedback. Regular users can only submit feedback.

### Issue 4: Downloads not working
**Cause:** Same as feedback list - missing or invalid token.

**Solution:** Follow steps 1-3 above to fix token handling.

## Testing Checklist

- [ ] Backend running on port 8080
- [ ] Can login successfully
- [ ] Token stored in localStorage
- [ ] Can submit feedback (any user)
- [ ] Can view feedback list (PROFESSIONAL only)
- [ ] Can mark feedback as reviewed (PROFESSIONAL only)
- [ ] Can download CSV (PROFESSIONAL only)
- [ ] Can download Excel (PROFESSIONAL only)

## Debug Panel

The new component includes a debug panel that shows:
- Token search process
- API request details
- Response status
- Error messages

Click "🔧 Debug Info" to expand and see what's happening.

## Backend Logs to Check

Look for these in your backend console:

```
✓ Good:
INFO  c.o.o.controller.FeedbackController : Feedback retrieval request from: nikita.a@omoikaneinnovations.com
INFO  c.o.o.service.FeedbackService       : Fetching feedback for company: Omoiservespare Pvt Ltd

✗ Bad:
WARN  o.s.s.w.a.www.BearerTokenAuthenticationFilter : Authentication failed: Invalid token
ERROR c.o.o.security.JwtTokenProvider    : JWT token validation failed
```

## Quick Test Commands

### Test feedback submission (any user):
```powershell
$token = "YOUR_TOKEN_HERE"
$body = @{
    rating = 4
    comments = "Test feedback"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/feedback" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
  -Body $body
```

### Test feedback retrieval (PROFESSIONAL only):
```powershell
$token = "YOUR_TOKEN_HERE"
Invoke-RestMethod -Uri "http://localhost:8080/api/feedback?page=0&size=20" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $token"}
```

## Need More Help?

1. Run the diagnostic script: `.\diagnose-feedback-token.ps1`
2. Check the debug panel in the UI
3. Check browser console (F12) for errors
4. Check backend logs for authentication errors
5. Verify you're using a PROFESSIONAL account

## Summary

The fix involves:
1. ✅ Enhanced token detection in frontend
2. ✅ Better error messages
3. ✅ Debug panel for troubleshooting
4. ✅ Proper token handling in all API calls
5. ✅ Diagnostic script for testing

After applying these fixes, your feedback system should work completely!
