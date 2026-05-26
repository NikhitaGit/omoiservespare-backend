# 🔑 Your Admin Secret Key

## Current Configuration

Your admin secret key is configured in `application.properties`:

```
qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG
```

---

## 🚀 Quick Start - Create First Admin

### Option 1: Use the Script (Easiest)

```powershell
.\create-first-admin.ps1
```

This script automatically uses your configured secret key.

---

### Option 2: Manual Command

```powershell
$body = @{
    email = "admin@company.com"
    phoneNumber = "+9876543210"
    fullName = "System Administrator"
    secretKey = "qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/admin/create-first" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

---

### Option 3: Using cURL

```bash
curl -X POST http://localhost:8080/api/admin/create-first \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@company.com",
    "phoneNumber": "+9876543210",
    "fullName": "System Administrator",
    "secretKey": "qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG"
  }'
```

---

## 📋 What Happens Next

1. **First admin is created** with email: `admin@company.com`
2. **You can login** using:
   - Email: `admin@company.com`
   - Phone: `+9876543210`
3. **OTP will be sent** (check console logs)
4. **After login**, you get a JWT token
5. **Use JWT token** to create additional admins

---

## 🔒 Security Notes

### Current Setup
- ✅ Secret key is configured in `application.properties`
- ✅ Secret key is: `qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG`
- ⚠️ This key is visible in your codebase

### For Production
Consider using environment variables instead:

```properties
# application.properties
app.admin.secret-key=${ADMIN_SECRET_KEY:qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG}
```

Then set environment variable:
```powershell
$env:ADMIN_SECRET_KEY = "qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG"
```

This way, the secret key is not committed to version control.

---

## 🧪 Test the Complete Flow

### Step 1: Create First Admin
```powershell
.\create-first-admin.ps1
```

### Step 2: Test Vendor Registration
```powershell
.\test-production-signup.ps1
```

### Step 3: Login as Admin
```powershell
$loginBody = @{
    email = "admin@company.com"
    phoneNumber = "+9876543210"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginBody

Write-Host "Check console logs for OTP"
```

### Step 4: Verify OTP
```powershell
# Replace 123456 with actual OTP from logs
$otpBody = @{
    email = "admin@company.com"
    otp = "123456"
} | ConvertTo-Json

$tokenResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" `
    -Method POST `
    -ContentType "application/json" `
    -Body $otpBody

$token = $tokenResponse.token
Write-Host "JWT Token: $token"
```

### Step 5: View Pending Vendors (Admin Only)
```powershell
$vendors = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/pending" `
    -Method GET `
    -Headers @{ Authorization = "Bearer $token" }

$vendors
```

---

## 🔄 Create Additional Admins

After logging in as admin and getting JWT token:

```powershell
$newAdminBody = @{
    email = "admin2@company.com"
    phoneNumber = "+1234567890"
    fullName = "Second Admin"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/admin/create" `
    -Method POST `
    -ContentType "application/json" `
    -Headers @{ Authorization = "Bearer $token" } `
    -Body $newAdminBody
```

**Note:** No secret key needed for additional admins - only JWT token!

---

## 📖 Documentation

For complete documentation, see:
- **Quick Start**: [PRODUCTION_SIGNUP_QUICK_START.md](PRODUCTION_SIGNUP_QUICK_START.md)
- **Complete API Docs**: [PRODUCTION_SIGNUP_SYSTEM.md](PRODUCTION_SIGNUP_SYSTEM.md)
- **Architecture**: [SIGNUP_SYSTEM_ARCHITECTURE.md](SIGNUP_SYSTEM_ARCHITECTURE.md)

---

## 🆘 Troubleshooting

### "Admin already exists"
✅ First admin was already created. Use `/api/admin/create` with JWT token.

### "Invalid secret key"
✅ Make sure you're using: `qFZMWtm2ihlAn15TDwkv7zEyO9RH6SjG`

### Application not responding
✅ Check if application is running: `http://localhost:8080/actuator/health`

---

## ✅ Ready to Go!

Your secret key is configured and ready to use. Run:

```powershell
.\create-first-admin.ps1
```

Then start testing the system! 🚀
