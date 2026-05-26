# Solution: Fix 401 Unauthorized Error

## Problem
Feedback is not showing because of **401 Unauthorized** error.

## Root Cause
The JWT token is either:
1. Not being found in localStorage
2. Stored with a different key name
3. Invalid or expired

## Solution (Choose One)

### Option 1: Use Auto-Detect Version (RECOMMENDED)

Replace your `App_Feedback.jsx` with `App_Feedback_FIXED_401.jsx`

This version automatically finds your token by checking common key names:
- "token"
- "authToken"
- "jwt"
- "accessToken"
- "jwtToken"

**Benefits:**
- ✅ Automatically finds your token
- ✅ Better error messages
- ✅ Console logging for debugging
- ✅ Shows exact error details

### Option 2: Manual Fix

1. **Find your token key:**
   - Open browser console (F12)
   - Run: `Object.keys(localStorage)`
   - Look for your JWT token key

2. **Update line 11 in App_Feedback.jsx:**
   ```javascript
   const token = localStorage.getItem("YOUR_KEY_HERE");
   ```

## Verification Steps

### Step 1: Run Diagnostic Script

```powershell
.\diagnose-feedback-401.ps1
```

This will:
- Check if backend is running
- Test your JWT token
- Show feedback data if successful
- Identify the exact problem

### Step 2: Check Browser Console

1. Open your feedback page
2. Press F12 to open DevTools
3. Go to Console tab
4. Look for these messages:

**If token is found:**
```
✓ Token found with key: "token"
Fetching feedback from: http://localhost:8080/api/feedback...
Response status: 200
✓ Feedback data received: {...}
```

**If token is NOT found:**
```
✗ No JWT token found in localStorage
Available keys: [...]
```

### Step 3: Verify Token in Browser

Run this in browser console:
```javascript
// Check all localStorage keys
for (let i = 0; i < localStorage.length; i++) {
  const key = localStorage.key(i);
  const value = localStorage.getItem(key);
  console.log(key + ":", value.substring(0, 50) + "...");
}
```

Look for a long string starting with "eyJ" - that's your JWT token!

## Common Issues & Fixes

### Issue 1: Token Not Found
**Symptom:** Console shows "No JWT token found"

**Fix:**
1. Make sure you're logged in
2. Check if login stores the token
3. Verify the token key name

### Issue 2: Token Expired
**Symptom:** 401 error even with token present

**Fix:**
1. Logout and login again
2. Get a fresh token
3. Tokens typically expire after 24 hours

### Issue 3: Wrong Account Type
**Symptom:** 403 Forbidden error

**Fix:**
- Only PROFESSIONAL users can view feedback
- Check your account type in database
- Login with a PROFESSIONAL account

### Issue 4: Backend Not Running
**Symptom:** Network error or connection refused

**Fix:**
```powershell
cd omoiservespare
mvnw spring-boot:run
```

## Testing After Fix

### Test 1: Check Token Detection
```javascript
// Run in browser console
const possibleKeys = ["token", "authToken", "jwt", "accessToken"];
for (const key of possibleKeys) {
  const token = localStorage.getItem(key);
  if (token) {
    console.log(`Found token with key: "${key}"`);
    console.log("Token preview:", token.substring(0, 30) + "...");
  }
}
```

### Test 2: Test API Directly
```javascript
// Run in browser console
const token = localStorage.getItem("token"); // Use your key
fetch("http://localhost:8080/api/feedback?page=0&size=20", {
  headers: {
    "Authorization": `Bearer ${token}`,
    "Content-Type": "application/json"
  }
})
.then(res => {
  console.log("Status:", res.status);
  return res.json();
})
.then(data => console.log("Data:", data))
.catch(err => console.error("Error:", err));
```

### Test 3: Verify User Profile
```javascript
// Check your account type
const token = localStorage.getItem("token");
fetch("http://localhost:8080/api/me", {
  headers: { "Authorization": `Bearer ${token}` }
})
.then(res => res.json())
.then(user => {
  console.log("Email:", user.email);
  console.log("Account Type:", user.accountType);
  console.log("Company:", user.companyName);
});
```

## Expected Result After Fix

Once fixed, you should see:
- ✅ No error messages
- ✅ Your 2 feedback entries displayed
- ✅ Rating: 3 stars for each
- ✅ Status: NEW
- ✅ User: nikita.a@omoikaneinnovations.com
- ✅ Download buttons work
- ✅ Mark Reviewed button appears

## Still Not Working?

If you still see 401 errors after trying these fixes:

1. **Check backend logs** - Look for authentication errors
2. **Verify JWT secret** - Make sure it matches between login and feedback
3. **Check CORS** - Verify SecurityConfig allows your frontend origin
4. **Test with Postman** - Isolate if it's a frontend or backend issue

Run this PowerShell command to test:
```powershell
$token = "YOUR_TOKEN_HERE"
Invoke-RestMethod -Uri "http://localhost:8080/api/feedback" `
  -Headers @{"Authorization" = "Bearer $token"}
```

If this works but browser doesn't, it's a frontend token issue.
If this fails too, it's a backend authentication issue.

---

**Use `App_Feedback_FIXED_401.jsx` for the easiest fix!** 🚀
