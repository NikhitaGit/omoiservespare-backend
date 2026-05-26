# 🔐 Unified Authentication System - COMPLETE

## Overview
Single authentication system for all roles (USER, VENDOR, ADMIN) with password-based login, just like Zomato and Swiggy.

## ✅ What's Implemented

### Backend (Spring Boot + PostgreSQL)
1. **Password Authentication**
   - BCrypt password hashing
   - Secure password storage in `users.password_hash`
   - Single `users` table for all roles

2. **Unified Endpoints**
   - `POST /api/v2/auth/login` - Login for all roles
   - `POST /api/v2/auth/signup` - Signup for USER and VENDOR
   - Returns JWT token + user info with role

3. **Role-Based Access**
   - USER: Full access after signup
   - VENDOR: Requires admin approval (PENDING → APPROVED)
   - ADMIN: Created via special endpoint with secret key

4. **Security Features**
   - JWT token authentication
   - Account suspension support
   - Vendor status validation
   - Password strength requirements

### Frontend (React)
1. **VendorLogin_UPDATED.jsx** - Real-time login with API
2. **VendorSignup.jsx** - Vendor registration form
3. **Role-based routing** - Redirects based on user role

## 🚀 Quick Start

### 1. Run Database Migration
```bash
# Restart Spring Boot to apply V11 migration
mvn spring-boot:run
```

### 2. Set Admin Password
```sql
-- Run in PostgreSQL
UPDATE users
SET password_hash = crypt('admin123', gen_salt('bf'))
WHERE email = 'admin@company.com';
```

Or use the script:
```powershell
.\set-admin-password.ps1
```

### 3. Test Authentication
```powershell
.\test-unified-auth.ps1
```

## 📋 API Reference

### Login (All Roles)
```http
POST /api/v2/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "companyName": "My Company",
    "phoneNumber": "+1234567890",
    "role": "USER",
    "vendorStatus": null,
    "accountActive": true
  }
}
```

### Signup (USER/VENDOR)
```http
POST /api/v2/auth/signup
Content-Type: application/json

{
  "email": "vendor@example.com",
  "password": "password123",
  "companyName": "Restaurant Name",
  "phoneNumber": "+9876543210",
  "role": "VENDOR"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Vendor registration successful. Awaiting admin approval.",
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 2,
    "email": "vendor@example.com",
    "role": "VENDOR",
    "vendorStatus": "PENDING"
  }
}
```

## 🎯 User Flows

### USER Flow
1. Signup → Immediate access
2. Login → Dashboard
3. Browse canteens, place orders

### VENDOR Flow
1. Signup → Status: PENDING
2. Wait for admin approval
3. Login → Check status
4. After approval → Full access to vendor dashboard

### ADMIN Flow
1. Created via `/api/admin/create-first` with secret key
2. Set password manually or via script
3. Login → Admin dashboard
4. Approve/reject vendor applications

## 🔒 Security Features

### Password Requirements
- Minimum 6 characters
- BCrypt hashing (strength 10)
- Stored in `password_hash` column

### JWT Token
- Contains: email, role
- Expiration: 24 hours (configurable)
- Sent in `Authorization: Bearer <token>` header

### Account Status Checks
- Account active/suspended
- Vendor approval status
- Role-based permissions

## 📱 Frontend Integration

### 1. Replace VendorLogin.jsx
```jsx
// Use frontend-integration/VendorLogin_UPDATED.jsx
// Handles real-time API authentication
// Role-based routing
```

### 2. Add VendorSignup.jsx
```jsx
// Use frontend-integration/VendorSignup.jsx
// Vendor registration form
// Validation and error handling
```

### 3. Store Token
```javascript
// After successful login
localStorage.setItem("accessToken", data.accessToken);
localStorage.setItem("userRole", data.user.role);
localStorage.setItem("userEmail", data.user.email);
```

### 4. Use Token in API Calls
```javascript
const response = await fetch("http://localhost:8080/api/orders", {
  headers: {
    "Authorization": `Bearer ${localStorage.getItem("accessToken")}`,
    "Content-Type": "application/json"
  }
});
```

## 🧪 Testing

### Test Credentials
After running `test-unified-auth.ps1`:

**User:**
- Email: testuser@example.com
- Password: password123
- Role: USER

**Vendor:**
- Email: testvendor@example.com
- Password: vendor123
- Role: VENDOR (Status: PENDING)

**Admin:**
- Email: admin@company.com
- Password: (set via script)
- Role: ADMIN

### Test Scenarios
1. ✅ User signup and login
2. ✅ Vendor signup (pending approval)
3. ✅ Vendor login (blocked until approved)
4. ✅ Admin login
5. ✅ Invalid credentials
6. ✅ Suspended account
7. ✅ Role-based access

## 🔄 Migration from OTP

If you have existing users with OTP-based auth:

1. **Add password column** - Already done in V11 migration
2. **Set passwords** - Users can set via "Forgot Password" flow
3. **Keep OTP optional** - Can support both methods
4. **Gradual migration** - Users set password on next login

## 📊 Database Schema

```sql
users table:
- id (PRIMARY KEY)
- email (UNIQUE)
- password_hash (BCrypt)
- company_name
- phone_number
- role (USER, VENDOR, ADMIN)
- vendor_status (PENDING, APPROVED, REJECTED, SUSPENDED)
- account_active (BOOLEAN)
- created_at
- updated_at
```

## 🎨 Frontend Routes

```javascript
// Suggested routes
/login              → Universal login page
/signup             → User signup
/vendor/login       → Vendor login (same as /login)
/vendor/signup      → Vendor signup
/vendor/pending     → Pending approval page
/admin/login        → Admin login (same as /login)

// After login (role-based)
/user/dashboard     → USER role
/vendor/monitor     → VENDOR role (approved)
/admin/dashboard    → ADMIN role
```

## ⚡ Next Steps

1. **Set admin password**
   ```powershell
   .\set-admin-password.ps1
   ```

2. **Test authentication**
   ```powershell
   .\test-unified-auth.ps1
   ```

3. **Update frontend**
   - Replace VendorLogin.jsx
   - Add VendorSignup.jsx
   - Update routing

4. **Test complete flow**
   - User signup → login → dashboard
   - Vendor signup → pending → admin approval → login
   - Admin login → approve vendors

## 🐛 Troubleshooting

### "Invalid email or password"
- Check email is correct
- Verify password was set
- Check account is active

### "Vendor application pending approval"
- Normal for new vendors
- Admin must approve via dashboard
- Check vendor_status in database

### "Account is suspended"
- Contact admin
- Check account_active flag

### JWT token expired
- Token expires after 24 hours
- Implement refresh token flow
- Or re-login

## 📚 Files Created

**Backend:**
- `UnifiedAuthService.java` - Authentication logic
- `UnifiedAuthController.java` - API endpoints
- `PasswordLoginRequest.java` - Login DTO
- `SignupRequest.java` - Signup DTO
- `AuthResponse.java` - Response DTO
- `V11__add_password_authentication.sql` - Migration

**Frontend:**
- `VendorLogin_UPDATED.jsx` - Real-time login
- `VendorSignup.jsx` - Registration form

**Scripts:**
- `test-unified-auth.ps1` - Test all flows
- `set-admin-password.ps1` - Set admin password

**Documentation:**
- `UNIFIED_AUTH_COMPLETE.md` - This file

## ✨ Features

✅ Single authentication system  
✅ Password-based login  
✅ Role-based access (USER, VENDOR, ADMIN)  
✅ JWT token authentication  
✅ Vendor approval workflow  
✅ Account suspension  
✅ Secure password hashing  
✅ Real-time API integration  
✅ Frontend components  
✅ Test scripts  

---

**Your unified authentication system is ready! 🎉**

Just like Zomato and Swiggy - one system, multiple roles, secure and scalable.
