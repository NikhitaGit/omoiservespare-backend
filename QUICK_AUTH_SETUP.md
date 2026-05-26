# 🚀 Quick Setup Guide - Unified Authentication

## Step 1: Restart Backend (Apply Migration)
```powershell
# Stop current Spring Boot (Ctrl+C)
# Start again to apply V11 migration
mvn spring-boot:run
```

Wait for: `Started OmoiservespareApplication`

## Step 2: Set Admin Password
```sql
-- Open PostgreSQL (pgAdmin or psql)
-- Run this query:

UPDATE users
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'
WHERE email = 'admin@company.com';

-- This sets password to: admin123
```

## Step 3: Test Backend
```powershell
.\test-unified-auth.ps1
```

Expected output:
- ✅ User signup successful
- ✅ Vendor signup successful (PENDING status)
- ✅ User login successful
- ✅ Vendor login successful

## Step 4: Test Admin Login
```powershell
# Create test-admin-login.ps1
$login = @{
    email = "admin@company.com"
    password = "admin123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/v2/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $login
```

Expected: Admin login successful with JWT token

## Step 5: Update Frontend

### A. Replace VendorLogin.jsx
```bash
# Copy from frontend-integration/VendorLogin_UPDATED.jsx
# to your React project
```

### B. Add VendorSignup.jsx
```bash
# Copy from frontend-integration/VendorSignup.jsx
# to your React project
```

### C. Add authApi.js
```bash
# Copy from frontend-integration/authApi.js
# to your React project utils folder
```

### D. Add ProtectedRoute.jsx
```bash
# Copy from frontend-integration/ProtectedRoute.jsx
# to your React project components folder
```

### E. Update App.jsx Routes
```jsx
import ProtectedRoute from "./components/ProtectedRoute";
import VendorLogin from "./pages/VendorLogin";
import VendorSignup from "./pages/VendorSignup";

// In your routes:
<Route path="/vendor/login" element={<VendorLogin />} />
<Route path="/vendor/signup" element={<VendorSignup />} />

<Route 
  path="/vendor/monitor" 
  element={
    <ProtectedRoute allowedRoles={["VENDOR"]}>
      <MonitorDashboard />
    </ProtectedRoute>
  } 
/>

<Route 
  path="/admin/dashboard" 
  element={
    <ProtectedRoute allowedRoles={["ADMIN"]}>
      <AdminDashboard />
    </ProtectedRoute>
  } 
/>
```

## Step 6: Test Complete Flow

### Test 1: User Signup & Login
1. Go to `/signup`
2. Fill form with role="USER"
3. Submit → Should get token
4. Redirected to `/user/dashboard`

### Test 2: Vendor Signup & Approval
1. Go to `/vendor/signup`
2. Fill vendor details
3. Submit → Status: PENDING
4. Login as admin
5. Approve vendor
6. Vendor can now login and access dashboard

### Test 3: Admin Login
1. Go to `/admin/login` (or `/login`)
2. Email: admin@company.com
3. Password: admin123
4. Should redirect to `/admin/dashboard`

## 🎯 Test Credentials

**Admin:**
- Email: admin@company.com
- Password: admin123
- Role: ADMIN

**Test User:**
- Email: testuser@example.com
- Password: password123
- Role: USER

**Test Vendor:**
- Email: testvendor@example.com
- Password: vendor123
- Role: VENDOR (Status: PENDING)

## ✅ Verification Checklist

- [ ] Backend running on port 8080
- [ ] V11 migration applied (check logs)
- [ ] Admin password set in database
- [ ] Test script passes all tests
- [ ] Frontend updated with new components
- [ ] Routes configured with ProtectedRoute
- [ ] User can signup and login
- [ ] Vendor can signup (pending status)
- [ ] Admin can login
- [ ] Role-based routing works

## 🐛 Common Issues

### "Invalid email or password"
→ Check password was set correctly in database

### "Vendor application pending approval"
→ Normal! Admin must approve first

### "401 Unauthorized"
→ Token expired or invalid, re-login

### Frontend CORS error
→ Check SecurityConfig allows your frontend origin

## 📞 Need Help?

Check these files:
- `UNIFIED_AUTH_COMPLETE.md` - Full documentation
- `test-unified-auth.ps1` - Test all endpoints
- `frontend-integration/` - All React components

---

**Setup time: ~10 minutes** ⏱️

Your unified auth system is ready to go! 🎉
