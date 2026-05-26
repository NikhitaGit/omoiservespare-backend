# ✅ Ready to Test - Your Setup is Complete!

## 🎉 Everything is Configured!

Your admin secret key is set up and ready to use:
```
qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG
```

---

## 🚀 Quick Test (3 Commands)

### 1. Start Your Application
```powershell
mvn spring-boot:run
```

### 2. Create First Admin
```powershell
.\create-first-admin.ps1
```

### 3. Test Complete System
```powershell
.\test-production-signup.ps1
```

**That's it!** Your production signup system is ready.

---

## 📋 What You Can Test Now

### ✅ Admin Creation
```powershell
.\create-first-admin.ps1
```
Creates admin with:
- Email: `admin@company.com`
- Phone: `+9876543210`
- Secret Key: `qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG`

### ✅ Vendor Registration
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

### ✅ Check Vendor Status
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/vendor/status/vendor@example.com"
```

### ✅ Admin Login
```powershell
$loginBody = @{
    email = "admin@company.com"
    phoneNumber = "+9876543210"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST -ContentType "application/json" -Body $loginBody
```

---

## 🔄 Complete Workflow Test

### Step 1: Create First Admin
```powershell
.\create-first-admin.ps1
```
**Expected:** ✅ Admin created successfully

### Step 2: Vendor Applies
```powershell
$vendorBody = @{
    email = "testvendor@example.com"
    phoneNumber = "+1234567890"
    restaurantName = "Test Restaurant"
    ownerName = "Test Owner"
    address = "123 Test St"
    businessLicense = "BL123456"
    description = "Test restaurant"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/vendor/register" `
    -Method POST -ContentType "application/json" -Body $vendorBody
```
**Expected:** ✅ Status: PENDING

### Step 3: Admin Logs In
```powershell
$loginBody = @{
    email = "admin@company.com"
    phoneNumber = "+9876543210"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST -ContentType "application/json" -Body $loginBody
```
**Expected:** ✅ OTP sent (check console logs)

### Step 4: Verify OTP
```powershell
# Get OTP from console logs, then:
$otpBody = @{
    email = "admin@company.com"
    otp = "123456"  # Replace with actual OTP
} | ConvertTo-Json

$tokenResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" `
    -Method POST -ContentType "application/json" -Body $otpBody

$token = $tokenResponse.token
```
**Expected:** ✅ JWT token received

### Step 5: View Pending Vendors
```powershell
$vendors = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/pending" `
    -Method GET `
    -Headers @{ Authorization = "Bearer $token" }

$vendors
```
**Expected:** ✅ List of pending vendors

### Step 6: Approve Vendor
```powershell
$approvalBody = @{
    action = "APPROVE"
    reason = "All documents verified"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/1/process" `
    -Method POST `
    -ContentType "application/json" `
    -Headers @{ Authorization = "Bearer $token" } `
    -Body $approvalBody
```
**Expected:** ✅ Vendor approved

### Step 7: Vendor Can Now Login
```powershell
$vendorLoginBody = @{
    email = "testvendor@example.com"
    phoneNumber = "+1234567890"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST -ContentType "application/json" -Body $vendorLoginBody
```
**Expected:** ✅ Vendor can login

---

## 📊 Quick Reference

### Your Configuration
| Item | Value |
|------|-------|
| **Admin Secret Key** | `qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG` |
| **First Admin Email** | `admin@company.com` |
| **First Admin Phone** | `+9876543210` |
| **Base URL** | `http://localhost:8080` |

### API Endpoints
| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/admin/create-first` | POST | Secret Key | Create first admin |
| `/api/vendor/register` | POST | None | Register vendor |
| `/api/vendor/status/{email}` | GET | None | Check status |
| `/api/auth/login` | POST | None | Login |
| `/api/auth/verify-otp` | POST | None | Verify OTP |
| `/api/admin/vendors/pending` | GET | JWT | Get pending vendors |
| `/api/admin/vendors/{id}/process` | POST | JWT | Approve/reject |

---

## 🧪 Automated Testing

### Run All Tests
```powershell
.\test-production-signup.ps1
```

This tests:
- ✅ Vendor registration
- ✅ Vendor status check
- ✅ First admin creation
- ✅ Admin login
- ⚠️ Admin endpoints (requires manual OTP)

---

## 🔍 Verify Database

### Check if admin was created
```sql
SELECT * FROM users WHERE role = 'ADMIN';
```

### Check pending vendors
```sql
SELECT * FROM users WHERE role = 'VENDOR' AND vendor_status = 'PENDING';
```

### Check vendor details
```sql
SELECT u.email, u.vendor_status, v.restaurant_name, v.owner_name
FROM users u
JOIN vendors v ON u.id = v.user_id
WHERE u.role = 'VENDOR';
```

---

## 📖 Documentation

### Quick Access
- **Your Secret Key Info**: [YOUR_ADMIN_SECRET_KEY.md](YOUR_ADMIN_SECRET_KEY.md)
- **Quick Start**: [PRODUCTION_SIGNUP_QUICK_START.md](PRODUCTION_SIGNUP_QUICK_START.md)
- **Complete API Docs**: [PRODUCTION_SIGNUP_SYSTEM.md](PRODUCTION_SIGNUP_SYSTEM.md)
- **Architecture**: [SIGNUP_SYSTEM_ARCHITECTURE.md](SIGNUP_SYSTEM_ARCHITECTURE.md)

---

## 🆘 Troubleshooting

### Application won't start
```powershell
# Check if port 8080 is available
netstat -ano | findstr :8080

# Check application logs
mvn spring-boot:run
```

### "Admin already exists"
✅ Admin was already created. You can login with `admin@company.com`

### "Invalid secret key"
✅ Make sure you're using: `qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG`

### Vendor can't login after approval
```sql
-- Verify vendor status
SELECT id, email, vendor_status, account_active 
FROM users 
WHERE email = 'vendor@example.com';

-- Should show: vendor_status='APPROVED' and account_active=1
```

---

## ✅ Success Checklist

- [ ] Application is running on port 8080
- [ ] Database is accessible
- [ ] First admin created successfully
- [ ] Admin can login
- [ ] Vendor can register
- [ ] Admin can view pending vendors
- [ ] Admin can approve vendors
- [ ] Approved vendor can login

---

## 🎯 Next Steps

### 1. Test Locally
```powershell
.\create-first-admin.ps1
.\test-production-signup.ps1
```

### 2. Configure for Production
- Set up environment variables
- Enable HTTPS
- Configure CORS for production domain
- Set up email notifications

### 3. Deploy
See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for deployment instructions.

---

## 🎉 You're All Set!

Your production signup system is configured and ready to test. Run:

```powershell
# Start application
mvn spring-boot:run

# In another terminal, create first admin
.\create-first-admin.ps1
```

**Happy testing! 🚀**
