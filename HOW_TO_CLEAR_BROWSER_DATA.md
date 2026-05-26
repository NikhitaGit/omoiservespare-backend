# 🧹 How to Clear Browser Data and Test Login

## Step-by-Step Guide

### Step 1: Open Your Application in Browser

Open your frontend application (usually http://localhost:5173 or http://localhost:3000)

---

### Step 2: Open Developer Tools

**Method 1:** Press `F12` on your keyboard

**Method 2:** Right-click anywhere on the page → Click "Inspect" or "Inspect Element"

**Method 3:** 
- Chrome/Edge: Press `Ctrl + Shift + I`
- Firefox: Press `Ctrl + Shift + I`

---

### Step 3: Clear Site Data

#### Option A: Clear Everything (Recommended)

1. In DevTools, click the **"Application"** tab (Chrome/Edge) or **"Storage"** tab (Firefox)
2. In the left sidebar, look for **"Storage"** section
3. Click **"Clear site data"** button
4. Click **"Clear"** to confirm

**Visual Guide:**
```
DevTools Window
├── Elements
├── Console
├── Sources
├── Network
├── Performance
├── Memory
├── Application  ← Click here
    ├── Storage
    │   └── [Clear site data] ← Click this button
    ├── Local Storage
    ├── Session Storage
    └── Cookies
```

#### Option B: Clear localStorage Only (Manual)

1. In DevTools, click **"Application"** tab
2. In left sidebar, expand **"Local Storage"**
3. Click on **"http://localhost:5173"** (or your frontend URL)
4. You'll see all stored items:
   - `token`
   - `deviceId`
   - `userEmail`
   - `companyName`
   - `phoneNumber`
   - `accountType`
   - `loginEmail`
   - `loginPhone`
5. Right-click in the storage area → Click **"Clear"**

**Or delete items one by one:**
- Right-click each item → Click "Delete"

---

### Step 4: Close DevTools

Press `F12` again or click the `X` button on DevTools

---

### Step 5: Refresh the Page

Press `Ctrl + R` or `F5` to refresh the page

---

### Step 6: Test Login

1. **Go to login page:**
   - Should automatically redirect to `/login` if you were logged in
   - Or manually go to http://localhost:5173/login

2. **Enter credentials:**
   - Company Name: (your company name)
   - Email: (your email)
   - Click "Login" or "Send OTP"

3. **Check backend console:**
   - Look for OTP in backend console
   - Example: `OTP sent to user@company.com: 1234`

4. **Enter OTP:**
   - Enter the 4-digit OTP from backend console
   - Click "Verify" or "Confirm"

5. **Check browser console (F12 → Console tab):**
   - Should see:
     ```
     Created new device ID: device-abc123-1234567890
     Verifying OTP for email: user@company.com
     Raw API response: {accessToken: "eyJ...", email: "...", ...}
     Token saved successfully as 'token'
     ```

6. **Check localStorage (F12 → Application → Local Storage):**
   - Should see:
     ```
     token: eyJ0bGct01JTUz1INtJ9...
     deviceId: device-abc123-1234567890
     userEmail: user@company.com
     companyName: Company Name
     phoneNumber: +1234567890
     accountType: PERSONAL
     ```

7. **Navigate to other pages:**
   - Click on Profile, Canteen List, My Orders, etc.
   - Should work without redirecting to login
   - Should see your data

---

## Quick Visual Guide

### Chrome/Edge DevTools:

```
1. Press F12
2. Click "Application" tab
3. Click "Clear site data" button
4. Click "Clear"
5. Close DevTools (F12)
6. Refresh page (F5)
7. Login again
```

### Firefox DevTools:

```
1. Press F12
2. Click "Storage" tab
3. Right-click "Local Storage" → "Delete All"
4. Close DevTools (F12)
5. Refresh page (F5)
6. Login again
```

---

## Alternative: Clear from Browser Settings

### Chrome/Edge:

1. Press `Ctrl + Shift + Delete`
2. Select "Cookies and other site data"
3. Select "Cached images and files"
4. Time range: "Last hour" or "All time"
5. Click "Clear data"

### Firefox:

1. Press `Ctrl + Shift + Delete`
2. Select "Cookies"
3. Select "Cache"
4. Time range: "Last hour" or "Everything"
5. Click "Clear Now"

---

## What Gets Cleared?

When you clear site data, these items are removed:

✅ `token` - Your JWT access token
✅ `deviceId` - Your device identifier
✅ `userEmail` - Your email
✅ `companyName` - Your company name
✅ `phoneNumber` - Your phone number
✅ `accountType` - Your account type
✅ `loginEmail` - Temporary login email
✅ `loginPhone` - Temporary login phone
✅ Cookies (including refresh token)
✅ Cache

---

## Why Clear Browser Data?

After updating frontend files, old tokens or cached data might cause issues. Clearing ensures:

1. Old token is removed
2. New device ID is generated
3. Fresh login creates new token
4. No conflicts with old data

---

## Troubleshooting

### "Clear site data" button not visible?

- Make sure you're in "Application" tab (Chrome/Edge) or "Storage" tab (Firefox)
- Look in the left sidebar under "Storage" section

### Still redirecting to login after clearing?

1. Check if backend is running (http://localhost:8080)
2. Check browser console for errors (F12 → Console)
3. Verify you copied the updated axiosInstance.js file
4. Try clearing browser cache completely (Ctrl + Shift + Delete)

### Can't find localStorage?

1. Open DevTools (F12)
2. Click "Application" tab
3. Expand "Local Storage" in left sidebar
4. Click on your site URL (http://localhost:5173)

---

**After clearing browser data, login again and your app will work perfectly!** 🎉
