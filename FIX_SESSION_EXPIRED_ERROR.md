# Fix "Session Expired" Error

## The Problem

You're getting "Session expired. Please login again" even though you just logged in. This happens because:

1. **Token key mismatch**: OTP saves as `"authToken"` but components look for `"token"`
2. **Token not being sent**: Frontend not sending token in Authorization header
3. **Backend expects different format**: Backend looks for `Bearer <token>` format

## The Complete Fix

### Step 1: Fix OTP to Save Correct Key

In `OtpVerification.jsx`, change line 30:

```javascript
// BEFORE (Wrong)
localStorage.setItem("authToken", result.accessToken);

// AFTER (Correct)
localStorage.setItem("token", result.accessToken);
```

### Step 2: Verify Token is Saved

After logging in with OTP, open console (F12) and run:

```javascript
localStorage.getItem('token')
```

Should return a long string starting with "eyJ..."

### Step 3: Check Your API Calls Send Token Correctly

Your API calls need to send the token in the Authorization header. Check your `authApi.js` or API utility file.

**Example of correct API call:**

```javascript
const token = localStorage.getItem('token');

const response = await fetch('http://localhost:8080/api/tickets/my-tickets', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

## Quick Test

Run this in browser console (F12) after logging in:

```javascript
// Check if token exists
const token = localStorage.getItem('token');
console.log('Token:', token ? token.substring(0, 50) + '...' : 'NOT FOUND');

// Test API call with token
fetch('http://localhost:8080/api/users/profile', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
})
.then(r => r.json())
.then(data => console.log('Profile:', data))
.catch(err => console.error('Error:', err));
```

## Common Issues

### Issue 1: Token Saved with Wrong Key

**Symptom:** Token exists but components can't find it

**Check:**
```javascript
// Check all possible keys
console.log('token:', localStorage.getItem('token'));
console.log('authToken:', localStorage.getItem('authToken'));
console.log('accessToken:', localStorage.getItem('accessToken'));
```

**Fix:** Use `"token"` everywhere

### Issue 2: Token Not Sent in Request

**Symptom:** Backend returns 401 even with valid token

**Check:** Open Network tab (F12 → Network), click on a failing request, check Headers → Request Headers → Authorization

**Should see:** `Authorization: Bearer eyJ...`

**If missing:** Your API calls aren't sending the token

### Issue 3: Wrong Token Format

**Symptom:** Token sent but backend rejects it

**Backend expects:** `Bearer <token>`

**Check your code sends:**
```javascript
headers: {
  'Authorization': `Bearer ${token}`  // ✅ Correct
}

// NOT:
headers: {
  'Authorization': token  // ❌ Wrong - missing "Bearer "
}
```

## Backend Token Validation

Your backend accepts tokens in 2 ways:

1. **Authorization header** (recommended):
   ```
   Authorization: Bearer eyJhbGc...
   ```

2. **Cookie** (if configured):
   ```
   Cookie: accessToken=eyJhbGc...
   ```

Most likely you're using Authorization header, so make sure your API calls include it.

## Complete Working Example

```javascript
// After OTP verification
const handleConfirm = async () => {
  const otp = inputs.current.map((input) => input.value).join("");
  
  try {
    const email = localStorage.getItem("loginEmail");
    const result = await verifyOtp({ email, otp });

    // ✅ Save token with correct key
    localStorage.setItem("token", result.accessToken);
    
    console.log("Token saved successfully!");
    navigate("/home");
    
  } catch (err) {
    console.error("OTP verification failed:", err);
  }
};

// Later, when making API calls
const fetchUserProfile = async () => {
  const token = localStorage.getItem('token');
  
  if (!token) {
    alert('Please login first');
    navigate('/login');
    return;
  }

  try {
    const response = await fetch('http://localhost:8080/api/users/profile', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (response.status === 401) {
      alert('Session expired. Please login again.');
      localStorage.removeItem('token');
      navigate('/login');
      return;
    }

    const profile = await response.json();
    console.log('Profile:', profile);
    
  } catch (err) {
    console.error('Error:', err);
  }
};
```

## Summary

1. **Fix OTP:** Save as `"token"` not `"authToken"`
2. **Check token exists:** `localStorage.getItem('token')`
3. **Send token correctly:** `Authorization: Bearer ${token}`
4. **Test with console:** Use the quick test above

The main issue is the key mismatch. Fix that first, then verify your API calls send the token in the Authorization header.
