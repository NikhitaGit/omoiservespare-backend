# ⚡ Quick Frontend Setup - 5 Minutes

## 🚀 Super Fast Setup

### 1. Install Packages (1 minute)
```bash
npm install axios sockjs-client @stomp/stompjs
```

### 2. Create API Service (2 minutes)

**File:** `src/services/adminDashboardApi.js`

```javascript
import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:8080/api',
});

// Auto-add JWT token
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const adminDashboardApi = {
  getDashboard: async (range = 'week') => {
    const response = await apiClient.get(`/admin/dashboard?range=${range}`);
    return response.data;
  },
};
```

### 3. Update Your Component (2 minutes)

**In your `AdminDashboard.jsx`:**

```javascript
import { useEffect, useState } from 'react';
import { adminDashboardApi } from '../services/adminDashboardApi';

const AdminDashboard = () => {
  const [dashboard, setDashboard] = useState(null);
  const [range, setRange] = useState('week');
  
  useEffect(() => {
    // Fetch from API instead of localStorage
    adminDashboardApi.getDashboard(range)
      .then(data => setDashboard(data))
      .catch(err => console.error(err));
  }, [range]);
  
  if (!dashboard) return <div>Loading...</div>;
  
  return (
    <div>
      {/* Use dashboard.kpis.todayRevenue instead of mock data */}
      <h1>Today Revenue: ₹{dashboard.kpis.todayRevenue}</h1>
      <h2>Total Orders: {dashboard.kpis.totalOrders}</h2>
      
      {/* Trending items */}
      {dashboard.trendingItems.map(item => (
        <div key={item.itemId}>
          <img src={item.imageUrl} alt={item.name} />
          <h3>{item.name}</h3>
          <p>{item.quantitySold} sold • ₹{item.revenue}</p>
          <span>{item.insight}</span>
        </div>
      ))}
      
      {/* Use your existing chart component */}
      <AreaChart data={dashboard.revenueSeries} />
    </div>
  );
};
```

---

## 🔥 Real-Time Updates (Optional - 3 minutes)

**Add WebSocket:**

```javascript
import { useEffect } from 'react';
import SockJS from 'sockjs-client';
import { Stomp } from '@stomp/stompjs';

// Inside your component
useEffect(() => {
  const socket = new SockJS('http://localhost:8080/ws');
  const stompClient = Stomp.over(socket);
  
  stompClient.connect({}, () => {
    stompClient.subscribe('/topic/admin/dashboard', (message) => {
      const event = JSON.parse(message.body);
      
      if (event.type === 'ORDER_COMPLETED') {
        // Update dashboard
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
  
  return () => stompClient.disconnect();
}, []);
```

---

## ✅ That's It!

**3 simple changes:**
1. ✅ Install packages
2. ✅ Create API service
3. ✅ Replace localStorage with API calls

**Your dashboard now:**
- ✅ Fetches real data from backend
- ✅ Uses JWT authentication
- ✅ Updates in real-time (optional)

---

## 🎯 Key Replacements

| Old (Mock Data) | New (Real API) |
|----------------|----------------|
| `localStorage.getItem('orders')` | `dashboard.kpis.totalOrders` |
| `MOCK_ORDERS` | `dashboard.revenueSeries` |
| `rewardsData` | `dashboard.trendingItems` |
| Manual calculations | Backend calculates everything |

---

## 🔑 JWT Token

**How it works:**
1. User logs in → Token saved to localStorage
2. API service reads token automatically
3. Adds to every request
4. Backend validates and returns data

**Login example:**
```javascript
// When user logs in
const response = await axios.post('/api/auth/login', { email, password });
localStorage.setItem('token', response.data.token);
```

---

## 📝 Full Example in FRONTEND_INTEGRATION_GUIDE.md

For complete code with error handling, loading states, and WebSocket, see:
- `FRONTEND_INTEGRATION_GUIDE.md`

---

**Done! Your dashboard is now connected to the backend!** 🎉
