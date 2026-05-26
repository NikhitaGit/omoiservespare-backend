# ✅ Quick Integration Checklist

## Before You Start
- [ ] Backend is running on port 8080
- [ ] You can login successfully
- [ ] JWT token is saved in localStorage

---

## Installation (2 minutes)
```bash
npm install sockjs-client @stomp/stompjs
```

---

## Files to Copy (5 minutes)

### 1. API Files → `src/api/`
- [ ] Copy `adminDashboardApi.js` to `src/api/adminDashboardApi.js`
- [ ] Copy `rewardsApi.js` to `src/api/rewardsApi.js`

### 2. Hook → `src/hooks/`
- [ ] Create folder `src/hooks/` (if not exists)
- [ ] Copy `useAdminWebSocket.js` to `src/hooks/useAdminWebSocket.js`

### 3. Components
- [ ] Replace `AdminDashboard.jsx` with `AdminDashboard_UPDATED.jsx`
- [ ] Replace `Rewards.jsx` with `Rewards_UPDATED.jsx`

### 4. Environment
- [ ] Add to `.env`:
```env
VITE_API_BASE_URL=http://localhost:8080
VITE_WS_URL=http://localhost:8080/ws
```

---

## Testing (5 minutes)

### Test 1: Login
- [ ] Login works
- [ ] Token saved: `localStorage.getItem('authToken')`

### Test 2: Admin Dashboard
- [ ] Dashboard loads
- [ ] Shows real data
- [ ] Green "● Live" indicator appears
- [ ] Console shows: "✅ Dashboard data loaded"

### Test 3: Rewards
- [ ] Rewards page loads
- [ ] Shows progress bars
- [ ] Can claim unlocked rewards

### Test 4: Real-time
- [ ] Place an order
- [ ] Dashboard updates automatically
- [ ] Console shows: "📊 Dashboard update received"

---

## Quick Commands

```bash
# Start backend
mvn spring-boot:run

# Start frontend
npm run dev

# Check backend
curl http://localhost:8080/api/admin/dashboard/health

# Check token
# In browser console:
localStorage.getItem('authToken')
```

---

## Done! 🎉

Your frontend is now connected to the backend with:
- ✅ JWT authentication
- ✅ Real-time updates
- ✅ Production-grade APIs
