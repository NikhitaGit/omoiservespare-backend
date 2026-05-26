# 🎨 Multi-Company Architecture - Visual Guide

## 📊 Current vs Future Architecture

### Current (Single Company):
```
┌──────────────────────────────────────────────────┐
│         application.properties                    │
│                                                   │
│  hr.api.base-url=https://company-a.com/api      │
│  hr.api.token=token-123                          │
└──────────────────────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────┐
│              HRApiService                         │
│                                                   │
│  Always calls: https://company-a.com/api         │
└──────────────────────────────────────────────────┘
                      ↓
         ❌ Can only handle ONE company
```

### Future (Multi-Company):
```
┌──────────────────────────────────────────────────┐
│           company_configs (Database)              │
│                                                   │
│  Company A → https://company-a.com/api           │
│  Company B → https://company-b.com/api           │
│  Company C → https://company-c.com/api           │
└──────────────────────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────┐
│         CompanyConfigService (Cache)              │
│                                                   │
│  Fast lookup of company configurations           │
└──────────────────────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────┐
│              HRApiService                         │
│                                                   │
│  Dynamically calls correct company HR API        │
└──────────────────────────────────────────────────┘
                      ↓
         ✅ Can handle UNLIMITED companies
```

---

## 🔄 Login Flow Comparison

### Single Company Flow:
```
User Login
    ↓
Email: john@company.com
    ↓
Call: https://fixed-hr-api.com/employees
    ↓
❌ Problem: What if user is from different company?
```

### Multi-Company Flow:
```
User Login
    ↓
Company: "Tech Corp"
Email: john@techcorp.com
    ↓
Lookup: company_configs WHERE company_name = 'Tech Corp'
    ↓
Found: {
  hr_api_base_url: "https://techcorp-hr.com/api",
  hr_api_token: "tech-token-123"
}
    ↓
Call: https://techcorp-hr.com/api/employees/john@techcorp.com
    ↓
✅ Success: Correct company's HR system called
```

---

## 📊 Database Structure

### company_configs Table:
```
┌─────────────────────────────────────────────────────────┐
│ id │ company_name        │ hr_api_base_url              │
├────┼────────────────────┼──────────────────────────────┤
│ 1  │ Omoiservespare     │ https://omoi-hr.com/api      │
│ 2  │ Tech Corp          │ https://techcorp-hr.com/v2   │
│ 3  │ Innovation Labs    │ https://inno-labs.com/hr     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ hr_api_token        │ hr_api_enabled │ is_active        │
├────────────────────┼────────────────┼──────────────────┤
│ omoi-token-123     │ true           │ true             │
│ tech-token-456     │ true           │ true             │
│ inno-token-789     │ false          │ true             │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Real-World Example

### Scenario: 3 Companies Using Your Application

```
┌─────────────────────────────────────────────────────────┐
│                  Your Application                        │
│              (Single Deployment)                         │
└─────────────────────────────────────────────────────────┘
                      ↓
        ┌─────────────┼─────────────┐
        ↓             ↓             ↓
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Company A   │ │  Company B   │ │  Company C   │
│              │ │              │ │              │
│ 500 employees│ │ 200 employees│ │ 1000 employees│
│              │ │              │ │              │
│ HR System A  │ │ HR System B  │ │ HR System C  │
│ (Workday)    │ │ (BambooHR)   │ │ (Custom)     │
└──────────────┘ └──────────────┘ └──────────────┘
```

### How It Works:

**Company A Employee Login:**
```
1. User enters: "Company A" + email
2. System looks up Company A config
3. Finds: Workday API URL + token
4. Calls Workday API
5. Gets employee data
6. Login success
```

**Company B Employee Login:**
```
1. User enters: "Company B" + email
2. System looks up Company B config
3. Finds: BambooHR API URL + token
4. Calls BambooHR API
5. Gets employee data
6. Login success
```

**Company C Employee Login:**
```
1. User enters: "Company C" + email
2. System looks up Company C config
3. Finds: Custom HR API URL + token
4. Calls Custom API
5. Gets employee data
6. Login success
```

---

## 🔍 Data Flow Diagram

### Complete Multi-Company Login Flow:

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend                              │
│                                                          │
│  User enters:                                            │
│  - Company Name: "Tech Corp"                            │
│  - Email: "john@techcorp.com"                           │
└─────────────────────────────────────────────────────────┘
                      ↓ HTTP POST
┌─────────────────────────────────────────────────────────┐
│              AuthController.login()                      │
│                                                          │
│  Receives: LoginRequest                                 │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│           AuthService.validateLogin()                    │
│                                                          │
│  Step 1: Validate company exists                        │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│      CompanyConfigService.getCompanyConfig()            │
│                                                          │
│  Check cache → If not found, query database             │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│              PostgreSQL Database                         │
│                                                          │
│  SELECT * FROM company_configs                          │
│  WHERE company_name = 'Tech Corp'                       │
│  AND is_active = true                                   │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│              Returns CompanyConfig:                      │
│                                                          │
│  {                                                       │
│    companyName: "Tech Corp",                            │
│    hrApiBaseUrl: "https://techcorp-hr.com/v2",         │
│    hrApiToken: "tech-secret-token-456",                │
│    hrApiEnabled: true                                   │
│  }                                                       │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│      HRApiService.getEmployeeByEmail()                  │
│                                                          │
│  Uses company-specific config to call HR API            │
└─────────────────────────────────────────────────────────┘
                      ↓ HTTP GET
┌─────────────────────────────────────────────────────────┐
│         Tech Corp's HR System                            │
│                                                          │
│  GET https://techcorp-hr.com/v2/employees/john@...     │
│  Authorization: Bearer tech-secret-token-456            │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│              Returns Employee Data:                      │
│                                                          │
│  {                                                       │
│    employeeId: "EMP123",                                │
│    firstName: "John",                                   │
│    email: "john@techcorp.com",                          │
│    status: "active"                                     │
│  }                                                       │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│         AuthService continues validation                 │
│                                                          │
│  - Check employee is active                             │
│  - Create/update user in local database                 │
│  - Generate OTP                                         │
│  - Send OTP                                             │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│              Return Success Response                     │
│                                                          │
│  { success: true, message: "OTP sent" }                │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Caching Strategy

### Without Cache:
```
Every login → Database query → Slow
```

### With Cache:
```
First login → Database query → Cache result
Next logins → Cache hit → Fast (no database query)
```

### Cache Flow:
```
┌─────────────────────────────────────────────────────────┐
│         Request: Get config for "Tech Corp"             │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│              Check In-Memory Cache                       │
│                                                          │
│  configCache.get("Tech Corp")                           │
└─────────────────────────────────────────────────────────┘
                      ↓
        ┌─────────────┴─────────────┐
        ↓                           ↓
   Found in Cache              Not in Cache
        ↓                           ↓
   Return cached config      Query database
   (Fast - 1ms)                    ↓
                            Store in cache
                                   ↓
                            Return config
                            (Slower - 50ms)
```

---

## 🎯 Benefits Visualization

### Scalability:
```
1 Company  → ✅ Supported
10 Companies → ✅ Supported
100 Companies → ✅ Supported
1000 Companies → ✅ Supported

Same code, just add database records!
```

### Flexibility:
```
Company A: Workday API
Company B: BambooHR API
Company C: Custom API
Company D: SAP SuccessFactors
Company E: Oracle HCM

All supported with same codebase!
```

### Performance:
```
Without Cache:
Login 1: 50ms (database query)
Login 2: 50ms (database query)
Login 3: 50ms (database query)
Total: 150ms

With Cache:
Login 1: 50ms (database query + cache)
Login 2: 1ms (cache hit)
Login 3: 1ms (cache hit)
Total: 52ms (3x faster!)
```

---

## 🔒 Security Model

### Token Isolation:
```
┌─────────────────────────────────────────────────────────┐
│  Company A Token: abc123                                │
│  ↓                                                       │
│  Only used for Company A HR API calls                   │
│  ↓                                                       │
│  Company A employees can only access Company A data     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Company B Token: xyz789                                │
│  ↓                                                       │
│  Only used for Company B HR API calls                   │
│  ↓                                                       │
│  Company B employees can only access Company B data     │
└─────────────────────────────────────────────────────────┘

No cross-company data access possible!
```

---

## ✅ Summary

### What You Get:

1. **One Application** → Serves multiple companies
2. **One Database** → Stores all company configs
3. **Dynamic Routing** → Each company → Correct HR API
4. **Fast Performance** → Caching for speed
5. **Easy Management** → Add companies via API/UI
6. **Secure** → Token isolation per company

### Perfect For:

- SaaS applications
- Multi-tenant systems
- Enterprise deployments
- Scalable architectures

**You're ready to scale from 1 to 1000+ companies!** 🚀
