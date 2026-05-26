# Quick RBAC Test Guide

## 1. Setup (One-time)

```sql
-- In PostgreSQL, create test users with roles:
UPDATE users SET role = 'ADMIN' WHERE email = 'admin@test.com';
UPDATE users SET role = 'USER' WHERE email = 'user@test.com';
```

## 2. Restart Application

```powershell
# Kill old process
taskkill /F /IM java.exe

# Start fresh
mvn spring-boot:run
```

## 3. Run Test

```powershell
.\test-rbac-system.ps1
```

## Expected Output:

```
✅ ADMIN can access admin endpoints
✅ USER blocked from admin endpoints (403)
✅ USER can access user endpoints
✅ ADMIN blocked from user-only endpoints (403)
```

## Manual Quick Test:

```powershell
# Login as admin
$a = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"admin@test.com","password":"pass"}' -ContentType "application/json"

# Try admin endpoint (should work)
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard" -Headers @{"Authorization"="Bearer $($a.token)"}

# Login as user
$u = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"user@test.com","password":"pass"}' -ContentType "application/json"

# Try admin endpoint (should fail with 403)
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/dashboard" -Headers @{"Authorization"="Bearer $($u.token)"}
```

That's it! 🎉
