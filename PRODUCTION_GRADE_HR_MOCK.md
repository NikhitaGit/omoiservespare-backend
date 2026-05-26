# 🏭 Production-Grade HR Mock Data System

## 📋 Overview

This document explains the production-grade mock HR data system that simulates a real Company HR Application for testing purposes.

## 🎯 What Was Implemented

### 1. MockHRDataService
A comprehensive in-memory HR database service that:
- Stores employee data in memory (simulates HR database)
- Provides fast lookups by email, phone, and employee ID
- Validates companies
- Manages employee lifecycle
- Provides statistics and reporting

### 2. Updated HRApiService
Enhanced to use the mock data service:
- Seamlessly switches between mock and real HR API
- Uses production-grade mock data when `hr.api.enabled=false`
- Falls back to real API when `hr.api.enabled=true`

### 3. HRMockDataController
Management API for viewing and managing mock data:
- View all employees
- Search by email/phone/company
- Add/remove employees dynamically
- Get statistics
- Reload data

## 📊 Pre-loaded Mock Data

### Companies:
1. **Omoiservespare Pvt Ltd** (Your company)
2. **Omoikane Innovations**
3. **Tech Corp**
4. **Innovation Labs**

### Employees (10 total):

#### Omoiservespare Pvt Ltd:
| ID | Name | Email | Phone | Job Title | Status |
|----|------|-------|-------|-----------|--------|
| EMP001 | Nikita A | nikita.a@omoikaneinnovations.com | +91-9876543210 | Software Engineer | active |
| EMP002 | Lata B | lata.b@omoikaneinnovations.com | +91-9876543211 | Senior Software Engineer | active |
| EMP003 | Rahul Sharma | rahul.sharma@omoikaneinnovations.com | +91-9876543212 | Engineering Manager | active |
| EMP004 | Priya Patel | priya.patel@omoikaneinnovations.com | +91-9876543213 | Product Manager | active |
| EMP005 | Amit Kumar | amit.kumar@omoikaneinnovations.com | +91-9876543214 | DevOps Engineer | active |

#### Omoikane Innovations:
| ID | Name | Email | Phone | Job Title | Status |
|----|------|-------|-------|-----------|--------|
| EMP101 | John Doe | john.doe@omoikaneinnovations.com | +91-9876543220 | Software Engineer | active |
| EMP102 | Jane Smith | jane.smith@omoikaneinnovations.com | +91-9876543221 | UI/UX Designer | active |

#### Tech Corp:
| ID | Name | Email | Phone | Job Title | Status |
|----|------|-------|-------|-----------|--------|
| EMP201 | Michael Johnson | michael.johnson@techcorp.com | +91-9876543230 | Tech Lead | active |
| EMP202 | Sarah Williams | sarah.williams@techcorp.com | +91-9876543231 | HR Manager | active |

#### Test Cases:
| ID | Name | Email | Phone | Job Title | Status |
|----|------|-------|-------|-----------|--------|
| EMP999 | Inactive User | inactive.user@omoikaneinnovations.com | +91-9876543299 | Software Engineer | inactive |

## 🧪 Testing the Mock HR System

### 1. View All Employees
```bash
curl http://localhost:8080/api/hr-mock/employees
```

### 2. Search Employee by Email
```bash
curl http://localhost:8080/api/hr-mock/employees/by-email/nikita.a@omoikaneinnovations.com
```

### 3. Search Employee by Phone
```bash
curl http://localhost:8080/api/hr-mock/employees/by-phone/+91-9876543210
```

### 4. Get Employees by Company
```bash
curl http://localhost:8080/api/hr-mock/employees/by-company/Omoiservespare%20Pvt%20Ltd
```

### 5. Get HR Statistics
```bash
curl http://localhost:8080/api/hr-mock/statistics
```

### 6. Validate Company
```bash
curl http://localhost:8080/api/hr-mock/companies/validate/Omoiservespare%20Pvt%20Ltd
```

## 🔄 How It Works

### Mock Mode (Default):
```
User Login
    ↓
AuthService.validateLogin()
    ↓
HRApiService.validateCompany() → MockHRDataService.isValidCompany()
    ↓
HRApiService.getEmployeeByEmail() → MockHRDataService.findByEmail()
    ↓
Returns employee from in-memory database
    ↓
User provisioned in local database
    ↓
OTP sent
```

### Production Mode:
```
User Login
    ↓
AuthService.validateLogin()
    ↓
HRApiService.validateCompany() → Real HR API call
    ↓
HRApiService.getEmployeeByEmail() → Real HR API call
    ↓
Returns employee from actual HR system
    ↓
User provisioned in local database
    ↓
OTP sent
```

## 🎯 Test Scenarios

### Scenario 1: Successful Login
```bash
# Login with Nikita's credentials
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "nikita.a@omoikaneinnovations.com",
    "phoneNumber": "+91-9876543210",
    "accountType": "PROFESSIONAL"
  }'

# Expected: Success, OTP sent
```

### Scenario 2: Login with Phone Number
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "",
    "phoneNumber": "+91-9876543211",
    "accountType": "PROFESSIONAL"
  }'

# Expected: Success, finds Lata B by phone
```

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

# Expected: 400 Bad Request, company not found
```

### Scenario 4: Inactive Employee
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "inactive.user@omoikaneinnovations.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'

# Expected: 400 Bad Request, employee not active
```

### Scenario 5: Employee Not Found
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "nonexistent@omoikaneinnovations.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'

# Expected: 400 Bad Request, employee not found
```

## 🔧 Adding Custom Employees

### Via API:
```bash
curl -X POST http://localhost:8080/api/hr-mock/employees \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "EMP006",
    "firstName": "Your",
    "lastName": "Name",
    "email": "your.name@omoikaneinnovations.com",
    "department": "Engineering",
    "jobTitle": "Software Engineer",
    "phoneNumber": "+91-9876543215",
    "hireDate": "2024-01-01",
    "status": "active",
    "managerEmail": "manager@omoikaneinnovations.com",
    "companyName": "Omoiservespare Pvt Ltd"
  }'
```

### Via Code:
Edit `MockHRDataService.java` and add to `loadMockEmployees()` method:
```java
addEmployee(createEmployee(
    "EMP006",
    "Your",
    "Name",
    "your.name@omoikaneinnovations.com",
    "Engineering",
    "Software Engineer",
    "+91-9876543215",
    "2024-01-01",
    "active",
    "manager@omoikaneinnovations.com",
    "Omoiservespare Pvt Ltd"
));
```

## 🚀 Switching to Production

When ready to use real HR API:

### 1. Update Configuration:
```properties
# application.properties
hr.api.enabled=true
hr.api.base-url=https://your-actual-hr-api.com/v1
hr.api.token=your-actual-api-token
```

### 2. Restart Application:
```bash
mvn spring-boot:run
```

### 3. Test:
The system will now call the real HR API instead of using mock data.

## 📊 Benefits of This Approach

1. **Production-Grade**: Simulates real HR system behavior
2. **Fast Development**: No need for actual HR API during development
3. **Comprehensive Testing**: Test all scenarios (success, failure, edge cases)
4. **Easy Management**: Add/remove employees via API
5. **Seamless Switch**: Toggle between mock and real API with one config change
6. **Realistic Data**: Pre-loaded with realistic employee data
7. **Statistics**: Monitor usage and data
8. **Thread-Safe**: Uses ConcurrentHashMap for concurrent access

## 🎓 Key Features

- ✅ In-memory database simulation
- ✅ Fast lookups (O(1) complexity)
- ✅ Multiple search methods (email, phone, ID)
- ✅ Company validation
- ✅ Employee status management
- ✅ Dynamic data management
- ✅ Statistics and reporting
- ✅ Thread-safe operations
- ✅ Production-ready architecture
- ✅ Easy to extend

## 📝 Next Steps

1. **Test with pre-loaded data** - Use the employees listed above
2. **Add your own employees** - Via API or code
3. **Test all scenarios** - Success, failure, edge cases
4. **Monitor statistics** - Check usage patterns
5. **Switch to production** - When ready, enable real HR API

Your mock HR system is now production-grade and ready for comprehensive testing!