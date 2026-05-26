# 🚀 React JWT Integration - Copy & Paste Guide

## ⚡ 3 Simple Steps (15 minutes)

---

## Step 1: Install Packages (2 minutes)

Open your React project terminal and run:

```bash
npm install axios sockjs-client @stomp/stompjs
```

**Wait for installation to complete...**

---

## Step 2: Create API Service File (5 minutes)

### Create this file: `src/services/api.js`

**Copy this entire code:**

```javascript
import axios from 'axios';

// Backend URL
const API_URL = 'http://localhost:8080/api';

// Create axios instance
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// ✨ MAGIC: Auto-add JWT token to every request
api.interceptors.request.use(
  (config) => {
    // Get token from localStorage
    const token = localStorage.getItem('token');
    
    // If token exists, add it to headers
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle 401 errors (token expired)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired - redirect to login
      console.error('Token expired. Please login again.');
      localStorage.removeItem('token');
      // Uncomment to auto-redirect:
      // window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Export API functions
export const dashboardApi = {
  // Get dashboard data
  getDashboard: (range = 'week') => {
    return api.get(`/admin/dashboard?range=${range}`);
  },
  
  // Get rewards
  getRewards: () => {
    return api.get('/rewards');
  },
  
  // Get my rewards
  getMyRewards: () => {
    return api.get('/rewards/my-rewards');
  },
};

export default api;
```

**Save the file!**

---

## Step 3: Update Your AdminDashboard Component (8 minutes)

### Find your `AdminDashboard.jsx` file

**Replace the data fetching part with this:**

```javascript
import React, { useEffect, useState } from "react";
import { dashboardApi } from "../services/api"; // ← Add this import
import "../styles/adminDashboard.css";

// Keep your existing components (Ring, AreaChart, etc.)

const AdminDashboard = () => {
  const [range, setRange] = useState("week");
  const [dashboard, setDashboard] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // ✨ Fetch data from backend API
  useEffect(() => {
    const fetchDashboard = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Call backend API
        const response = await dashboardApi.getDashboard(range);
        setDashboard(response.data);
        console.log('✅ Dashboard loaded:', response.data);
      } catch (err) {
        console.error('❌ Error loading dashboard:', err);
        setError(err.response?.data?.message || 'Failed to load dashboard');
      } finally {
        setLoading(false);
      }
    };
    
    fetchDashboard();
  }, [range]);
  
  // Show loading
  if (loading) {
    return (
      <div className="adm2">
        <main className="adm2Main">
          <div style={{ textAlign: 'center', padding: '50px' }}>
            <h2>Loading dashboard...</h2>
          </div>
        </main>
      </div>
    );
  }
  
  // Show error
  if (error) {
    return (
      <div className="adm2">
        <main className="adm2Main">
          <div style={{ textAlign: 'center', padding: '50px', color: 'red' }}>
            <h2>Error</h2>
            <p>{error}</p>
            <button onClick={() => window.location.reload()}>Retry</button>
          </div>
        </main>
      </div>
    );
  }
  
  // Show dashboard (use your existing JSX)
  return (
    <div className="adm2 noSidebar">
      <main className="adm2Main">
        {/* Your existing dashboard JSX */}
        {/* Just replace mock data with dashboard.kpis, dashboard.trendingItems, etc. */}
        
        {/* Example: */}
        <div className="kpiCard">
          <h3>Today Revenue</h3>
          <p>₹{dashboard?.kpis?.todayRevenue || 0}</p>
        </div>
        
        {/* Keep rest of your existing code */}
      </main>
    </div>
  );
};

export default AdminDashboard;
```

---

## 🔑 How JWT Token Gets There

### In Your Login Component

**Make sure your login saves the token:**

```javascript
// In your Login.jsx or wherever you handle login
const handleLogin = async (email, password) => {
  try {
    const response = await axios.post('http://localhost:8080/api/auth/login', {
      email,
      password
    });
    
    // ✨ SAVE TOKEN - This is the key!
    localStorage.setItem('token', response.data.token);
    
    // Redirect to dashboard
    navigate('/admin/dashboard');
  } catch (error) {
    console.error('Login failed:', error);
  }
};
```

---

## ✅ Test It!

### 1. Check if token is saved

Open browser console and type:
```javascript
localStorage.getItem('token')
```

Should show: `"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`

### 2. Test API call

In browser console:
```javascript
fetch('http://localhost:8080/api/admin/dashboard?range=week', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`
  }
})
.then(res => res.json())
.then(data => console.log('Dashboard data:', data))
```

Should show dashboard data!

---

## 🎯 Quick Reference

### Where is the token?
```javascript
localStorage.getItem('token')
```

### How is it added to requests?
```javascript
// Automatically by axios interceptor in api.js
config.headers.Authorization = `Bearer ${token}`;
```

### What if I get 401 error?
```javascript
// Token is missing or expired
// Solution: Login again to get new token
localStorage.removeItem('token');
// Then redirect to login page
```

---

## 🔥 Real-Time Updates (Optional - 5 more minutes)

### Add WebSocket for live updates

**Add this to your AdminDashboard component:**

```javascript
import { useEffect } from 'react';
import SockJS from 'sockjs-client';
import { Stomp } from '@stomp/stompjs';

// Inside your component, after the API fetch useEffect:
useEffect(() => {
  // Connect to WebSocket
  const socket = new SockJS('http://localhost:8080/ws');
  const stompClient = Stomp.over(socket);
  
  // Disable debug logs
  stompClient.debug = () => {};
  
  // Connect
  stompClient.connect({}, () => {
    console.log('✅ WebSocket connected');
    
    // Subscribe to dashboard updates
    stompClient.subscribe('/topic/admin/dashboard', (message) => {
      const event = JSON.parse(message.body);
      console.log('📊 Real-time update:', event);
      
      // Update dashboard when order completed
      if (event.type === 'ORDER_COMPLETED') {
        setDashboard(prev => ({
          ...prev,
          kpis: {
            ...prev.kpis,
            todayRevenue: prev.kpis.todayRevenue + event.amount,
            totalOrders: prev.kpis.totalOrders + 1
          }
        }));
      }
    });
  });
  
  // Cleanup
  return () => {
    if (stompClient.connected) {
      stompClient.disconnect();
    }
  };
}, []);
```

---

## 📝 Complete Example

Here's a minimal working example:

```javascript
import React, { useEffect, useState } from "react";
import { dashboardApi } from "../services/api";

const AdminDashboard = () => {
  const [dashboard, setDashboard] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    dashboardApi.getDashboard('week')
      .then(res => {
        setDashboard(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error(err);
        setLoading(false);
      });
  }, []);
  
  if (loading) return <div>Loading...</div>;
  if (!dashboard) return <div>No data</div>;
  
  return (
    <div>
      <h1>Admin Dashboard</h1>
      <p>Today Revenue: ₹{dashboard.kpis.todayRevenue}</p>
      <p>Total Orders: {dashboard.kpis.totalOrders}</p>
      <p>Customers: {dashboard.kpis.customers}</p>
      
      <h2>Trending Items</h2>
      {dashboard.trendingItems.map(item => (
        <div key={item.itemId}>
          <h3>{item.name}</h3>
          <p>{item.quantitySold} sold • ₹{item.revenue}</p>
          <p>{item.insight}</p>
        </div>
      ))}
    </div>
  );
};

export default AdminDashboard;
```

---

## 🎉 That's It!

**You've done it! Your React app now:**
1. ✅ Calls backend API with JWT token
2. ✅ Token is added automatically
3. ✅ Shows real data from database
4. ✅ Handles errors properly

**Test it:**
1. Login to your app
2. Navigate to admin dashboard
3. Should see real data!

---

## 🐛 Troubleshooting

### "401 Unauthorized"
**Problem:** No token or invalid token

**Solution:**
```javascript
// Check if token exists
console.log(localStorage.getItem('token'));

// If no token, login again
// If token exists but still 401, token expired - login again
```

### "Network Error"
**Problem:** Backend not running

**Solution:**
```powershell
# Check if backend is running
netstat -ano | findstr :8080

# If not running, start it
mvn spring-boot:run
```

### "CORS Error"
**Problem:** Backend not allowing frontend

**Solution:** Backend already configured with `@CrossOrigin(origins = "*")`

---

## 📚 Need More Help?

Check these files:
- `FRONTEND_INTEGRATION_GUIDE.md` - Detailed guide
- `JWT_TOKEN_FLOW.md` - How authentication works
- `QUICK_FRONTEND_SETUP.md` - Quick reference

---

**You're all set! Happy coding!** 🚀
