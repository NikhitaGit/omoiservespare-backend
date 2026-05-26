# 📚 Step-by-Step Guide: Production-Grade HR Mock System

## 🎯 Goal
Create a production-grade mock HR system that simulates a real Company HR Application for testing login functionality.

---

## 📋 Step 1: Understanding the Architecture

### What We Built:
```
┌─────────────────────────────────────────────────────────┐
│                    Your Application                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  AuthService ──→ HRApiService ──→ MockHRDataService    │
│                         │                                │
│                         │ (if hr.api.enabled=false)     │
│                         ↓                                │
│                  In-Memory HR Database                   │
│                  (10 pre-loaded employees)               │
│                                                          │
│                         │ (if hr.api.enabled=true)      │
│                         ↓                                │
│                  Real HR API                             │
│                  (Your company's HR system)              │
└─────────────────────────────────────────────────────────┘
```

### Key Components:
1. **MockHRDataService** - In-memory HR database
2. **HRApiService** - Switches between mock and real API
3. **HRMockDataController** - Management API
4. **Pre-loaded Data** - 10 realistic employees

---

## 📋 Step 2: Verify Installation

### Check Files Created:
```powershell
# Check if files exist
Test-Path "src/main/java/com/omoikaneinnovations/omoiservespare/service/MockHRDataService.java"
Test-Path "src/main/java/com/omoikaneinnovations/omoiservespare/controller/HRMockDataController.java"
```

### Compile Application:
```bash
mvn clean compile
```

**Expected**: No compilation errors

---

## 📋 Step 3: Start the Application

```bash
mvn spring-boot:run
```

### Look for This in Console:
```
Initializing Mock HR Data Service...
Loaded 10 mock employees
Mock HR Data initialized: 10 employees, 4 companies
```

**This confirms the mock HR system is loaded!**

---

## 📋 Step 4: View Available Employees

### Option A: Using Browser
Open: `http://localhost:8080/api/hr-mock/employees`

### Option B: Using PowerShell
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/hr-mock/employees" -Method GET | ConvertTo-Json
```

### Option C: Using Test Script
```powershell
.\test-mock-hr-system.ps1
```

### You Should See:
- 10 employees
- 4 companies
- Various job titles and departments

---

## 📋 Step 5: Test Employee Lookup

### Test 1: Find by Email
```bash
curl http://localhost:8080/api/hr-mock/employees/by-email/nikita.a@omoikaneinnovations.com
```

**Expected Response:**
```json
{
  "employeeId": "EMP001",
  "firstName": "Nikita",
  "lastName": "A",
  "email": "nikita.a@omoikaneinnovations.com",
  "department": "Engineering",
  "jobTitle": "Software Engineer",
  "phoneNumber": "+91-9876543210",
  "status": "active",
  "companyName": "Omoiservespare Pvt Ltd"
}
```

### Test 2: Find by Phone
```bash
curl http://localhost:8080/api/hr-mock/employees/by-phone/+91-9876543210
```

**Expected**: Same employee data

### Test 3: Validate Company
```bash
curl http://localhost:8080/api/hr-mock/companies/validate/Omoiservespare%20Pvt%20Ltd
```

**Expected**: `true`

---

## 📋 Step 6: Test Login Integration

### Test with Pre-loaded Employee:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "nikita.a@omoikaneinnovations.com",
    "phoneNumber": "+91-9876543210",
    "accountType": "PROFESSIONAL"
  }'
```

### Expected Flow:
```
1. Company validation → SUCCESS (Omoiservespare Pvt Ltd found)
2. Employee lookup → SUCCESS (Nikita A found)
3. Employee status check → SUCCESS (active)
4. User provisioning → SUCCESS (created in local DB)
5. OTP generation → SUCCESS (check console)
6. Response → "OTP sent successfully"
```

### Check Console for:
```
=== LOGIN VALIDATION START ===
Company: Omoiservespare Pvt Ltd
Email: nikita.a@omoikaneinnovations.com
Step 1: Validating company in HR system...
Company validation PASSED
...
Found employee in mock HR data: nikita.a@omoikaneinnovations.com
...
===========================================
🔐 OTP GENERATED FOR: nikita.a@omoikaneinnovations.com
📧 OTP CODE: 1234
===========================================
```

---

## 📋 Step 7: Test Different Scenarios

### Scenario 1: Login with Different Employee
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "lata.b@omoikaneinnovations.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'
```

**Expected**: Success with Lata B's data

### Scenario 2: Login with Phone Only
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "",
    "phoneNumber": "+91-9876543211",
    "accountType": "PROFESSIONAL"
  }'
```

**Expected**: Success, finds Lata B by phone

### Scenario 3: Invalid Company
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Invalid Company",
    "email": "nikita.a@omoikaneinnovations.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'
```

**Expected**: 400 Bad Request, "Invalid credentials"

### Scenario 4: Employee Not Found
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "nonexistent@omoikaneinnovations.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'
```

**Expected**: 400 Bad Request, "Invalid credentials"

### Scenario 5: Inactive Employee
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "inactive.user@omoikaneinnovations.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'
```

**Expected**: 400 Bad Request, "Invalid credentials"

---

## 📋 Step 8: Add Your Own Test Employees

### Method 1: Via API
```bash
curl -X POST http://localhost:8080/api/hr-mock/employees \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "EMP999",
    "firstName": "Test",
    "lastName": "User",
    "email": "test.user@omoikaneinnovations.com",
    "department": "Engineering",
    "jobTitle": "Software Engineer",
    "phoneNumber": "+91-9999999999",
    "hireDate": "2024-01-01",
    "status": "active",
    "managerEmail": "manager@omoikaneinnovations.com",
    "companyName": "Omoiservespare Pvt Ltd"
  }'
```

### Method 2: Edit Code
1. Open `MockHRDataService.java`
2. Find `loadMockEmployees()` method
3. Add your employee:
```java
addEmployee(createEmployee(
    "EMP999",
    "Your",
    "Name",
    "your.email@omoikaneinnovations.com",
    "Engineering",
    "Your Job Title",
    "+91-9999999999",
    "2024-01-01",
    "active",
    "manager@omoikaneinnovations.com",
    "Omoiservespare Pvt Ltd"
));
```
4. Restart application

---

## 📋 Step 9: Monitor and Manage

### Get Statistics:
```bash
curl http://localhost:8080/api/hr-mock/statistics
```

### Get Employees by Company:
```bash
curl http://localhost:8080/api/hr-mock/employees/by-company/Omoiservespare%20Pvt%20Ltd
```

### Reload Data:
```bash
curl -X POST http://localhost:8080/api/hr-mock/reload
```

---

## 📋 Step 10: Switch to Production

When ready to use real HR API:

### 1. Update Configuration:
Edit `application.properties`:
```properties
hr.api.enabled=true
hr.api.base-url=https://your-actual-hr-api.com/v1
hr.api.token=your-actual-api-token
```

### 2. Restart Application:
```bash
mvn spring-boot:run
```

### 3. Test:
The system now calls real HR API instead of mock data!

---

## ✅ Success Checklist

- [ ] Mock HR system initialized (check console)
- [ ] Can view all employees via API
- [ ] Can search employees by email
- [ ] Can search employees by phone
- [ ] Company validation works
- [ ] Login with mock employee succeeds
- [ ] OTP generated and displayed in console
- [ ] Can add custom employees
- [ ] Statistics API works
- [ ] Ready to switch to production

---

## 🎯 Summary

You now have a **production-grade mock HR system** that:
- ✅ Simulates real HR application
- ✅ Contains 10 pre-loaded employees
- ✅ Supports all lookup methods
- ✅ Integrates seamlessly with login
- ✅ Easy to manage and extend
- ✅ Ready for comprehensive testing
- ✅ Can switch to production with one config change

**Next**: Test all scenarios and add your own employees as needed!