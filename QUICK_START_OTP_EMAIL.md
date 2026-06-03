# 🚀 Quick Start: OTP Email System

## ⚡ 3-Step Setup

### Step 1: Rebuild Project
```powershell
./mvnw clean install
```

### Step 2: Start Backend
```powershell
./mvnw spring-boot:run
```

### Step 3: Test OTP Flow
```powershell
# Edit test-otp-email-flow.ps1
# Replace: $TEST_EMAIL = "your.test.email@gmail.com"

# Run test
./test-otp-email-flow.ps1
```

---

## 📧 What You'll See

### In Your Email Inbox:
1. Professional HTML email from `aishushettar95@gmail.com`
2. Clear 4-digit OTP code
3. 5-minute expiry warning
4. Company branding

### In Backend Logs:
```log
📧 EMAIL SERVICE: OTP Send Initiated
Recipient: user@company.com
OTP: 1234
✅ EMAIL SENT SUCCESSFULLY
Duration: 847 ms
```

---

## ✅ Testing Checklist

- [ ] Backend starts without errors
- [ ] OTP request returns success
- [ ] Email arrives in inbox (check spam)
- [ ] Email has professional HTML formatting
- [ ] OTP code is clearly visible
- [ ] OTP verification succeeds
- [ ] JWT token is returned

---

## 🎯 What Was Implemented

1. ✅ Professional HTML email template
2. ✅ Automatic retry logic (3 attempts)
3. ✅ Async email sending (non-blocking)
4. ✅ Comprehensive error handling
5. ✅ Production-grade logging
6. ✅ SMTP configuration (Gmail)
7. ✅ OTP security (5-min expiry)

---

## 📱 Frontend Integration

Your frontend code is already compatible:

### LoginPage.jsx
```javascript
// User enters email
const loginData = {
    companyName: company,
    email: emailOrPhone,
    phoneNumber: ""
};
await loginUser(loginData);
// OTP is sent to email
```

### OtpVerification.jsx
```javascript
// User enters OTP from email
const otp = inputs.map(i => i.value).join("");
await verifyOtp({ email, otp });
// Returns JWT token
```

**No frontend changes needed!** 🎉

---

## 🔧 Configuration

Your `application.properties` is already configured:

```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=aishushettar95@gmail.com
spring.mail.password=bbfskhrhtnujkokk
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```

✅ **No configuration changes needed!**

---

## 🚨 Troubleshooting

### Email not received?
1. Check spam/junk folder
2. Verify Gmail credentials in application.properties
3. Check backend logs for errors

### Backend won't start?
```powershell
# Clean and rebuild
./mvnw clean install

# Check for port conflicts
netstat -ano | findstr :8080
```

---

## 📊 API Endpoints

### 1. Request OTP
```http
POST /api/auth/user/login
Content-Type: application/json

{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "user@company.com",
    "phoneNumber": "+91-9876543210"
}
```

### 2. Verify OTP
```http
POST /api/auth/verify-otp
Content-Type: application/json
X-Device-Id: <uuid>

{
    "email": "user@company.com",
    "otp": "1234"
}
```

---

## 🎉 Success!

If you can:
1. Request OTP
2. Receive professional HTML email
3. Enter OTP
4. Get JWT token

**Your production-grade OTP system is working!** ✅

---

For detailed documentation, see: `OTP_EMAIL_PRODUCTION_IMPLEMENTATION.md`
