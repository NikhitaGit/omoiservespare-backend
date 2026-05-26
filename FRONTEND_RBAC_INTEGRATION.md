# 🎨 Frontend RBAC Integration Guide

## ✅ Good News: Your Frontend Already Works!

Your existing JWT authentication system already handles RBAC automatically. The backend enforces all security rules, so **no breaking changes needed**.

However, you should add these **optional enhancements** for better user experience.

---

## 🔄 What Changed in Backend

### Before:
```json
{
  "token": "eyJhbGc...",
  "email": "user@example.com"
}
```

### After (with RBAC):
```json
{
  "token": "eyJhbGc...",
  "email": "user@example.com",
  "role": "USER"  // ← New field
}
```

The JWT token now includes the user's role.

---

## 🎯 Optional Frontend Enhancements

### 1. Store User Role in Frontend (Optional)

When user logs in, store their role:

```javascript
// In your authApi.js or login component
const handleLogin = async (email, password) => {
  try {
    const response = await loginUser({ email, password });
    
    // Store token (you already do this)
    localStorage.setItem('authToken', response.token);
    
    // ✨ NEW: Store user role
    localStorage.setItem('userRole', response.role);
    localStorage.setItem('userEmail', response.email);
    
    // Redirect based on role
    if (response.role === 'ADMIN') {
      navigate('/admin/dashboard');
    } else if (response.role === 'VENDOR') {
      navigate('/vendor/dashboard');
    } else {
      navigate('/home');
    }
    
  } catch (error) {
    console.error('Login failed:', error);
  }
};
```

### 2. Create Role-Based Navigation (Optional)

Hide/show menu items based on role:

```javascript
// src/components/Navigation.jsx
import React from 'react';
import { Link } from 'react-router-dom';

const Navigation = () => {
  const userRole = localStorage.getItem('userRole');
  
  return (
    <nav>
      {/* Everyone can see these */}
      <Link to="/home">Home</Link>
      <Link to="/restaurants">Restaurants</Link>
      
      {/* Only users can see these */}
      {userRole === 'USER' && (
        <>
          <Link to="/orders">My Orders</Link>
          <Link to="/wallet">Wallet</Link>
          <Link to="/rewards">Rewards</Link>
        </>
      )}
      
      {/* Only vendors can see these */}
      {userRole === 'VENDOR' && (
        <>
          <Link to="/vendor/menu">Manage Menu</Link>
          <Link to="/vendor/orders">Orders</Link>
          <Link to="/vendor/analytics">Analytics</Link>
        </>
      )}
      
      {/* Only admins can see these */}
      {userRole === 'ADMIN' && (
        <>
          <Link to="/admin/dashboard">Dashboard</Link>
          <Link to="/admin/vendors">Manage Vendors</Link>
          <Link to="/admin/users">Manage Users</Link>
        </>
      )}
    </nav>
  );
};

export default Navigation;
```

### 3. Create Protected Routes (Optional)

Prevent users from accessing wrong pages:

```javascript
// src/components/ProtectedRoute.jsx
import React from 'react';
import { Navigate } from 'react-router-dom';

const ProtectedRoute = ({ children, allowedRoles }) => {
  const userRole = localStorage.getItem('userRole');
  const token = localStorage.getItem('authToken');
  
  // Not logged in
  if (!token) {
    return <Navigate to="/login" />;
  }
  
  // Wrong role
  if (allowedRoles && !allowedRoles.includes(userRole)) {
    return <Navigate to="/unauthorized" />;
  }
  
  return children;
};

export default ProtectedRoute;
```

Usage in routes:

```javascript
// src/App.jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import ProtectedRoute from './components/ProtectedRoute';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public routes */}
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        
        {/* User routes */}
        <Route 
          path="/orders" 
          element={
            <ProtectedRoute allowedRoles={['USER']}>
              <MyOrders />
            </ProtectedRoute>
          } 
        />
        
        {/* Vendor routes */}
        <Route 
          path="/vendor/menu" 
          element={
            <ProtectedRoute allowedRoles={['VENDOR']}>
              <VendorMenu />
            </ProtectedRoute>
          } 
        />
        
        {/* Admin routes */}
        <Route 
          path="/admin/dashboard" 
          element={
            <ProtectedRoute allowedRoles={['ADMIN']}>
              <AdminDashboard />
            </ProtectedRoute>
          } 
        />
      </Routes>
    </BrowserRouter>
  );
}
```

### 4. Handle 403 Errors Gracefully (Recommended)

Update your axios interceptor to handle permission errors:

```javascript
// In your axiosInstance.js
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired - redirect to login
      localStorage.removeItem('authToken');
      localStorage.removeItem('userRole');
      window.location.href = '/login';
    }
    
    // ✨ NEW: Handle 403 Forbidden
    if (error.response?.status === 403) {
      // User doesn't have permission
      console.error('Access denied:', error.response.data);
      
      // Show error message
      alert(error.response.data || 'You don\'t have permission to access this resource');
      
      // Optionally redirect
      // window.location.href = '/unauthorized';
    }
    
    return Promise.reject(error);
  }
);
```

### 5. Show Vendor Status (For Vendors)

If user is a vendor, show their approval status:

```javascript
// src/components/VendorStatusBanner.jsx
import React, { useEffect, useState } from 'react';
import api from '../api/axiosInstance';

const VendorStatusBanner = () => {
  const [status, setStatus] = useState(null);
  const userRole = localStorage.getItem('userRole');
  
  useEffect(() => {
    if (userRole === 'VENDOR') {
      // Fetch vendor status from backend
      api.get('/api/vendor/status')
        .then(res => setStatus(res.data.status))
        .catch(err => console.error(err));
    }
  }, [userRole]);
  
  if (userRole !== 'VENDOR' || !status) return null;
  
  return (
    <div className={`vendor-status-banner ${status.toLowerCase()}`}>
      {status === 'PENDING' && (
        <div className="banner pending">
          ⏳ Your vendor application is pending approval
        </div>
      )}
      
      {status === 'APPROVED' && (
        <div className="banner approved">
          ✅ Your vendor account is active
        </div>
      )}
      
      {status === 'SUSPENDED' && (
        <div className="banner suspended">
          ⚠️ Your vendor account has been suspended. Contact support.
        </div>
      )}
      
      {status === 'REJECTED' && (
        <div className="banner rejected">
          ❌ Your vendor application was rejected. Contact support.
        </div>
      )}
    </div>
  );
};

export default VendorStatusBanner;
```

---

## 🚫 What You DON'T Need to Change

### ❌ No Changes Needed:

1. **API calls** - Your existing axios setup works perfectly
2. **JWT token handling** - Already handled by your interceptor
3. **Authentication flow** - Login/logout works as-is
4. **Existing components** - No breaking changes

### ✅ Backend Handles Everything:

- Role checking
- Permission validation
- Vendor approval
- Account suspension

**Your frontend just needs to handle the responses!**

---

## 📝 Minimal Changes (Copy-Paste Ready)

### Change 1: Update Login Response Handling

```javascript
// In your login component
const handleLogin = async (email, password) => {
  try {
    const response = await loginUser({ email, password });
    
    localStorage.setItem('authToken', response.token);
    localStorage.setItem('userRole', response.role); // ← Add this
    
    // Redirect based on role
    switch(response.role) {
      case 'ADMIN':
        navigate('/admin/dashboard');
        break;
      case 'VENDOR':
        navigate('/vendor/dashboard');
        break;
      default:
        navigate('/home');
    }
  } catch (error) {
    console.error('Login failed:', error);
  }
};
```

### Change 2: Update Logout

```javascript
const handleLogout = () => {
  localStorage.removeItem('authToken');
  localStorage.removeItem('userRole'); // ← Add this
  navigate('/login');
};
```

### Change 3: Add 403 Error Handling

```javascript
// In axiosInstance.js
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      localStorage.removeItem('userRole');
      window.location.href = '/login';
    }
    
    if (error.response?.status === 403) {
      alert(error.response.data || 'Access denied');
    }
    
    return Promise.reject(error);
  }
);
```

---

## 🎯 Summary

### Required Changes: **NONE** ✅
Your frontend already works with RBAC!

### Recommended Enhancements:
1. ✅ Store user role in localStorage
2. ✅ Handle 403 errors gracefully
3. ✅ Redirect based on role after login

### Optional Enhancements:
1. 🎨 Role-based navigation
2. 🎨 Protected routes
3. 🎨 Vendor status banner
4. 🎨 Role-based UI components

---

## 🧪 Testing

### Test 1: Login as Different Roles

```javascript
// Login as user
loginUser({ email: 'user@example.com', password: 'pass' })
// Should redirect to /home

// Login as vendor
loginUser({ email: 'vendor@example.com', password: 'pass' })
// Should redirect to /vendor/dashboard

// Login as admin
loginUser({ email: 'admin@example.com', password: 'pass' })
// Should redirect to /admin/dashboard
```

### Test 2: Try Accessing Wrong Endpoint

```javascript
// Login as user
// Try to access admin dashboard
navigate('/admin/dashboard')
// Backend returns 403, frontend shows error
```

---

## 🎉 Conclusion

**Your frontend is already RBAC-ready!** The backend enforces all security rules. Frontend changes are purely for **better UX**, not security.

**Security is enforced on the backend** - even if someone bypasses frontend checks, the backend will block them.

---

## 📚 Quick Reference

```javascript
// Get current user role
const userRole = localStorage.getItem('userRole');

// Check if user is admin
const isAdmin = userRole === 'ADMIN';

// Check if user is vendor
const isVendor = userRole === 'VENDOR';

// Check if user is regular user
const isUser = userRole === 'USER';

// Conditional rendering
{isAdmin && <AdminPanel />}
{isVendor && <VendorPanel />}
{isUser && <UserPanel />}
```

---

**That's it! Your frontend is ready to work with RBAC.** 🚀
