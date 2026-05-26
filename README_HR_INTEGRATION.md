# 🎯 HR Integration - Quick Start Guide

## ✅ Current Status - HR Integration Complete

| Component | Status | Notes |
|-----------|--------|-------|
| HR API Service | ✅ Implemented | Mock mode enabled for testing |
| Signup Removal | ✅ Complete | No more manual registration |
| Authentication | ✅ Updated | SmartQ model implemented |
| User Provisioning | ✅ Active | Auto-creates users from HR data |
| OTP System | ✅ Working | Sends to HR-registered credentials |

---

## 🚀 Start with HR Integration

### 1️⃣ Validate Setup
```powershell
.\validate-hr-integration.ps1
```

### 2️⃣ Start Application
```powershell
.\start-with-hr-integration.ps1
```

### 3️⃣ Test HR Integration
```powershell
.\test-hr-integration.ps1
```

**That's it!** ✨ Your app now uses HR integration like SmartQ!

---

## 🔐 How Authentication Works Now

```
User Login → Company Check → HR Lookup → Employee Validation → OTP → Tokens
```

### Step by Step:
1. **User enters**: Company name + Email/Phone
2. **System validates**: Company exists in HR system
3. **System finds**: Employee in HR database
4. **System checks**: Employee is active
5. **System creates**: Local user from HR data
6. **System sends**: OTP to HR-registered credentials
7. **User verifies**: OTP and gets JWT tokens

---

## 🧪 Test Credentials (Mock Mode)

### Valid Test Data:
- **Company**: "Omoikane Innovations" or "Tech Corp"
- **Email**: "john.doe@omoikaneinnovations.com"
- **Phone**: "+91-9876543210"

### Invalid Test Data (should fail):
- **Company**: "Invalid Company"
- **Email**: "invalid@wrongcompany.com"
- **Phone**: "+1-555-0000"

---

## ⚙️ Configuration Modes

### 🧪 Mock Mode (Current - for testing)
```properties
hr.api.enabled=false
hr.api.base-url=https://api.hrcompany.com/v1
hr.api.token=demo-token
```

**Mock mode accepts:**
- Companies: containing "omoikane", "tech", "innovation"
- Emails: @omoikaneinnovations.com, @techcorp.com, @example.com
- Phones: starting with +91-, 91, or 9

### 🏭 Production Mode (when ready)
```properties
hr.api.enabled=true
hr.api.base-url=https://your-actual-hr-api.com/v1
hr.api.token=your-actual-api-token
```

---

## 📋 API Changes

### ❌ Removed Endpoints:
- `POST /api/auth/signup` - No more manual registration

### ✅ Updated Endpoints:
- `POST /api/auth/login` - Now validates against HR system
- `POST /api/auth/verify-otp` - Uses HR-registered credentials
- `POST /api/auth/refresh` - Unchanged

### 📝 Login Request Format:
```json
{
  "companyName": "Omoikane Innovations",
  "email": "john.doe@omoikaneinnovations.com",
  "phoneNumber": "+91-9876543210",
  "accountType": "PROFESSIONAL"
}
```

---

## 🔧 New Files Added

### Core Implementation:
- `HRApiService.java` - HR system communication
- `HREmployeeDTO.java` - HR employee data structure
- `RestTemplateConfig.java` - HTTP client configuration

### Scripts & Documentation:
- `validate-hr-integration.ps1` - Setup validation
- `start-with-hr-integration.ps1` - Enhanced startup
- `test-hr-integration.ps1` - Integration testing
- `HR_API_INTEGRATION.md` - Complete guide
- `HR_INTEGRATION_COMPLETE.md` - Implementation summary

---

## 🧪 Testing Flow

### 1. Start Application:
```powershell
.\start-with-hr-integration.ps1
```

### 2. Test Valid Login:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoikane Innovations",
    "email": "john.doe@omoikaneinnovations.com",
    "phoneNumber": "+91-9876543210",
    "accountType": "PROFESSIONAL"
  }'
```

### 3. Check Console for OTP:
Look for output like:
```
===========================================
🔐 OTP GENERATED FOR: john.doe@omoikaneinnovations.com
📧 OTP CODE: 1234
⏰ EXPIRES AT: 2026-03-17T15:30:00
===========================================
```

### 4. Verify OTP:
```bash
curl -X POST http://localhost:8080/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: test-device-123" \
  -d '{
    "email": "john.doe@omoikaneinnovations.com",
    "otp": "1234"
  }'
```

---

## 🎯 Key Benefits

- ✅ **No Manual Registration** - Users pre-registered through HR
- ✅ **Centralized Management** - HR system is single source of truth
- ✅ **Auto Provisioning** - Users created automatically on first login
- ✅ **Role Mapping** - Job titles mapped to account types
- ✅ **Enhanced Security** - Company and employee validation
- ✅ **SmartQ Compatible** - Same authentication model

---

## 🆘 Troubleshooting

### Common Issues:

**1. "Company not found"**
- Check company name spelling
- Ensure it contains "omoikane", "tech", or "innovation" (mock mode)

**2. "Employee not found"**
- Use valid email domains (@omoikaneinnovations.com, @techcorp.com)
- Use valid phone patterns (+91-, 91, 9)

**3. "Employee not active"**
- Mock employees are always active
- In production, check HR system employee status

### Debug Commands:
```powershell
# Validate setup
.\validate-hr-integration.ps1

# Check application logs
mvn spring-boot:run

# Test specific endpoints
.\test-hr-integration.ps1
```

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| `HR_API_INTEGRATION.md` | Complete technical guide |
| `HR_INTEGRATION_COMPLETE.md` | Implementation summary |
| `README_HR_INTEGRATION.md` | This quick start guide |

---

## 🔗 Quick Links

- **Application**: http://localhost:8080
- **Test Login**: Use scripts in project root
- **View Logs**: Check console output for OTP codes
- **Database**: pgAdmin 4 (users table updated automatically)

---

**Ready to test HR integration?** Run the validation script first! 🚀

```powershell
.\validate-hr-integration.ps1
```