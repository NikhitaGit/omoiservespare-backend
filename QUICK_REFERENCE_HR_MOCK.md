# 🚀 Quick Reference: HR Mock System

## 📋 Pre-loaded Test Credentials

### Your Company Employees:
```
Email: nikita.a@omoikaneinnovations.com
Phone: +91-9876543210
Company: Omoiservespare Pvt Ltd
Status: ✅ Active

Email: lata.b@omoikaneinnovations.com
Phone: +91-9876543211
Company: Omoiservespare Pvt Ltd
Status: ✅ Active

Email: rahul.sharma@omoikaneinnovations.com
Phone: +91-9876543212
Company: Omoiservespare Pvt Ltd
Status: ✅ Active (Manager)
```

## 🧪 Quick Test Commands

### Start Application:
```bash
mvn spring-boot:run
```

### Run All Tests:
```powershell
.\test-mock-hr-system.ps1
```

### Test Login:
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

### View All Employees:
```bash
curl http://localhost:8080/api/hr-mock/employees
```

### Get Statistics:
```bash
curl http://localhost:8080/api/hr-mock/statistics
```

## 📊 API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/hr-mock/employees` | List all employees |
| GET | `/api/hr-mock/employees/by-email/{email}` | Find by email |
| GET | `/api/hr-mock/employees/by-phone/{phone}` | Find by phone |
| GET | `/api/hr-mock/statistics` | Get statistics |
| GET | `/api/hr-mock/companies/validate/{name}` | Validate company |
| POST | `/api/hr-mock/employees` | Add employee |
| DELETE | `/api/hr-mock/employees/{email}` | Remove employee |
| POST | `/api/hr-mock/reload` | Reload data |

## 🔧 Configuration

### Mock Mode (Current):
```properties
hr.api.enabled=false
```

### Production Mode:
```properties
hr.api.enabled=true
hr.api.base-url=https://your-hr-api.com/v1
hr.api.token=your-api-token
```

## ✅ Success Indicators

### Console Output:
```
✅ Initializing Mock HR Data Service...
✅ Loaded 10 mock employees
✅ Mock HR Data initialized: 10 employees, 4 companies
```

### Login Success:
```
✅ Company validation PASSED
✅ Found employee in mock HR data
✅ Employee is active
✅ User created/updated in local database
✅ OTP GENERATED FOR: email@domain.com
```

## 📚 Documentation

- **Complete Guide**: `PRODUCTION_GRADE_HR_MOCK.md`
- **Step-by-Step**: `STEP_BY_STEP_HR_MOCK_GUIDE.md`
- **Summary**: `HR_MOCK_IMPLEMENTATION_COMPLETE.md`

## 🆘 Troubleshooting

### Issue: Employees not found
**Solution**: Check console for "Mock HR Data initialized" message

### Issue: Company validation fails
**Solution**: Use exact company name: "Omoiservespare Pvt Ltd"

### Issue: Login returns 400
**Solution**: Verify employee email exists in mock data

## 🎯 Quick Win

Test with Nikita's credentials - guaranteed to work:
- Company: Omoiservespare Pvt Ltd
- Email: nikita.a@omoikaneinnovations.com
- Phone: +91-9876543210