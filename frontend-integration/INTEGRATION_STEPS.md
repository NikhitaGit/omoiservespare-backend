# 🚀 Frontend Integration - Step by Step Guide

## Overview
Your existing axios setup is already perfect! It handles JWT tokens automatically. You just need to add the new API files and update components.

---

## Step 1: Install Required Packages (2 minutes)

```bash
npm install sockjs-client @stomp/stompjs
```

---

## Step 2: Copy API Files to Your Project (3 minutes)

Copy these files from `frontend-integration/` folder to your `src/api/` folder:

1. **adminDashboardApi.js** → `src/api/adminDashboardApi.js`
2. **rewardsApi.js** → `src/api/rewardsApi.js`

These files use your existing `axiosInstance.js`, so JWT tokens are handled automatically!

---

## Step 3: Copy WebSocket Hook (2 minutes)

Create a new folder: `src/hooks/`

Copy this file:
- **useAdminWebSocket.js** → `src/hooks/useAdminWebSocket.js`

---

## Step 4: Update Environment Variables (1 minute)

Add to your `.env` file:

```env
VITE_API_BASE_URL=http://localhost:8080
VITE_WS_URL=http://localhost:8080/ws
```

---

## Step 5: Replace Components (5 minutes)

### Admin Dashboard
Replace your `AdminDashboard.jsx` with `AdminDashboard_UPDATED.jsx`

**Changes:**
- Fetches real data from backend API
- Shows loading/error states
- Real-time updates via WebSocket
- Uses your existing CSS

### Rewards Page
Replace your `Rewards.jsx` with `Rewards_UPDATED.jsx`

**Changes:**
- Fetches rewards from backend
- Shows progress bars
- Claim button functionality
- Locked/unlocked states

---

## Step 6: Test Everything (5 minutes)

### Test 1: Login
```
1. Login to your app
2. Check browser console: localStorage.getItem('authToken')
3. Should show JWT token
```

### Test 2: Admin Dashboard
```
1. Navigate to admin dashboard
2. Should load real data from database
3. Check console for "✅ Dashboard data loaded"
4. Look for green "● Live" indicator (WebSocket connected)
```

### Test 3: Rewards Page
```
1. Navigate to rewards page
2. Should show rewards with progress
3. Try claiming an unlocked reward
4. Amount should be added to wallet
```

---

## How It Works

### JWT Token Flow
```
1. User logs in
   ↓
2. Backend returns JWT token
   ↓
3. Your authApi.js saves: localStorage.setItem('authToken', token)
   ↓
4. axiosInstance.js adds token to ALL requests automatically
   ↓
5. Backend validates token and returns data
```

### Real-Time Updates
```
1. WebSocket connects to backend
   ↓
2. User places order
   ↓
3. Backend publishes event
   ↓
4. WebSocket receives event
   ↓
5. Dashboard updates instantly
```

---

## File Structure

```
src/
├── api/
│   ├── axiosInstance.js          (✅ Already exists - no changes needed)
│   ├── authApi.js                (✅ Already exists - no changes needed)
│   ├── ordersApi.js              (✅ Already exists - no changes needed)
│   ├── adminDashboardApi.js      (🆕 NEW - copy from frontend-integration/)
│   └── rewardsApi.js             (🆕 NEW - copy from frontend-integration/)
├── hooks/
│   └── useAdminWebSocket.js      (🆕 NEW - copy from frontend-integration/)
├── components/
│   ├── AdminDashboard.jsx        (🔄 REPLACE with AdminDashboard_UPDATED.jsx)
│   └── Rewards.jsx               (🔄 REPLACE with Rewards_UPDATED.jsx)
└── .env                          (🔄 ADD WebSocket URL)
```

---

## API Endpoints Used

### Admin Dashboard
```
GET /api/admin/dashboard?range=week
Authorization: Bearer <token>

Response:
{
  "kpis": { "todayRevenue": 450, "totalRevenue": 3200, ... },
  "trendingItems": [...],
  "revenueSeries": [...],
  "topSoldToday": [...],
  "leastSoldToday": [...],
  "categoryDistribution": [...],
  "sessions": { "totalSessions": 845, "liveVisitors": 12 },
  "customerRate": { "returningPercent": 65.5 },
  "insights": [...]
}
```

### Rewards
```
GET /api/rewards
Authorization: Bearer <token>

Response:
{
  "rewards": [
    {
      "ruleId": 1,
      "name": "Monthly Cashback",
      "rewardAmount": 75,
      "isUnlocked": true,
      "isClaimed": false,
      "currentProgress": 1200,
      "targetValue": 1000,
      "progressPercent": 100
    }
  ],
  "totalRewards": 3,
  "unlockedCount": 1
}
```

```
POST /api/rewards/{rewardId}/claim
Authorization: Bearer <token>

Response:
{
  "message": "Reward claimed successfully!",
  "status": "success"
}
```

---

## Troubleshooting

### "401 Unauthorized"
**Problem:** Token missing or expired

**Solution:**
```javascript
// Check token in console
console.log(localStorage.getItem('authToken'));

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

### WebSocket not connecting
**Problem:** WebSocket URL incorrect

**Solution:**
```
Check .env file:
VITE_WS_URL=http://localhost:8080/ws

Restart React dev server after changing .env
```

### Data not showing
**Problem:** No orders in database

**Solution:**
```
1. Place some test orders first
2. Then check admin dashboard
3. Backend returns empty arrays if no data
```

---

## Summary

✅ Your existing axios setup already handles JWT tokens perfectly
✅ Just add 3 new files (2 API files + 1 hook)
✅ Replace 2 components (AdminDashboard + Rewards)
✅ Everything works with your existing authentication

**Total time: ~15 minutes**

---

## Next Steps

1. Copy files to your project
2. Install packages
3. Test login → dashboard → rewards flow
4. Place test order to see real-time updates

**You're all set!** 🎉
