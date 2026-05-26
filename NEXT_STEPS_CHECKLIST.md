# ✅ Next Steps Checklist

## 🎯 Your Current Status

✅ Backend is running on port 8080
✅ Kafka is running
✅ Database is configured
✅ All APIs are ready
✅ WebSocket is configured
✅ Documentation is complete

---

## 📋 Frontend Integration Checklist

### Step 1: Install Dependencies (2 minutes)
```bash
cd your-react-app
npm install axios sockjs-client @stomp/stompjs
```

**Status:** ⬜ Not started

---

### Step 2: Create API Service (5 minutes)

**File:** `src/services/adminDashboardApi.js`

**Copy from:** `FRONTEND_INTEGRATION_GUIDE.md` (Section: "Step 2")

**What it does:**
- Creates axios instance
- Auto-adds JWT token to requests
- Handles 401 errors

**Status:** ⬜ Not started

---

### Step 3: Create WebSocket Hook (5 minutes)

**File:** `src/hooks/useAdminWebSocket.js`

**Copy from:** `FRONTEND_INTEGRATION_GUIDE.md` (Section: "Step 3")

**What it does:**
- Connects to WebSocket
- Subscribes to dashboard updates
- Handles real-time events

**Status:** ⬜ Not started

---

### Step 4: Update AdminDashboard Component (15 minutes)

**File:** `src/pages/AdminDashboard.jsx` (or wherever your component is)

**Changes needed:**
1. Import API service and WebSocket hook
2. Replace mock data with API calls
3. Add loading and error states
4. Connect to WebSocket

**Before:**
```javascript
const [orders, setOrders] = useState(() => safeReadOrders());
```

**After:**
```javascript
const [dashboard, setDashboard] = useState(null);

useEffect(() => {
  adminDashboardApi.getDashboard(range)
    .then(data => setDashboard(data))
    .catch(err => console.error(err));
}, [range]);
```

**Status:** ⬜ Not started

---

### Step 5: Test Login Flow (5 minutes)

**Verify JWT token is saved:**

1. Login to your app
2. Open browser console
3. Check localStorage:
   ```javascript
   localStorage.getItem('token')
   ```
4. Should see: `"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`

**If no token:**
- Check your login component
- Make sure it saves token after successful login:
  ```javascript
  localStorage.setItem('token', response.data.token);
  ```

**Status:** ⬜ Not started

---

### Step 6: Test Dashboard API (5 minutes)

**Open browser console and run:**
```javascript
// Test API call
fetch('http://localhost:8080/api/admin/dashboard?range=week', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`
  }
})
.then(res => res.json())
.then(data => console.log('Dashboard data:', data))
.catch(err => console.error('Error:', err));
```

**Expected result:**
- Status: 200 OK
- Response: Dashboard data with kpis, trendingItems, etc.

**If 401 error:**
- Token is missing or invalid
- Login again to get fresh token

**Status:** ⬜ Not started

---

### Step 7: Test WebSocket (5 minutes)

**Open browser console and run:**
```javascript
const socket = new SockJS('http://localhost:8080/ws');
const stompClient = Stomp.over(socket);

stompClient.connect({}, () => {
  console.log('✅ Connected to WebSocket');
  
  stompClient.subscribe('/topic/admin/dashboard', (message) => {
    console.log('📊 Update received:', JSON.parse(message.body));
  });
});
```

**Expected result:**
- Console shows: "✅ Connected to WebSocket"
- When you place an order, console shows update

**Status:** ⬜ Not started

---

### Step 8: Test Complete Flow (10 minutes)

1. **Open admin dashboard**
   - Should load data from API
   - Should show real metrics

2. **Place a test order**
   - Use your customer app
   - Complete payment

3. **Watch dashboard update**
   - KPIs should update in real-time
   - Console should show WebSocket event

4. **Change date range**
   - Select "Today", "This Month", etc.
   - Dashboard should refresh with new data

**Status:** ⬜ Not started

---

## 🐛 Troubleshooting

### Issue: "Cannot read property 'kpis' of null"
**Cause:** Dashboard data not loaded yet

**Solution:**
```javascript
if (!dashboard) return <div>Loading...</div>;
```

---

### Issue: "401 Unauthorized"
**Cause:** JWT token missing or invalid

**Solution:**
1. Check if token exists: `localStorage.getItem('token')`
2. If no token, login again
3. If token exists but still 401, token might be expired

---

### Issue: "CORS error"
**Cause:** Backend not allowing frontend origin

**Solution:** Backend already configured with `@CrossOrigin(origins = "*")`
If still having issues, check browser console for exact error

---

### Issue: "WebSocket connection failed"
**Cause:** Backend not running or WebSocket not configured

**Solution:**
1. Check if backend is running: `http://localhost:8080`
2. Check WebSocket endpoint: `http://localhost:8080/ws`

---

### Issue: "Network Error"
**Cause:** Backend not running

**Solution:**
```powershell
# Check if running
netstat -ano | findstr :8080

# If not running, start it
mvn spring-boot:run
```

---

## 📚 Reference Documents

**For complete code examples:**
- `FRONTEND_INTEGRATION_GUIDE.md` - Full React integration
- `QUICK_FRONTEND_SETUP.md` - 5-minute quick setup
- `JWT_TOKEN_FLOW.md` - Authentication flow

**For backend reference:**
- `ADMIN_DASHBOARD_IMPLEMENTATION.md` - Backend architecture
- `ADMIN_DASHBOARD_COMPLETE.md` - API reference

**For testing:**
- `test-admin-dashboard.ps1` - Test backend APIs

---

## 🎯 Success Criteria

You'll know it's working when:

✅ Dashboard loads without errors
✅ Shows real data from database
✅ KPIs display correct numbers
✅ Charts render with actual data
✅ Trending items show with images
✅ Real-time updates work when order placed
✅ Date range selector changes data
✅ No console errors

---

## ⏱️ Estimated Time

- **Minimum (basic integration):** 30 minutes
- **Complete (with WebSocket):** 60 minutes
- **With testing:** 90 minutes

---

## 🚀 Ready to Start?

1. ✅ Backend is running
2. ✅ Documentation is ready
3. ✅ Code examples provided
4. ⬜ Frontend integration pending

**Start with Step 1 and work through the checklist!**

---

## 💡 Pro Tips

1. **Start simple:** Get basic API call working first, then add WebSocket
2. **Use console.log:** Debug by logging API responses
3. **Check Network tab:** See actual API requests in browser DevTools
4. **Test incrementally:** Test each step before moving to next
5. **Keep backend running:** Don't stop Spring Boot while testing

---

## 📞 Need Help?

**Check these first:**
1. Is backend running? → `netstat -ano | findstr :8080`
2. Is Kafka running? → `.\check-kafka-status.ps1`
3. Is token valid? → `localStorage.getItem('token')`
4. Any console errors? → Check browser console

**Still stuck?**
- Review `FRONTEND_INTEGRATION_GUIDE.md`
- Check `JWT_TOKEN_FLOW.md` for auth issues
- Look at `SESSION_SUMMARY.md` for overview

---

**Good luck! You've got this!** 🎉

Mark each step as ✅ when complete!
