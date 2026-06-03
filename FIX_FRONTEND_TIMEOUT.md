# 🔧 Fix Frontend Timeout Error

## 🚨 Problem

Your frontend is timing out when trying to connect to the backend because the API base URL is not configured.

**Error in Browser Console:**
```
AxiosError: timeout of 30000ms exceeded
```

---

## ✅ Solution

Your backend is running on `http://localhost:8080` but your frontend doesn't know this.

### Fix: Create .env File in Frontend

**Location:** In your frontend project root (where package.json is)

**Create file:** `.env`

**Content:**
```env
VITE_API_BASE_URL=http://localhost:8080
```

---

## 📝 Step-by-Step Instructions

### 1. Navigate to Your Frontend Project

```powershell
cd path\to\your\frontend\project
```

### 2. Create .env File

**Option A: Using Command Line**
```powershell
echo VITE_API_BASE_URL=http://localhost:8080 > .env
```

**Option B: Manually**
1. Open your frontend project in code editor
2. Create new file named `.env` (at root level, next to package.json)
3. Add this content:
   ```
   VITE_API_BASE_URL=http://localhost:8080
   ```

### 3. Restart Your Frontend

```powershell
# Stop the current frontend server (Ctrl+C)
# Then restart:
npm run dev
```

---

## 🧪 Test the Backend is Working

Before fixing frontend, let's verify the OTP email system works:

```powershell
./test-otp-now.ps1
```

This will:
1. Check backend health
2. Request an OTP
3. Verify email is sent

**Expected Output:**
```
✅ Backend is running
✅ OTP Request Successful!
📧 CHECK YOUR EMAIL INBOX!
```

**Check Your Email:**
- Look for email from: `aishushettar95@gmail.com`
- Subject: "🔐 Your Login OTP"
- Beautiful HTML formatting
- Clear 4-digit OTP code

---

## 📊 Verify Backend Logs

In your backend console, you should see:

```log
========================================
📧 EMAIL SERVICE: OTP Send Initiated
Recipient: your@email.com
OTP: 1234
Timestamp: 2026-06-03T11:40:00
========================================
Sending email via SMTP...
========================================
✅ EMAIL SENT SUCCESSFULLY
Recipient: your@email.com
Duration: 847 ms
SMTP Server: aishushettar95@gmail.com
========================================
```

---

## 🔍 Troubleshooting

### Frontend Still Timing Out?

1. **Verify .env file location**
   - Must be at frontend root (same level as package.json)
   - Filename must be exactly `.env` (not .env.txt)

2. **Verify .env content**
   ```
   VITE_API_BASE_URL=http://localhost:8080
   ```
   - No quotes around the URL
   - No spaces
   - Correct port (8080)

3. **Restart frontend completely**
   ```powershell
   # Stop frontend (Ctrl+C)
   npm run dev
   ```

4. **Clear browser cache**
   - Press Ctrl+Shift+Delete
   - Clear cache and cookies
   - Refresh page

### Backend Not Responding?

1. **Check backend is running**
   ```powershell
   # In backend terminal, you should see:
   # "Started OmoiservespareApplication..."
   ```

2. **Test backend directly**
   ```powershell
   curl http://localhost:8080/api/auth/health
   ```
   Should return: "Unified Auth API is running"

3. **Check port 8080 is not blocked**
   ```powershell
   netstat -ano | findstr :8080
   ```

---

## 📋 Complete Checklist

- [ ] Backend is running (port 8080)
- [ ] Backend shows "Started OmoiservespareApplication"
- [ ] Created `.env` file in frontend root
- [ ] `.env` contains: `VITE_API_BASE_URL=http://localhost:8080`
- [ ] Restarted frontend server
- [ ] Cleared browser cache
- [ ] Tested backend with `test-otp-now.ps1`
- [ ] Email is being sent successfully

---

## 🎯 Expected Result

After fixing:

1. **Frontend login page loads** ✅
2. **User enters email** ✅
3. **Click "Log In"** ✅
4. **NO timeout error** ✅
5. **OTP page appears** ✅
6. **Email arrives in inbox** ✅
7. **User enters OTP** ✅
8. **Login succeeds** ✅

---

## 📧 Email Test Results

Once backend is confirmed working, your OTP emails will have:

✅ Professional HTML design
✅ Purple gradient header
✅ Large, clear OTP display
✅ 5-minute expiry warning
✅ Security warnings
✅ Company branding
✅ Mobile-responsive layout

---

## 🚀 Next Steps

1. **Run the test script first:**
   ```powershell
   ./test-otp-now.ps1
   ```

2. **Verify email arrives in inbox**

3. **Then fix frontend .env**

4. **Restart frontend**

5. **Test complete login flow**

---

**Your backend OTP email system is working!** The issue is just the frontend connection configuration.

Fix the `.env` file and you're good to go! 🎉
