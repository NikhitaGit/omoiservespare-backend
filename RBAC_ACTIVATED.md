# ✅ RBAC System Activated!

## Changes Made

### 1. AuthService.java - JWT Tokens Now Include Roles
**Updated methods:**
- `loginSuccess()` - Now generates tokens with role using `generateTokenWithRole()`
- `refreshAccessToken()` - Refresh tokens also include role

**Code:**
```java
String accessToken = jwtUtil.generateTokenWithRole(
    user.getEmail(),
    user.getRole() != null ? user.getRole().name() : "USER",
    user.getAccountType()
);
```

### 2. AdminDashboardController.java - Protected with @RequireRole
**Protected endpoints:**
- `GET /api/admin/dashboard` - Now requires ADMIN role
- `GET /api/admin/dashboard/health` - No auth (public health check)

**Code:**
```java
@GetMapping
@RequireRole(Role.ADMIN)
public ResponseEntity<AdminDashboardDTO> getDashboard(...) { ... }
```

### 3. RewardController.java - Protected with @RequireRole
**Protected endpoints:**
- `GET /api/rewards` - Requires USER role
- `GET /api/rewards/unlocked` - Requires USER role
- `POST /api/rewards/{id}/claim` - Requires USER role

**Code:**
```java
@GetMapping
@RequireRole(Role.USER)
public ResponseEntity<Map<String, Object>> getUserRewards(...) { ... }
```

## How to Test

### Step 1: Setup Test Users
Run the SQL script to create test users with different roles:

```powershell
# Connect to PostgreSQL and run:
psql -U postgres -d omoiservespare_db -f setup-rbac-test-users.sql
```

Or manually in your database:
```sql
-- Make one user ADMIN
UPDATE users SET role = 'ADMIN', account_active = true 
WHERE email = 'admin@test.com';

-- Make another user regular USER
UPDATE users SET role = 'USER', account_active = true 
WHERE email = 'user@test.com';
```

### Step 2: Restart Application
Kill the old process and start fresh:

```powershell
# Find and kill the process
Get-Process -Name java | Where-Object {$_.Path -like "*maven*"} | Stop-Process -Force

# Or use task manager to kill Java process on port 8080

# Start application
mvn spring-boot:run
```

### Step 3: Run Automated Test
```powershell
.\test-rbac-system.ps1
```

This will:
1. Login as ADMIN
2. Login as USER
3. Test ADMIN accessing admin endpoint ✅ (should work)
4. Test USER accessing admin endpoint ❌ (should fail with 403)
5. Test USER accessing user endpoint ✅ (should work)
6. Test ADMIN accessing user endpoint ❌ (should fail with 403)

### Step 4: Manual Testing (Optional)

**Login as ADMIN:**
```powershell
$admin = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -Body '{"email":"admin@test.com","password":"password123"}' `
    -ContentType "application/json"

$adminHeaders = @{"Authorization" = "Bearer $($admin.token)"}
```

**Test admin endpoint (should work):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" `
    -Headers $adminHeaders
```

**Login as USER:**
```powershell
$user = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -Body '{"email":"user@test.com","password":"password123"}' `
    -ContentType "application/json"

$userHeaders = @{"Authorization" = "Bearer $($user.token)"}
```

**Test admin endpoint as USER (should fail with 403):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard?range=week" `
    -Headers $userHeaders
# Expected: 403 Forbidden
```

**Test rewards endpoint as USER (should work):**
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/rewards" `
    -Headers $userHeaders
# Expected: 200 OK with rewards data
```

## Expected Behavior

### ✅ What Should Work:
- ADMIN accessing `/api/admin/dashboard` → 200 OK
- USER accessing `/api/rewards` → 200 OK
- USER accessing `/api/rewards/unlocked` → 200 OK
- USER accessing `/api/rewards/{id}/claim` → 200 OK

### ❌ What Should Fail (403 Forbidden):
- USER accessing `/api/admin/dashboard` → 403 Forbidden
- ADMIN accessing `/api/rewards` → 403 Forbidden (ADMIN ≠ USER)
- Any request without valid JWT token → 401 Unauthorized

## How RBAC Works

1. **User logs in** → JWT token generated with role claim
2. **User makes request** → Token sent in Authorization header
3. **@RequireRole annotation** → Triggers RoleAuthorizationAspect
4. **Aspect checks role** → Extracts role from JWT and compares
5. **Access granted/denied** → 200 OK or 403 Forbidden

## Files Created/Modified

**Modified:**
- `src/main/java/com/omoikaneinnovations/omoiservespare/service/AuthService.java`
- `src/main/java/com/omoikaneinnovations/omoiservespare/controller/AdminDashboardController.java`
- `src/main/java/com/omoikaneinnovations/omoiservespare/controller/RewardController.java`

**Created:**
- `setup-rbac-test-users.sql` - SQL to create test users
- `test-rbac-system.ps1` - Automated RBAC test script
- `RBAC_ACTIVATED.md` - This file

## Troubleshooting

**Issue: 403 Forbidden for all requests**
- Check if user has correct role in database
- Verify JWT token contains role claim (decode at jwt.io)
- Check application logs for role mismatch errors

**Issue: ADMIN can access user endpoints**
- This is expected if you want ADMIN to have all permissions
- To fix: Update RoleAuthorizationAspect to check for exact role match

**Issue: Token doesn't contain role**
- Make sure you restarted the application after changes
- Old tokens won't have role claim - need to login again

**Issue: Users don't have roles**
- Run `setup-rbac-test-users.sql`
- Or manually update: `UPDATE users SET role = 'USER' WHERE email = 'your@email.com'`

## Next Steps

1. ✅ Test RBAC with automated script
2. Add more role-protected endpoints as needed
3. Consider adding VENDOR role protection for vendor endpoints
4. Update frontend to show/hide UI based on user role
5. Add role-based navigation in React app

## Security Notes

- Roles are stored in JWT token (can't be modified without invalidating signature)
- Role checks happen on every request via AOP
- No database query needed for role verification (fast!)
- Tokens expire after 24 hours (configurable in JwtUtil)
- Refresh tokens also include role for seamless renewal

🎉 **RBAC is now fully active and protecting your endpoints!**
