# 🔐 JWT Token Flow - Visual Guide

## How JWT Authentication Works

```
┌─────────────────────────────────────────────────────────────┐
│                    1. USER LOGS IN                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Frontend (React)                                           │
│  ─────────────────                                          │
│  const handleLogin = async () => {                          │
│    const response = await axios.post(                       │
│      'http://localhost:8080/api/auth/login',                │
│      { email: 'admin@example.com', password: 'pass123' }    │
│    );                                                        │
│                                                              │
│    // ✅ SAVE TOKEN                                         │
│    localStorage.setItem('token', response.data.token);      │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Backend (Spring Boot)                                      │
│  ──────────────────────                                     │
│  @PostMapping("/api/auth/login")                            │
│  public ResponseEntity<?> login(@RequestBody LoginDTO dto) {│
│    // Validate credentials                                  │
│    String token = jwtUtil.generateToken(user.getEmail());   │
│    return ResponseEntity.ok(new TokenResponse(token));      │
│  }                                                           │
│                                                              │
│  Token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  localStorage (Browser)                                     │
│  ───────────────────────                                    │
│  {                                                           │
│    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."      │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────┐
│              2. USER OPENS ADMIN DASHBOARD                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Frontend (React)                                           │
│  ─────────────────                                          │
│  useEffect(() => {                                          │
│    // Fetch dashboard data                                  │
│    adminDashboardApi.getDashboard('week');                  │
│  }, []);                                                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  API Service (axios interceptor)                            │
│  ────────────────────────────────                           │
│  apiClient.interceptors.request.use((config) => {           │
│    // ✅ AUTO-ADD TOKEN FROM localStorage                   │
│    const token = localStorage.getItem('token');             │
│    if (token) {                                              │
│      config.headers.Authorization = `Bearer ${token}`;      │
│    }                                                         │
│    return config;                                            │
│  });                                                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  HTTP Request                                               │
│  ─────────────                                              │
│  GET /api/admin/dashboard?range=week                        │
│  Headers:                                                    │
│    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...   │
│    Content-Type: application/json                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Backend (Spring Boot)                                      │
│  ──────────────────────                                     │
│  1. JwtAuthenticationFilter intercepts request              │
│  2. Extracts token from Authorization header                │
│  3. Validates token using JwtUtil                           │
│  4. If valid → Allow request                                │
│  5. If invalid → Return 401 Unauthorized                    │
│                                                              │
│  @GetMapping("/api/admin/dashboard")                        │
│  public ResponseEntity<AdminDashboardDTO> getDashboard() {  │
│    // ✅ Token validated, user authenticated                │
│    return ResponseEntity.ok(dashboardService.getData());    │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  HTTP Response                                              │
│  ─────────────                                              │
│  Status: 200 OK                                             │
│  Body: {                                                     │
│    "kpis": {                                                 │
│      "todayRevenue": 1250.50,                               │
│      "totalOrders": 42,                                     │
│      ...                                                     │
│    },                                                        │
│    "trendingItems": [...],                                  │
│    ...                                                       │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Frontend (React)                                           │
│  ─────────────────                                          │
│  setDashboard(response.data);                               │
│  // ✅ Dashboard displays real data                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 Key Points

### 1. Token Storage
```javascript
// After login
localStorage.setItem('token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6...');

// Token stays in browser until:
// - User logs out (localStorage.removeItem('token'))
// - User clears browser data
// - Token expires (backend rejects it)
```

### 2. Automatic Token Injection
```javascript
// You DON'T need to manually add token to every request
// The interceptor does it automatically!

// ❌ DON'T DO THIS:
axios.get('/api/admin/dashboard', {
  headers: { Authorization: `Bearer ${token}` }
});

// ✅ DO THIS (interceptor adds token automatically):
adminDashboardApi.getDashboard('week');
```

### 3. Token Validation
```
Backend checks:
1. Is token present? ✓
2. Is token format valid? ✓
3. Is signature valid? ✓
4. Is token expired? ✓
5. Does user exist? ✓

If all pass → Request allowed
If any fail → 401 Unauthorized
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "401 Unauthorized"
**Cause:** Token missing or invalid

**Solution:**
```javascript
// Check if token exists
const token = localStorage.getItem('token');
console.log('Token:', token);

// If no token, redirect to login
if (!token) {
  navigate('/login');
}
```

### Issue 2: "Token expired"
**Cause:** JWT token has expiration time

**Solution:**
```javascript
// In axios interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired, redirect to login
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### Issue 3: "CORS error"
**Cause:** Backend not allowing frontend origin

**Solution:** Backend already configured with `@CrossOrigin(origins = "*")`

---

## 📝 Complete Flow Example

```javascript
// 1. LOGIN
const login = async (email, password) => {
  const response = await axios.post('/api/auth/login', { email, password });
  localStorage.setItem('token', response.data.token);
  // Token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBleGFtcGxlLmNvbSIsImlhdCI6MTYxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
};

// 2. API SERVICE (Auto-adds token)
const apiClient = axios.create({
  baseURL: 'http://localhost:8080/api',
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 3. FETCH DASHBOARD (Token added automatically)
const fetchDashboard = async () => {
  const response = await apiClient.get('/admin/dashboard?range=week');
  // Request includes: Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...
  return response.data;
};

// 4. BACKEND VALIDATES
// JwtAuthenticationFilter → JwtUtil.validateToken() → Allow/Deny

// 5. RESPONSE
// If valid: 200 OK + dashboard data
// If invalid: 401 Unauthorized
```

---

## 🎯 Summary

**Token Flow:**
1. Login → Get token → Save to localStorage
2. Make API call → Interceptor adds token automatically
3. Backend validates → Returns data or 401
4. Frontend displays data or redirects to login

**You only need to:**
1. ✅ Save token after login
2. ✅ Create axios interceptor (one time)
3. ✅ Make API calls (token added automatically)

**That's it!** The interceptor handles everything else.
