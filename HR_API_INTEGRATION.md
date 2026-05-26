# HR API Integration Guide

## Overview

The application now follows the SmartQ authentication model where users are pre-registered through HR system integration instead of manual signup. This document explains how the HR API integration works and how to configure it.

## How It Works

### 1. Login Flow
```
User Login → Validate Company → Fetch Employee from HR → Validate Employee → Send OTP → Verify OTP → Issue Tokens
```

### 2. Authentication Process

1. **Company Validation**: First validates if the company exists in the HR system
2. **Employee Lookup**: Searches for employee by email or phone number in HR system
3. **Employee Validation**: Checks if employee is active and authorized
4. **Local User Creation**: Creates/updates user record in local database with HR data
5. **OTP Generation**: Sends OTP to employee's registered email/phone from HR system
6. **Token Issuance**: Issues JWT tokens after successful OTP verification

## Configuration

### Application Properties

```properties
# HR API Integration Config
hr.api.enabled=false                           # Enable/disable HR API (false = mock mode)
hr.api.base-url=https://api.hrcompany.com/v1   # HR API base URL
hr.api.token=demo-token                        # HR API authentication token
hr.api.timeout=30000                           # Request timeout in milliseconds
```

### Mock Mode vs Production Mode

#### Mock Mode (hr.api.enabled=false)
- Uses mock employee data for testing
- Accepts emails from: @omoikaneinnovations.com, @techcorp.com, @example.com
- Accepts phone numbers starting with: +91-, 91, 9
- Automatically generates employee data for valid patterns

#### Production Mode (hr.api.enabled=true)
- Makes actual HTTP calls to HR API
- Requires valid HR API URL and authentication token
- Returns real employee data from HR system

## HR API Endpoints Expected

The integration expects the following HR API endpoints:

### 1. Validate Company
```
GET /companies/validate/{companyName}
Response: boolean (true if company exists)
```

### 2. Get Employee by Email
```
GET /employees/by-email/{email}
Response: HREmployeeDTO object
```

### 3. Get Employee by Phone
```
GET /employees/by-phone/{phoneNumber}
Response: HREmployeeDTO object
```

## HR Employee Data Structure

```json
{
  "employee_id": "EMP12345",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@company.com",
  "department": "Engineering",
  "job_title": "Software Engineer",
  "phone_number": "+91-9876543210",
  "hire_date": "2023-01-15",
  "status": "active",
  "manager_email": "manager@company.com",
  "company_name": "Tech Corp"
}
```

## Testing

### 1. Run Test Script
```powershell
.\test-hr-integration.ps1
```

### 2. Manual Testing with Mock Data

Valid test credentials (mock mode):
- Company: "Omoikane Innovations" or "Tech Corp"
- Email: "john.doe@omoikaneinnovations.com"
- Phone: "+91-9876543210"

### 3. Test Login Flow
```bash
# 1. Login request
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoikane Innovations",
    "email": "john.doe@omoikaneinnovations.com",
    "phoneNumber": "+91-9876543210",
    "accountType": "PROFESSIONAL"
  }'

# 2. Check console for OTP, then verify
curl -X POST http://localhost:8080/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: test-device-123" \
  -d '{
    "email": "john.doe@omoikaneinnovations.com",
    "otp": "1234"
  }'
```

## Key Features

### 1. Automatic User Provisioning
- Users are automatically created in local database when they first login
- User data is synchronized from HR system
- No manual user registration required

### 2. Role Mapping
- Job titles containing "manager", "lead", or "director" → PROFESSIONAL account type
- Other job titles → PROFESSIONAL account type (default)
- Can be customized in AuthService.validateLogin()

### 3. Security Features
- Company validation prevents unauthorized access
- Employee status validation (only "active" employees can login)
- OTP verification for secure authentication
- JWT tokens with role-based access

### 4. Error Handling
- Graceful fallback to mock data when HR API is unavailable
- Comprehensive logging for debugging
- Proper error responses for invalid credentials

## Production Deployment

### 1. Configure HR API
```properties
hr.api.enabled=true
hr.api.base-url=https://your-hr-api.company.com/v1
hr.api.token=your-actual-api-token
```

### 2. Security Considerations
- Use HTTPS for HR API communication
- Secure API token storage (environment variables)
- Implement rate limiting for HR API calls
- Monitor HR API availability and performance

### 3. Monitoring
- Log HR API response times
- Monitor employee lookup success rates
- Track authentication failures
- Set up alerts for HR API downtime

## Troubleshooting

### Common Issues

1. **HR API Connection Failed**
   - Check hr.api.base-url configuration
   - Verify network connectivity
   - Validate API token

2. **Employee Not Found**
   - Verify employee exists in HR system
   - Check email/phone format
   - Ensure employee status is "active"

3. **Company Validation Failed**
   - Check company name spelling
   - Verify company exists in HR system
   - Check HR API company validation endpoint

### Debug Mode
Enable debug logging:
```properties
logging.level.com.omoikaneinnovations.omoiservespare.service.HRApiService=DEBUG
logging.level.com.omoikaneinnovations.omoiservespare.service.AuthService=DEBUG
```

## Migration from Signup

The following changes were made to remove signup functionality:

1. ✅ Removed signup endpoint from AuthController
2. ✅ Deleted SignupRequest and SignupResponse DTOs
3. ✅ Updated AuthService to use HR API validation
4. ✅ Created HRApiService for HR system integration
5. ✅ Created HREmployeeDTO for HR data mapping
6. ✅ Updated DataInitializer comments
7. ✅ Added HR API configuration properties

The application now follows the SmartQ model where users are pre-registered through HR integration.