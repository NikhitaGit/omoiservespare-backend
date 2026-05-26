# 🔧 Fix Connection Error - ERR_CONNECTION_REFUSED

## Problem
Your frontend is trying to connect to `http://localhost:5173/` instead of `http://localhost:8080` (backend).

## Root Cause
The `.env` file in the root folder is for the backend (Spring Boot). Your frontend (React/Vite) needs its own `.env` file in the frontend folder.

---

## Solution: Create Frontend .env File

### Step 1: Find Your Frontend Folder
Your frontend is likely in one of these locations:
- `frontend/`
- `client/`
- `ui/`
- Or the root if it's a separate project

### Step 2: Create `.env` File in Frontend Folder

Create a file named `.env` in your frontend project root (same level as `package.json`):

```env
VITE_API_BASE_URL=http://localhost:8080
VITE_WS_URL=http://localhost:8080/ws
```

### Step 3: Restart Frontend Dev Server

**IMPORTANT:** Vite only reads `.env` files on startup!

```bash
# Stop the dev server (Ctrl+C)
# Then restart:
npm run dev
```

---

## Alternative: Check Your axiosInstance.js

If you already have a frontend `.env` file, check your `axiosInstance.js`:

### Current Code (from your file):
```javascript
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,  // ← Should be http://localhost:8080
  timeout: 10000,
  withCredentials: true
});
```

### Verify in Browser Console:
Open browser console and type:
```javascript
import.meta.env.VITE_API_BASE_URL
```

Should show: `"http://localhost:8080"`

If it shows `undefined`, the `.env` file is not being read.

---

## Quick Fix: Hardcode Temporarily

If the `.env` file isn't working, temporarily hardcode the URL in `axiosInstance.js`:

```javascript
const api = axios.create({
  baseURL: 'http://localhost:8080',  // ← Hardcoded
  timeout: 10000,
  withCredentials: true
});
```

Then restart your dev server.

---

## Checklist

- [ ] Backend is running on port 8080
  ```bash
  # Check with:
  netstat -ano | findstr :8080
  ```

- [ ] Frontend `.env` file exists in frontend folder
  ```env
  VITE_API_BASE_URL=http://localhost:8080
  VITE_WS_URL=http://localhost:8080/ws
  ```

- [ ] Frontend dev server restarted after creating `.env`
  ```bash
  # Stop (Ctrl+C) then:
  npm run dev
  ```

- [ ] Browser console shows correct URL
  ```javascript
  import.meta.env.VITE_API_BASE_URL
  // Should show: "http://localhost:8080"
  ```

---

## Test Backend is Running

Open browser and go to:
```
http://localhost:8080/api/admin/dashboard/health
```

Should show: `"Admin Dashboard API is running"`

If you get connection refused, backend is not running. Start it:
```bash
mvn spring-boot:run
```

---

## Common Issues

### Issue 1: Backend not running
**Error:** `ERR_CONNECTION_REFUSED` on port 8080

**Solution:**
```bash
# Start backend
mvn spring-boot:run

# Or if using IDE, run the main application class
```

### Issue 2: Wrong port in .env
**Error:** Still connecting to wrong port

**Solution:**
1. Check `.env` file location (must be in frontend folder)
2. Restart dev server (Vite only reads .env on startup)
3. Clear browser cache

### Issue 3: CORS error
**Error:** `CORS policy: No 'Access-Control-Allow-Origin' header`

**Solution:** Backend already has `@CrossOrigin(origins = "*")` - should work. If not, check backend logs.

---

## Summary

1. Create `.env` in your frontend folder (not backend)
2. Add `VITE_API_BASE_URL=http://localhost:8080`
3. Restart frontend dev server
4. Make sure backend is running on port 8080

**That's it!** 🎉
