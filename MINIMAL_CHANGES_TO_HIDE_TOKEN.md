# 🔒 Minimal Changes to Hide Token

## Current Situation

Your token is visible in localStorage because your login code does this:
```javascript
localStorage.setItem("token", accessToken);
// or
localStorage.setItem("authToken", accessToken);
```

## The Problem

Even though the backend now sends the token as an httpOnly cookie, your frontend is ALSO storing it in localStorage, making it visible.

## Solution: Stop Storing Token in localStorage

You need to find where you're storing the token and remove those lines.

### Step 1: Find Your Login Component

Look for your login/OTP verification component. It probably has code like this:

```javascript
// ❌ REMOVE THESE LINES
localStorage.setItem("token", response.token);
localStorage.setItem("authToken", response.token);
```

### Step 2: Remove Token Storage

Simply delete or comment out those lines:

```javascript
// ✅ AFTER - Don't store token
// localStorage.setItem("token", response.token);  // REMOVED
// localStorage.setItem("authToken", response.token);  // REMOVED

// Token is now in httpOnly cookie automatically!
```

### Step 3: Update Your Feedback Files

In your existing `App_Feedback.jsx` and `Feedback.jsx`, make these MINIMAL changes:

#### Change 1: Remove getToken function
```javascript
// ❌ REMOVE THIS
const getToken = () => {
  return localStorage.getItem("token") || localStorage.getItem("authToken");
};
```

#### Change 2: Update fetch calls

**OLD:**
```javascript
const token = getToken();
const response = await fetch(url, {
  headers: {
    "Authorization": `Bearer ${token}`,
    "Content-Type": "application/json"
  }
});
```

**NEW:**
```javascript
const response = await fetch(url, {
  credentials: 'include', // 🔒 Send httpOnly cookie
  headers: {
    "Content-Type": "application/json"
  }
});
```

## Complete Minimal Changes

### For App_Feedback.jsx

1. Remove the `getToken` function (lines 13-15)
2. In `fetchFeedback`, remove token check and update fetch:
```javascript
// Remove these lines:
const token = getToken();
if (!token) { ... }

// Change fetch to:
const response = await fetch(url, {
  credentials: 'include',
  headers: {
    "Content-Type": "application/json"
  }
});
```

3. In `markAsReviewed`, remove token and update fetch:
```javascript
// Remove: const token = getToken();
// Remove: if (!token) { ... }

const response = await fetch(`http://localhost:8080/api/feedback/${id}/review`, {
  method: "PUT",
  credentials: 'include'
});
```

4. In `downloadCSV` and `downloadExcel`, update fetch:
```javascript
const response = await fetch("http://localhost:8080/api/feedback/export/csv", {
  credentials: 'include'
});
```

### For Feedback.jsx

1. In `handleSubmit`, remove token check and update fetch:
```javascript
// Remove these lines:
const token = localStorage.getItem("token") || localStorage.getItem("authToken");
if (!token) { ... }

// Change fetch to:
const response = await fetch("http://localhost:8080/api/feedback", {
  method: "POST",
  credentials: 'include',
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    rating: rating,
    comments: comments.trim()
  })
});
```

## That's It!

These are the ONLY changes needed:
1. Stop storing token in localStorage (in your login component)
2. Remove `getToken()` function
3. Add `credentials: 'include'` to all fetch calls
4. Remove `Authorization` header

The token will now be:
- ✅ Stored in httpOnly cookie (automatic)
- ✅ Hidden from JavaScript
- ✅ Not visible in DevTools
- ✅ Sent automatically with every request

## Quick Test

After making changes:
1. Login to your app
2. Open DevTools (F12)
3. Go to Application → Local Storage
4. ✅ Should NOT see 'token' or 'authToken'
5. Go to Application → Cookies
6. ✅ Should see 'accessToken' with HttpOnly flag

---

**Note:** The backend already supports this! I modified it to send tokens as httpOnly cookies. Your existing code will work during transition because the backend accepts BOTH cookie and Authorization header.
