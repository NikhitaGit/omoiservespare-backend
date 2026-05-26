# 🚀 Production Signup System - Quick Start

## What Was Implemented

✅ **Separate signup endpoints for Admins and Vendors**
✅ **Admin creation with secret key (first admin) or by existing admin**
✅ **Vendor registration with approval workflow**
✅ **Vendor details stored in separate table**
✅ **Security configuration updated**
✅ **Database migration created**

---

## 🎯 Quick Setup (5 Minutes)

### Step 1: Run Database Migration

The system will automatically run the migration on startup. The new `vendors` table will be created.

**Manual verification (optional):**
```sql
SHOW TABLES LIKE 'vendors';
DESC vendors;
```

---

### Step 2: Change Admin Secret Key (CRITICAL!)

**Option A: Environment Variable (Recommended)**
```bash
# Windows PowerShell
$env:ADMIN_SECRET_KEY="your-super-secret-key-here"

# Linux/Mac
export ADMIN_SECRET_KEY="your-super-secret-key-here"
```

**Option B: application.properties**
```properties
app.admin.secret-key=your-super-secret-key-here
```

**Generate a strong key:**
```bash
# Linux/Mac
openssl rand -base64 32

# PowerShell
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

---

### Step 3: Start Application

```bash
mvn spring-boot:run
```

---

### Step 4: Create First Admin

**PowerShell:**
```powershell
$body = @{
    email = "admin@yourcompany.com"
    phoneNumber = "+1234567890"
    fullName = "System Administrator"
    secretKey = "your-super-secret-key-here"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/admin/create-first" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

**cURL:**
```bash
curl -X POST http://localhost:8080/api/admin/create-first \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@yourcompany.com",
    "phoneNumber": "+1234567890",
    "fullName": "System Administrator",
    "secretKey": "your-super-secret-key-here"
  }'
```

---

### Step 5: Test Vendor Registration

**PowerShell:**
```powershell
$body = @{
    email = "restaurant@example.com"
    phoneNumber = "+1234567890"
    restaurantName = "Test Restaurant"
    ownerName = "John Doe"
    address = "123 Main St"
    businessLicense = "BL123456"
    description = "Great food!"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/vendor/register" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

---

## 🧪 Run Automated Tests

```powershell
.\test-production-signup.ps1
```

This will test:
- ✅ Vendor registration
- ✅ Vendor status check
- ✅ First admin creation
- ✅ Admin login
- ⚠️ Admin-only endpoints (requires manual OTP verification)

---

## 📋 Complete Workflow Example

### 1. Vendor Applies
```bash
POST /api/vendor/register
→ Status: PENDING
→ Account: INACTIVE
```

### 2. Admin Logs In
```bash
POST /api/auth/login
→ Receives OTP
POST /api/auth/verify-otp
→ Receives JWT token
```

### 3. Admin Views Pending Applications
```bash
GET /api/admin/vendors/pending
Authorization: Bearer <token>
→ Returns list of pending vendors
```

### 4. Admin Approves Vendor
```bash
POST /api/admin/vendors/1/process
Authorization: Bearer <token>
Body: { "action": "APPROVE", "reason": "Verified" }
→ Vendor status: APPROVED
→ Account: ACTIVE
```

### 5. Vendor Can Now Login
```bash
POST /api/auth/login
→ Vendor can access system
```

---

## 🔒 Security Features

| Feature | Implementation |
|---------|---------------|
| **Admin Creation** | Secret key required for first admin |
| **Vendor Approval** | Admin must approve before vendor can login |
| **Account Status** | `accountActive` flag controls access |
| **Vendor Status** | `PENDING`, `APPROVED`, `REJECTED`, `SUSPENDED` |
| **JWT Authentication** | All protected endpoints require valid token |
| **RBAC** | Role-based access control with `@RequireRole` |

---

## 📊 Database Schema

### Users Table
```sql
role: ENUM('USER', 'VENDOR', 'ADMIN')
vendor_status: ENUM('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED')
account_active: BOOLEAN
```

### Vendors Table (New)
```sql
user_id: BIGINT (FK to users.id)
restaurant_name: VARCHAR(255)
owner_name: VARCHAR(255)
address: TEXT
business_license: VARCHAR(255)
description: TEXT
```

---

## 🔗 API Endpoints Summary

### Public Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/vendor/register` | Register as vendor |
| GET | `/api/vendor/status/{email}` | Check application status |
| POST | `/api/admin/create-first` | Create first admin (secret key) |

### Protected Endpoints (Admin Only)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/admin/create` | Create additional admin |
| GET | `/api/admin/vendors/pending` | Get pending applications |
| GET | `/api/admin/vendors` | Get all vendors |
| POST | `/api/admin/vendors/{id}/process` | Approve/reject vendor |
| POST | `/api/admin/vendors/{id}/suspend` | Suspend vendor |

---

## 🆘 Troubleshooting

### "Admin already exists"
✅ First admin was already created. Use `/api/admin/create` with admin JWT token.

### "Invalid secret key"
✅ Check `application.properties` or environment variable `ADMIN_SECRET_KEY`.

### Vendor can't login after approval
✅ Verify in database:
```sql
SELECT id, email, role, vendor_status, account_active 
FROM users 
WHERE email = 'vendor@example.com';
```
Should show: `vendor_status='APPROVED'` and `account_active=1`

### Migration not running
✅ Check Flyway configuration in `application.properties`:
```properties
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
```

---

## 📖 Full Documentation

For complete documentation, see: **PRODUCTION_SIGNUP_SYSTEM.md**

Includes:
- Detailed API documentation
- Security best practices
- Email notification setup
- Deployment checklist
- Monitoring and troubleshooting

---

## ✅ Checklist

- [ ] Database migration ran successfully
- [ ] Admin secret key changed
- [ ] First admin created
- [ ] Vendor registration tested
- [ ] Admin approval workflow tested
- [ ] Security configuration verified
- [ ] Email notifications configured (optional)
- [ ] Production deployment planned

---

## 🎉 You're Ready!

Your production-ready signup system is now active with:
- ✅ Secure admin creation
- ✅ Vendor registration with approval
- ✅ Role-based access control
- ✅ Proper security measures

**Next Steps:**
1. Configure email notifications
2. Set up monitoring
3. Deploy to production
4. Create admin accounts for your team
