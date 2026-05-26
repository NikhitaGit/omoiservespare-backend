# 🚀 Auth System - Quick Reference Card

## 📍 API Endpoints

### Login (All Roles)
```
POST http://localhost:8080/api/v2/auth/login
Body: { "email": "user@example.com", "password": "password123" }
```

### Signup (USER/VENDOR)
```
POST http://localhost:8080/api/v2/auth/signup
Body: { 
  "email": "user@example.com", 
  "password": "password123",
  "companyName": "Company Name",
  "phoneNumber": "+1234567890",
  "role": "USER" or "VENDOR"
}
```

## 🔑 Test Credentials

| Role | Email | Password | Status |
|------|-------|----------|--------|
| ADMIN | admin@company.com | admin123 | Active |
| USER | testuser@example.com | password123 | Active |
| VENDOR | testvendor@example.com | vendor123 | PENDING |

## 🧪 Quick Tests

```powershell
# Test all auth flows
.\test-unified-auth.ps1

# Test admin login
.\test-admin-login.ps1

# Check backend status
.\test-backend-status.ps1
```

## 🔧 Quick Setup

```powershell
# 1. Restart backend
mvn spring-boot:run

# 2. Set admin password (PostgreSQL)
psql -U postgres -d omoiservespare -f set-admin-password.sql

# 3. Test
.\test-unified-auth.ps1
```

## 📱 Frontend Usage

```javascript
import { login, signup, isAuthenticated } from './utils/authApi';

// Login
const response = await login(email, password);
// Returns: { success, message, accessToken, user }

// Signup
const response = await signup(email, password, companyName, phoneNumber, role);
// Returns: { success, message, accessToken, user }

// Check auth
if (isAuthenticated()) {
  // User is logged in
}

// Get role
const role = getUserRole(); // "USER", "VENDOR", or "ADMIN"
```

## 🛡️ Protected Routes

```jsx
import ProtectedRoute from './components/ProtectedRoute';

<ProtectedRoute allowedRoles={["VENDOR"]}>
  <VendorDashboard />
</ProtectedRoute>
```

## 🎯 Role-Based Routing

```javascript
// After login, redirect based on role
if (user.role === "ADMIN") {
  navigate("/admin/dashboard");
} else if (user.role === "VENDOR") {
  navigate("/vendor/monitor");
} else if (user.role === "USER") {
  navigate("/user/dashboard");
}
```

## 🔐 Security Headers

```javascript
// All authenticated API calls
headers: {
  "Authorization": `Bearer ${localStorage.getItem("accessToken")}`,
  "Content-Type": "application/json"
}
```

## 📊 User Roles

| Role | Signup | Approval | Access |
|------|--------|----------|--------|
| USER | Self | Immediate | Full user features |
| VENDOR | Self | Admin required | Limited until approved |
| ADMIN | Special endpoint | N/A | Full system access |

## 🚦 Vendor Status Flow

```
PENDING → (Admin approves) → APPROVED → Full Access
        → (Admin rejects) → REJECTED → No Access
        → (Admin suspends) → SUSPENDED → No Access
```

## 📝 Common Tasks

### Set Admin Password
```sql
UPDATE users
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL41lW4W'
WHERE email = 'admin@company.com';
```

### Check User in Database
```sql
SELECT id, email, role, vendor_status, account_active 
FROM users 
WHERE email = 'user@example.com';
```

### Verify Password Set
```sql
SELECT email, 
  CASE WHEN password_hash IS NOT NULL THEN 'Set' ELSE 'Not Set' END as password
FROM users;
```

## 🐛 Quick Troubleshooting

| Error | Solution |
|-------|----------|
| Invalid email or password | Check password was set in DB |
| Vendor application pending | Normal, admin must approve |
| 401 Unauthorized | Token expired, re-login |
| CORS error | Check SecurityConfig origins |

## 📚 Documentation Files

- `START_HERE_UNIFIED_AUTH.md` - Overview
- `QUICK_AUTH_SETUP.md` - Setup guide
- `UNIFIED_AUTH_COMPLETE.md` - Full docs
- `IMPLEMENTATION_SUMMARY_AUTH.md` - Summary
- `AUTH_QUICK_REFERENCE.md` - This file

## 🎉 Status

✅ Backend: Complete  
✅ Frontend: Complete  
✅ Tests: Passing  
✅ Docs: Complete  
✅ Ready: YES

---

**Need help?** Check the documentation files or run test scripts.
