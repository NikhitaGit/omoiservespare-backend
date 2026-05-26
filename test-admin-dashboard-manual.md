# 🧪 Manual Testing Guide - Admin Dashboard Backend

## Prerequisites
- Backend running on port 8080
- Valid user account (email + password)
- Tool: Postman, curl, or browser

---

## Test 1: Health Check (No Auth Required)

### Using Browser
```
http://localhost:8080/api/admin/dashboard/health
```

**Expected Response:**
```
Admin Dashboard API is running
```

### Using PowerShell
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/api/admin/dashboard/health" -Method GET
```

**✅ Pass:** Status 200, message received
**❌ Fail:** Connection refused (backend not running)

---

## Test 2: Login & Get JWT Token

### Using PowerShell
```powershell
$body = @{
    email = "your-email@example.com"
    password = "your-password"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $body -ContentType "application/json"

# Save token
$token = $response.token
Write-Host "Token: $token"
```

### Using curl
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your-email@example.com","password":"your-password"}'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "your-email@example.com"
}
```

**✅ Pass:** Token received
**❌ Fail:** 401 Unauthorized (wrong credentials)

---

## Test 3: Get Dashboard Data (Requires JWT)

### Using PowerShell
```powershell
$headers = @{
    "Authorization" = "Bearer $token"
}

$dashboard = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" -Method GET -Headers $headers

# View response
$dashboard | ConvertTo-Json -Depth 3
```

### Using curl
```bash
curl -X GET "http://localhost:8080/api/admin/dashboard?range=week" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Using Postman
1. Create new GET request
2. URL: `http://localhost:8080/api/admin/dashboard?range=week`
3. Headers:
   - Key: `Authorization`
   - Value: `Bearer YOUR_TOKEN_HERE`
4. Send

**Expected Response Structure:**
```json
{
  "kpis": {
    "todayRevenue": 450.0,
    "totalRevenue": 3200.0,
    "totalOrders": 25,
    "customers": 15,
    "todayRevenueGrowth": 12.5
  },
  "trendingItems": [
    {
      "itemId": 1,
      "name": "Idli",
      "quantitySold": 45,
      "revenue": 1350.0,
      "growthPercent": 15.5,
      "imageUrl": null,
      "insight": "Idli sales ↑ 15.5% today"
    }
  ],
  "revenueSeries": [
    {
      "label": "14 Feb",
      "sales": 450.0,
      "orders": 5
    }
  ],
  "topSoldToday": [
    {
      "itemId": 1,
      "name": "Idli",
      "qty": 10
    }
  ],
  "leastSoldToday": [
    {
      "itemId": 5,
      "name": "Pizza",
      "qty": 0
    }
  ],
  "categoryDistribution": [
    {
      "category": "Breakfast",
      "count": 3,
      "percentage": 37.5
    }
  ],
  "sessions": {
    "totalSessions": 845,
    "liveVisitors": 12
  },
  "customerRate": {
    "returningPercent": 65.5
  },
  "insights": [
    "Idli sales ↑ 15.5% today",
    "Tea is trending"
  ]
}
```

**✅ Pass:** All fields present, data makes sense
**❌ Fail:** 401 Unauthorized (invalid token), 500 Error (backend issue)

---

## Test 4: Test Different Date Ranges

### Today
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=today" -Headers $headers
```

### Week
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" -Headers $headers
```

### Month
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=month" -Headers $headers
```

### Year
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=year" -Headers $headers
```

### Custom Date Range
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?start=2026-02-01&end=2026-02-14" -Headers $headers
```

**✅ Pass:** Each range returns appropriate data
**❌ Fail:** Error or empty data

---

## Test 5: Security Test (Should Fail)

### Without JWT Token
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/api/admin/dashboard?range=week" -Method GET
```

**Expected:** 401 Unauthorized or 403 Forbidden

**✅ Pass:** Request blocked (401/403)
**❌ Fail:** Request succeeds (security issue!)

---

## Test 6: Data Validation Checklist

Check the response has:

- [ ] `kpis` object with:
  - [ ] `todayRevenue` (number)
  - [ ] `totalRevenue` (number)
  - [ ] `totalOrders` (number)
  - [ ] `customers` (number)
  - [ ] `todayRevenueGrowth` (number)

- [ ] `trendingItems` array with items containing:
  - [ ] `itemId`, `name`, `quantitySold`, `revenue`, `growthPercent`

- [ ] `revenueSeries` array with:
  - [ ] `label`, `sales`, `orders`

- [ ] `topSoldToday` array
- [ ] `leastSoldToday` array
- [ ] `categoryDistribution` array
- [ ] `sessions` object
- [ ] `customerRate` object
- [ ] `insights` array (optional)

---

## Test 7: Performance Test

### Measure Response Time
```powershell
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$dashboard = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" -Headers $headers
$stopwatch.Stop()
Write-Host "Response time: $($stopwatch.ElapsedMilliseconds) ms"
```

**✅ Pass:** < 1000ms (1 second)
**⚠️ Acceptable:** 1000-2000ms
**❌ Fail:** > 2000ms (needs optimization)

---

## Test 8: Database Check

### Check if data is from database (not mock)

1. Place a new order through your app
2. Call dashboard API
3. Check if `totalOrders` increased
4. Check if new item appears in `trendingItems`

**✅ Pass:** Data updates with new orders
**❌ Fail:** Data is static (using mock data)

---

## Test 9: Backend Logs Check

### Check Spring Boot logs for:

```
✅ Good logs:
- "Dashboard request: range=week, start=null, end=null"
- "Fetching dashboard data for range: week"
- No errors or exceptions

❌ Bad logs:
- SQL errors
- NullPointerException
- Connection refused
```

---

## Test 10: Database Query Check

### Verify data in PostgreSQL

```sql
-- Check orders exist
SELECT COUNT(*) FROM orders WHERE status = 'PAID';

-- Check order items
SELECT oi.item_id, mi.name, SUM(oi.quantity) as total_qty
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.id
GROUP BY oi.item_id, mi.name
ORDER BY total_qty DESC;

-- Check revenue
SELECT SUM(total_amount) as total_revenue
FROM orders
WHERE status = 'PAID';
```

**✅ Pass:** Data matches API response
**❌ Fail:** Mismatch between database and API

---

## Quick Test Script (Copy-Paste)

```powershell
# 1. Health check
Invoke-WebRequest -Uri "http://localhost:8080/api/admin/dashboard/health"

# 2. Login
$body = @{
    email = "your-email@example.com"
    password = "your-password"
} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $body -ContentType "application/json"
$token = $response.token

# 3. Get dashboard
$headers = @{ "Authorization" = "Bearer $token" }
$dashboard = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" -Headers $headers

# 4. View results
Write-Host "Today Revenue: ₹$($dashboard.kpis.todayRevenue)"
Write-Host "Total Orders: $($dashboard.kpis.totalOrders)"
Write-Host "Customers: $($dashboard.kpis.customers)"
Write-Host "Trending Items: $($dashboard.trendingItems.Count)"
```

---

## Troubleshooting

### Issue: Connection Refused
**Solution:** Backend not running. Start with `mvn spring-boot:run`

### Issue: 401 Unauthorized
**Solution:** Token expired or invalid. Login again to get new token

### Issue: Empty Data
**Solution:** No orders in database. Place some test orders first

### Issue: 500 Internal Server Error
**Solution:** Check backend logs for errors. Likely database connection issue

---

## Success Criteria

✅ All tests pass
✅ Response time < 1 second
✅ Data updates with new orders
✅ Security works (401 without token)
✅ All date ranges work
✅ Data structure matches expected format

**If all criteria met: Backend is production-ready!** 🎉
