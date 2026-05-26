# 🎨 Frontend Integration Guide - Admin Dashboard

## Step-by-Step: Connect React to Backend API

---

## Step 1: Install Required Packages

```bash
npm install axios sockjs-client @stomp/stompjs
```

**What these do:**
- `axios` - Makes HTTP requests to backend
- `sockjs-client` - WebSocket connection
- `@stomp/stompjs` - WebSocket messaging protocol

---

## Step 2: Create API Service File

Create a new file: `src/services/adminDashboardApi.js`

```javascript
import axios from 'axios';

// Base URL for your backend
const API_BASE_URL = 'http://localhost:8080/api';

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add JWT token to every request automatically
apiClient.interceptors.request.use(
  (config) => {
    // Get token from localStorage
    const token = localStorage.getItem('token');
    
    if (token) {
      // Add Authorization header
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle 401 errors (token expired)
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      console.error('Authentication failed. Please login again.');
      // Optionally redirect to login
      // window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Admin Dashboard API functions
export const adminDashboardApi = {
  /**
   * Get dashboard data
   * @param {string} range - 'today', 'week', 'month', 'year'
   * @param {string} start - Optional start date (YYYY-MM-DD)
   * @param {string} end - Optional end date (YYYY-MM-DD)
   */
  getDashboard: async (range = 'week', start = null, end = null) => {
    try {
      let url = `/admin/dashboard?range=${range}`;
      
      if (start && end) {
        url = `/admin/dashboard?start=${start}&end=${end}`;
      }
      
      const response = await apiClient.get(url);
      return response.data;
    } catch (error) {
      console.error('Failed to fetch dashboard:', error);
      throw error;
    }
  },
  
  /**
   * Health check
   */
  healthCheck: async () => {
    try {
      const response = await apiClient.get('/admin/dashboard/health');
      return response.data;
    } catch (error) {
      console.error('Health check failed:', error);
      throw error;
    }
  },
};

export default apiClient;
```

---

## Step 3: Create WebSocket Hook

Create a new file: `src/hooks/useAdminWebSocket.js`

```javascript
import { useEffect, useRef, useState } from 'react';
import SockJS from 'sockjs-client';
import { Stomp } from '@stomp/stompjs';

/**
 * Custom hook for admin dashboard WebSocket connection
 * Automatically connects and subscribes to dashboard updates
 */
export const useAdminWebSocket = (onUpdate) => {
  const [connected, setConnected] = useState(false);
  const stompClientRef = useRef(null);
  
  useEffect(() => {
    // Create WebSocket connection
    const socket = new SockJS('http://localhost:8080/ws');
    const stompClient = Stomp.over(socket);
    
    // Disable debug logs (optional)
    stompClient.debug = () => {};
    
    // Connect to WebSocket
    stompClient.connect(
      {},
      () => {
        console.log('✅ Connected to WebSocket');
        setConnected(true);
        
        // Subscribe to admin dashboard updates
        stompClient.subscribe('/topic/admin/dashboard', (message) => {
          try {
            const event = JSON.parse(message.body);
            console.log('📊 Dashboard update received:', event);
            
            // Call the callback function with the event
            if (onUpdate) {
              onUpdate(event);
            }
          } catch (error) {
            console.error('Failed to parse WebSocket message:', error);
          }
        });
      },
      (error) => {
        console.error('❌ WebSocket connection error:', error);
        setConnected(false);
      }
    );
    
    stompClientRef.current = stompClient;
    
    // Cleanup on unmount
    return () => {
      if (stompClient && stompClient.connected) {
        stompClient.disconnect(() => {
          console.log('🔌 Disconnected from WebSocket');
        });
      }
    };
  }, [onUpdate]);
  
  return { connected };
};
```

---

## Step 4: Update Your AdminDashboard Component

Replace your existing `AdminDashboard.jsx` with this:

```javascript
import React, { useEffect, useState, useCallback } from "react";
import { adminDashboardApi } from "../services/adminDashboardApi";
import { useAdminWebSocket } from "../hooks/useAdminWebSocket";
import "../styles/adminDashboard.css";

// Import your existing components
import { Ring, AreaChart } from "../components/DashboardComponents"; // Adjust path

const RANGE_OPTIONS = [
  { key: "today", label: "Today" },
  { key: "week", label: "This Week" },
  { key: "15d", label: "Last 15 Days" },
  { key: "month", label: "This Month" },
  { key: "year", label: "This Year" },
];

const AdminDashboard = () => {
  const [range, setRange] = useState("week");
  const [dashboard, setDashboard] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Fetch dashboard data from API
  const fetchDashboard = useCallback(async (selectedRange) => {
    setLoading(true);
    setError(null);
    
    try {
      const data = await adminDashboardApi.getDashboard(selectedRange);
      setDashboard(data);
      console.log('✅ Dashboard data loaded:', data);
    } catch (err) {
      console.error('❌ Failed to load dashboard:', err);
      setError('Failed to load dashboard. Please try again.');
      
      // Check if it's an auth error
      if (err.response?.status === 401) {
        setError('Please login to view the dashboard.');
      }
    } finally {
      setLoading(false);
    }
  }, []);
  
  // Handle WebSocket updates
  const handleWebSocketUpdate = useCallback((event) => {
    console.log('🔄 Real-time update:', event);
    
    if (event.type === 'ORDER_COMPLETED') {
      // Update KPIs in real-time
      setDashboard(prev => {
        if (!prev) return prev;
        
        return {
          ...prev,
          kpis: {
            ...prev.kpis,
            todayRevenue: prev.kpis.todayRevenue + (event.amount || 0),
            totalOrders: prev.kpis.totalOrders + 1,
          }
        };
      });
      
      // Optionally refresh full dashboard
      // fetchDashboard(range);
    }
  }, [range]);
  
  // Connect to WebSocket
  const { connected } = useAdminWebSocket(handleWebSocketUpdate);
  
  // Initial load
  useEffect(() => {
    fetchDashboard(range);
  }, [range, fetchDashboard]);
  
  // Loading state
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
  
  // Error state
  if (error) {
    return (
      <div className="adm2">
        <main className="adm2Main">
          <div style={{ textAlign: 'center', padding: '50px', color: 'red' }}>
            <h2>Error</h2>
            <p>{error}</p>
            <button onClick={() => fetchDashboard(range)}>Retry</button>
          </div>
        </main>
      </div>
    );
  }
  
  // No data state
  if (!dashboard) {
    return (
      <div className="adm2">
        <main className="adm2Main">
          <div style={{ textAlign: 'center', padding: '50px' }}>
            <h2>No data available</h2>
          </div>
        </main>
      </div>
    );
  }
  
  // Main render
  return (
    <div className="adm2 noSidebar">
      <main className="adm2Main">
        {/* Topbar */}
        <div className="adm2Topbar">
          <div>
            <h1 className="adm2Title">Admin Dashboard</h1>
            <p className="adm2Sub">
              Revenue, orders, trending items and performance overview.
              {connected && <span style={{ color: '#4ade80', marginLeft: '10px' }}>● Live</span>}
            </p>
          </div>
          <div className="adm2TopbarRight">
            <select 
              value={range} 
              onChange={(e) => setRange(e.target.value)} 
              className="adm2Select"
            >
              {RANGE_OPTIONS.map((r) => (
                <option key={r.key} value={r.key}>{r.label}</option>
              ))}
            </select>
          </div>
        </div>

        {/* KPI Cards */}
        <section className="adm2Kpis">
          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Today Revenue</div>
                <div className="kpiBig">₹{dashboard.kpis.todayRevenue.toFixed(2)}</div>
              </div>
              <Ring value={dashboard.kpis.todayRevenue} max={2000} className="ringOrange" />
            </div>
            <div className="kpiFoot">
              {dashboard.kpis.todayRevenueGrowth > 0 && (
                <span>↑ {dashboard.kpis.todayRevenueGrowth.toFixed(1)}% growth</span>
              )}
            </div>
          </div>

          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Total Revenue</div>
                <div className="kpiBig">₹{dashboard.kpis.totalRevenue.toFixed(2)}</div>
              </div>
              <Ring value={dashboard.kpis.totalRevenue} max={10000} className="ringBlue" />
            </div>
            <div className="kpiFoot">Selected range</div>
          </div>

          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Total Orders</div>
                <div className="kpiBig">{dashboard.kpis.totalOrders}</div>
              </div>
              <Ring value={dashboard.kpis.totalOrders} max={100} className="ringGreen" />
            </div>
            <div className="kpiFoot">Paid orders count</div>
          </div>

          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Customers</div>
                <div className="kpiBig">{dashboard.kpis.customers}</div>
              </div>
              <Ring value={dashboard.kpis.customers} max={50} className="ringPurple" />
            </div>
            <div className="kpiFoot">Unique in range</div>
          </div>
        </section>

        {/* Main Grid */}
        <section className="adm2Grid">
          {/* Left Column */}
          <div className="adm2Col">
            {/* Trending Items */}
            <div className="panel">
              <div className="panelTop">
                <h3>Trending Items</h3>
                <span className="pill2">Top selling</span>
              </div>
              <div className="trendList">
                {dashboard.trendingItems.length === 0 ? (
                  <div className="empty">No trending items in this range.</div>
                ) : (
                  dashboard.trendingItems.map((item, idx) => (
                    <div className="trendRow" key={item.itemId}>
                      <div className="rank">#{idx + 1}</div>
                      <div className="trendThumb">
                        {item.imageUrl ? (
                          <img src={item.imageUrl} alt={item.name} />
                        ) : (
                          item.name?.[0]?.toUpperCase() || "🍽"
                        )}
                      </div>
                      <div className="trendMeta">
                        <div className="trendName">{item.name}</div>
                        <div className="trendSub">
                          ₹{item.revenue.toFixed(2)} • {item.quantitySold} sold
                        </div>
                      </div>
                      <div className={`trendChip ${item.growthPercent >= 0 ? 'up' : 'down'}`}>
                        {item.growthPercent >= 0 ? '↑' : '↓'}
                        {Math.abs(item.growthPercent).toFixed(1)}%
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>

            {/* Revenue Chart */}
            <div className="panel">
              <div className="panelTop">
                <h3>Revenue Overview</h3>
                <span className="muted2">Line + area chart</span>
              </div>
              {dashboard.revenueSeries.length === 0 ? (
                <div className="empty">No data for this range.</div>
              ) : (
                <AreaChart data={dashboard.revenueSeries} />
              )}
            </div>

            {/* Top vs Least Sold */}
            <div className="panel">
              <div className="panelTop">
                <h3>Top vs Least Sold (Today)</h3>
                <span className="muted2">Quick check</span>
              </div>
              <div className="twoTables">
                <div className="miniTable">
                  <div className="miniHead">
                    <span>Top Sold</span>
                    <span className="pill2">Qty</span>
                  </div>
                  {dashboard.topSoldToday.map((item) => (
                    <div className="miniRow" key={item.itemId}>
                      <span className="miniName">{item.name}</span>
                      <span className="miniNum">{item.qty}</span>
                    </div>
                  ))}
                </div>
                <div className="miniTable">
                  <div className="miniHead">
                    <span>Least Sold</span>
                    <span className="pill2 ghost">0 included</span>
                  </div>
                  {dashboard.leastSoldToday.map((item) => (
                    <div className="miniRow" key={item.itemId}>
                      <span className="miniName">{item.name}</span>
                      <span className="miniNum">{item.qty}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="adm2Col right">
            {/* Category Split */}
            <div className="panel">
              <div className="panelTop">
                <h3>Category Split</h3>
                <span className="muted2">Menu distribution</span>
              </div>
              <div className="donutBox">
                <div className="donut" style={{
                  background: `conic-gradient(
                    var(--c1) 0 ${dashboard.categoryDistribution[0]?.percentage || 0}%,
                    var(--c2) ${dashboard.categoryDistribution[0]?.percentage || 0}% ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0)}%,
                    var(--c3) ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0)}% ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0) + (dashboard.categoryDistribution[2]?.percentage || 0)}%,
                    var(--c4) ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0) + (dashboard.categoryDistribution[2]?.percentage || 0)}% 100%
                  )`
                }}>
                  <div className="donutHole">
                    <div className="donutBig">
                      {dashboard.categoryDistribution.reduce((sum, cat) => sum + cat.count, 0)}
                    </div>
                    <div className="donutSub">Items</div>
                  </div>
                </div>
                <div className="legend">
                  {dashboard.categoryDistribution.map((cat, idx) => (
                    <div className="legRow" key={cat.category}>
                      <span className={`dot dot${idx + 1}`} />
                      <span className="legName">{cat.category}</span>
                      <span className="legVal">{Math.round(cat.percentage)}%</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Sessions */}
            <div className="panel">
              <div className="panelTop">
                <h3>Total Sessions</h3>
                <span className="muted2">Traffic</span>
              </div>
              <div className="statBig">{dashboard.sessions.totalSessions}</div>
              <div className="statSub">Live: {dashboard.sessions.liveVisitors} visitors</div>
            </div>

            {/* Customer Rate */}
            <div className="panel">
              <div className="panelTop">
                <h3>Customer Rate</h3>
                <span className="muted2">Repeat / retention</span>
              </div>
              <div className="rateRow">
                <div className="statBig">{dashboard.customerRate.returningPercent.toFixed(1)}%</div>
                <div className="rateBars">
                  <div className="ratePill">
                    <span className="dot dot2" /> Returning
                  </div>
                  <div className="ratePill">
                    <span className="dot dot1" /> First time
                  </div>
                </div>
              </div>
            </div>

            {/* Insights */}
            {dashboard.insights && dashboard.insights.length > 0 && (
              <div className="panel">
                <div className="panelTop">
                  <h3>Insights</h3>
                  <span className="muted2">AI-generated</span>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {dashboard.insights.map((insight, idx) => (
                    <div key={idx} style={{ 
                      padding: '10px', 
                      background: 'rgba(59, 130, 246, 0.1)', 
                      borderRadius: '8px',
                      fontSize: '14px',
                      fontWeight: '500'
                    }}>
                      💡 {insight}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </section>
      </main>
    </div>
  );
};

export default AdminDashboard;
```

---

## Step 5: Extract Ring and AreaChart Components

Create `src/components/DashboardComponents.jsx`:

```javascript
import React from 'react';

// Ring component (from your existing code)
export function Ring({ value, max = 100, size = 44, stroke = 7, className = "" }) {
  const v = Math.max(0, Math.min(value, max));
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const p = max === 0 ? 0 : v / max;
  const dash = c * p;
  
  return (
    <svg
      className={`ring ${className}`}
      width={size}
      height={size}
      viewBox={`0 0 ${size} ${size}`}
      aria-hidden="true"
    >
      <circle
        className="ringTrack"
        cx={size / 2}
        cy={size / 2}
        r={r}
        strokeWidth={stroke}
        fill="none"
      />
      <circle
        className="ringValue"
        cx={size / 2}
        cy={size / 2}
        r={r}
        strokeWidth={stroke}
        fill="none"
        strokeDasharray={`${dash} ${c - dash}`}
        strokeLinecap="round"
        transform={`rotate(-90 ${size / 2} ${size / 2})`}
      />
    </svg>
  );
}

// AreaChart component (from your existing code)
export function AreaChart({ data }) {
  const W = 640;
  const H = 240;
  const P = 22;
  
  const vals = data.map((d) => d.sales);
  const max = Math.max(...vals, 1);
  const xStep = data.length <= 1 ? 0 : (W - 2 * P) / (data.length - 1);
  
  const pts = data.map((d, i) => {
    const x = P + i * xStep;
    const y = H - P - (d.sales / max) * (H - 2 * P);
    return { x, y, label: d.label, value: d.sales };
  });
  
  const line = pts.map((p) => `${p.x},${p.y}`).join(" ");
  const area = `${P},${H - P} ${line} ${P + xStep * (pts.length - 1)},${H - P}`;
  
  return (
    <div className="areaChart">
      <svg viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none">
        <line className="gridLine" x1={P} y1={H - P} x2={W - P} y2={H - P} />
        <line className="gridLine" x1={P} y1={P} x2={P} y2={H - P} />
        <polygon className="areaFill" points={area} />
        <polyline className="areaLine" points={line} />
        {pts.map((p, idx) => (
          <g key={idx}>
            <circle className="areaDot" cx={p.x} cy={p.y} r="4" />
          </g>
        ))}
      </svg>
      <div className="areaXAxis">
        {data.map((d, idx) => (
          <span key={idx}>{d.label}</span>
        ))}
      </div>
    </div>
  );
}
```

---

## Step 6: How JWT Token Gets Stored

When user logs in, your login component should store the token:

```javascript
// In your Login component
const handleLogin = async (email, password) => {
  try {
    const response = await axios.post('http://localhost:8080/api/auth/login', {
      email,
      password
    });
    
    // Store the JWT token
    localStorage.setItem('token', response.data.token);
    
    // Redirect to dashboard
    navigate('/admin/dashboard');
  } catch (error) {
    console.error('Login failed:', error);
  }
};
```

---

## Step 7: Test Everything

1. **Login first** to get JWT token
2. **Navigate to admin dashboard**
3. **Watch real-time updates** when orders are placed

---

## 🎯 Summary

**What happens:**
1. User logs in → JWT token stored in localStorage
2. Dashboard loads → API service adds token to request automatically
3. Backend validates token → Returns dashboard data
4. WebSocket connects → Real-time updates start flowing
5. New order placed → Dashboard updates instantly

**Key Points:**
- ✅ Token automatically added to all requests
- ✅ WebSocket connects automatically
- ✅ Real-time updates work seamlessly
- ✅ Error handling included
- ✅ Loading states handled

**Your dashboard is now connected to the backend!** 🎉
