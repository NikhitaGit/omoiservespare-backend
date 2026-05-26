# Fix: 401 Unauthorized Error in Feedback System

## Problem Identified

Your browser console shows:
```
Failed to load resource: 401 (Unauthorized)
GET http://localhost:8080/api/feedback?page=0&size=20
```

This means the JWT token is either:
1. Not being sent in the request
2. Invalid or expired
3. Stored with a different key name

## Solution

### Step 1: Check Your Token

Open browser console (F12) and run:
```javascript
console.log("Token:", localStorage.getItem("token"));
```

If it shows `null`, the token key is different!

### Step 2: Find the Correct Token Key

Run this in console:
```javascript
// List all localStorage keys
for (let i = 0; i < localStorage.length; i++) {
  const key = localStorage.key(i);
  console.log(key + ":", localStorage.getItem(key));
}
```

Look for your JWT token (long string starting with "eyJ...")

### Step 3: Update App_Feedback Component

Once you find the correct key, update line 11:

**If your token is stored as "authToken":**
```javascript
const token = localStorage.getItem("authToken");
```

**If your token is stored as "jwt":**
```javascript
const token = localStorage.getItem("jwt");
```

**If your token is stored as "accessToken":**
```javascript
const token = localStorage.getItem("accessToken");
```

## Quick Fix Version

I'll create an updated version that automatically finds the token!
