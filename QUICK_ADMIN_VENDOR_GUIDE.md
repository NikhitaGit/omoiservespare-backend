# Quick Admin & Vendor Setup Guide

## 1. Create First Admin (One-time)

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/create-first" `
    -Method POST `
    -Body '{"email":"admin@test.com","phoneNumber":"+1234567890","fullName":"Admin","secretKey":"SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD"}' `
    -ContentType "application/json"
```

## 2. Vendor Applies

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/vendor/register" `
    -Method POST `
    -Body '{"email":"vendor@restaurant.com","phoneNumber":"+9876543210","restaurantName":"My Restaurant","ownerName":"John Doe","address":"123 St","businessLicense":"LIC123","description":"Great food"}' `
    -ContentType "application/json"
```

## 3. Admin Approves Vendor

```powershell
# Login as admin
$admin = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"admin@test.com","password":"pass"}' -ContentType "application/json"

# Get pending vendors
$pending = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/pending" -Headers @{"Authorization"="Bearer $($admin.token)"}

# Approve first vendor
$vendorId = $pending[0].id
Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/$vendorId/process" -Method POST -Headers @{"Authorization"="Bearer $($admin.token)"} -Body '{"action":"APPROVE"}' -ContentType "application/json"
```

## 4. Vendor Logs In

```powershell
$vendor = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"vendor@restaurant.com","password":"pass"}' -ContentType "application/json"

# Vendor now has VENDOR role in JWT token
```

## Run Complete Test

```powershell
.\test-admin-vendor-flow.ps1
```

## Vendor Status Values

- **PENDING** - Application submitted, waiting for admin review
- **APPROVED** - Can login and use system
- **REJECTED** - Application denied
- **SUSPENDED** - Account suspended by admin

## Key Endpoints

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/admin/create-first` | POST | Secret Key | Create first admin |
| `/api/admin/create` | POST | Admin | Create more admins |
| `/api/vendor/register` | POST | None | Vendor applies |
| `/api/vendor/status/{email}` | GET | None | Check status |
| `/api/admin/vendors/pending` | GET | Admin | View applications |
| `/api/admin/vendors/{id}/process` | POST | Admin | Approve/Reject |

Done! 🎉
