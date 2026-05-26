# 🚀 Production Signup System - Quick Reference Card

## 📋 Quick Commands

### Create First Admin
```powershell
$body = @{
    email = "admin@company.com"
    phoneNumber = "+1234567890"
    fullName = "Admin User"
    secretKey = "SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/admin/create-first" `
    -Method POST -ContentType "application/json" -Body $body
```

### Register Vendor
```powershell
$body = @{
    email = "vendor@example.com"
    phoneNumber = "+1234567890"
    restaurantName = "My Restaurant"
    ownerName = "John Doe"
    address = "123 Main St"
    businessLicense = "BL123456"
    description = "Great food"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/vendor/register" `
    -Method POST -ContentType "application/json" -Body $body
```

### Check Vendor Status
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/vendor/status/vendor@example.com"
```

---

## 🔗 API Endpoints

### Public (No Auth Required)
```
POST   /api/vendor/register          → Register as vendor
GET    /api/vendor/status/{email}    → Check application status
POST   /api/admin/create-first       → Create first admin (secret key)
```

### Protected (Admin JWT Required)
```
POST   /api/admin/create                    → Create additional admin
GET    /api/admin/vendors/pending           → Get pending applications
GET    /api/admin/vendors                   → Get all vendors
POST   /api/admin/vendors/{id}/process      → Approve/reject vendor
POST   /api/admin/vendors/{id}/suspend      → Suspend vendor
```

---

## 🔐 Security

### Admin Secret Key
```properties
# application.properties
app.admin.secret-key=${ADMIN_SECRET_KEY:SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD}
```

### Environment Variable (Recommended)
```bash
# Windows
$env:ADMIN_SECRET_KEY="your-secret-key"

# Linux/Mac
export ADMIN_SECRET_KEY="your-secret-key"
```

---

## 🗄️ Database

### Check Pending Vendors
```sql
SELECT * FROM users 
WHERE role = 'VENDOR' AND vendor_status = 'PENDING';
```

### Check Vendor Details
```sql
SELECT u.email, u.vendor_status, v.restaurant_name, v.owner_name
FROM users u
JOIN vendors v ON u.id = v.user_id
WHERE u.role = 'VENDOR';
```

### Check Admins
```sql
SELECT * FROM users WHERE role = 'ADMIN';
```

---

## 🔄 Vendor Status Flow

```
PENDING → APPROVED → Can Login ✅
       → REJECTED → Cannot Login ❌
       → SUSPENDED → Cannot Login ❌
```

---

## 🧪 Test Script

```powershell
.\test-production-signup.ps1
```

---

## 📖 Documentation

| File | Purpose |
|------|---------|
| `PRODUCTION_SIGNUP_SYSTEM.md` | Complete API docs |
| `PRODUCTION_SIGNUP_QUICK_START.md` | 5-minute setup |
| `SIGNUP_SYSTEM_ARCHITECTURE.md` | Architecture diagrams |
| `PRODUCTION_SIGNUP_IMPLEMENTATION_SUMMARY.md` | Implementation details |

---

## ✅ Deployment Checklist

- [ ] Change admin secret key
- [ ] Run database migrations
- [ ] Create first admin
- [ ] Test vendor registration
- [ ] Test admin approval
- [ ] Configure email notifications
- [ ] Deploy to production

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Admin already exists" | Use `/api/admin/create` with admin JWT |
| "Invalid secret key" | Check environment variable or properties |
| Vendor can't login | Verify `vendor_status='APPROVED'` and `account_active=1` |
| Migration not running | Enable Flyway in `application.properties` |

---

## 🎯 Key Features

✅ **Admin**: Secret key for first, JWT for additional
✅ **Vendor**: Public registration with approval workflow
✅ **Security**: JWT + RBAC + Account status validation
✅ **Database**: Separate tables for users and vendor details

---

**Ready to deploy! 🚀**
