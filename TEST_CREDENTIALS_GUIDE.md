# 🔐 Test Credentials Guide

## How Login Works

Your system uses **OTP-based authentication** that validates against the HR database:

1. Enter **Company Name** + **Email**
2. System validates against HR database
3. If valid, sends **4-digit OTP** to console (email not configured yet)
4. Enter OTP to complete login
5. Receive JWT token

## Available Test Users

### Company 1: Omoiservespare Pvt Ltd

#### User 1 - Nikita (Software Engineer)
```
Company Name: Omoiservespare Pvt Ltd
Email: nikita.a@omoikaneinnovations.com
Phone: +91-9876543210
Department: Engineering
Role: USER (default for employees)
```

#### User 2 - Lata (Senior Software Engineer)
```
Company Name: Omoiservespare Pvt Ltd
Email: lata.b@omoikaneinnovations.com
Phone: +91-9876543211
Department: Engineering
Role: USER
```

#### User 3 - Rahul (Engineering Manager)
```
Company Name: Omoiservespare Pvt Ltd
Email: rahul.sharma@omoikaneinnovations.com
Phone: +91-9876543212
Department: Engineering
Role: USER
```

#### User 4 - Priya (Product Manager)
```
Company Name: Omoiservespare Pvt Ltd
Email: priya.patel@omoikaneinnovations.com
Phone: +91-9876543213
Department: Product
Role: USER
```

#### User 5 - Amit (DevOps Engineer)
```
Company Name: Omoiservespare Pvt Ltd
Email: amit.kumar@omoikaneinnovations.com
Phone: +91-9876543214
Department: Engineering
Role: USER
```

### Company 2: Omoikane Innovations

#### User 6 - John (Software Engineer)
```
Company Name: Omoikane Innovations
Email: john.doe@omoikaneinnovations.com
Phone: +91-9876543220
Department: Engineering
Role: USER
```

#### User 7 - Jane (UI/UX Designer)
```
Company Name: Omoikane Innovations
Email: jane.smith@omoikaneinnovations.com
Phone: +91-9876543221
Department: Design
Role: USER
```

### Company 3: Tech Corp

#### User 8 - Michael (Tech Lead)
```
Company Name: Tech Corp
Email: michael.johnson@techcorp.com
Phone: +91-9876543230
Department: Engineering
Role: USER
```

#### User 9 - Sarah (HR Manager)
```
Company Name: Tech Corp
Email: sarah.williams@techcorp.com
Phone: +91-9876543231
Department: HR
Role: USER
```

---

## How to Create a VENDOR

Vendors must register and be approved by an admin:

### Step 1: Register as Vendor

**API Call:**
```bash
curl -X POST http://localhost:8080/api/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nikita.a@omoikaneinnovations.com",
    "phoneNumber": "+91-9876543210",
    "restaurantName": "Nikita's Kitchen",
    "restaurantAddress": "123 Main St, Bangalore",
    "gstNumber": "29ABCDE1234F1Z5",
    "fssaiNumber": "12345678901234"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Vendor application submitted successfully",
  "status": "PENDING",
  "email": "nikita.a@omoikaneinnovations.com"
}
```

### Step 2: Admin Approves Vendor

**API Call (requires ADMIN token):**
```bash
curl -X POST http://localhost:8080/api/admin/vendors/{vendorId}/process \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "action": "APPROVE",
    "reason": "All documents verified"
  }'
```

### Step 3: Login as Vendor

After approval, login with:
```
Company Name: Omoiservespare Pvt Ltd
Email: nikita.a@omoikaneinnovations.com
```

Now the user has **VENDOR** role and can:
- Access Admin Dashboard
- Manage Menu Items
- View Orders

---

## How to Create an ADMIN

### Step 1: Create First Admin (One-time only)

**API Call:**
```bash
curl -X POST http://localhost:8080/api/admin/create-first \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@omoikaneinnovations.com",
    "phoneNumber": "+91-9999999999",
    "secretKey": "SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "First admin created successfully",
  "email": "admin@omoikaneinnovations.com"
}
```

### Step 2: Login as Admin

```
Company Name: Omoiservespare Pvt Ltd
Email: admin@omoikaneinnovations.com
```

Admin can:
- Access Admin Dashboard
- Approve/Reject Vendors
- Manage All Users
- View All Data

---

## Quick Test Login

### Test as Regular User:

1. Go to http://localhost:5174/login
2. Enter:
   - Company Name: `Omoiservespare Pvt Ltd`
   - Email: `nikita.a@omoikaneinnovations.com`
3. Click "Send OTP"
4. Check backend console for OTP (e.g., "OTP: 1234")
5. Enter the 4-digit OTP
6. Login successful!

### Test as Vendor:

1. First register as vendor (see above)
2. Admin approves the vendor
3. Login with same credentials
4. Now has VENDOR role
5. Can access Admin Dashboard

### Test as Admin:

1. Create first admin (see above)
2. Login with admin credentials
3. Has full system access

---

## Role Permissions

| Feature | USER | VENDOR | ADMIN |
|---------|------|--------|-------|
| Order Food | ✅ | ✅ | ✅ |
| View Canteens | ✅ | ✅ | ✅ |
| Admin Dashboard | ❌ | ✅ | ✅ |
| Manage Menu | ❌ | ✅ | ✅ |
| Approve Vendors | ❌ | ❌ | ✅ |
| Create Admins | ❌ | ❌ | ✅ |

---

## API Endpoints for Testing

### Check HR Data:
```bash
# Get all employees
curl http://localhost:8080/api/hr-mock/employees

# Get employee by email
curl http://localhost:8080/api/hr-mock/employees/by-email/nikita.a@omoikaneinnovations.com

# Get employees by company
curl http://localhost:8080/api/hr-mock/employees/by-company/Omoiservespare%20Pvt%20Ltd

# Get statistics
curl http://localhost:8080/api/hr-mock/statistics
```

### Add Custom Test User:
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
    "phoneNumber": "+91-9999999998",
    "hireDate": "2024-01-01",
    "status": "active",
    "managerEmail": "manager@omoikaneinnovations.com",
    "companyName": "Omoiservespare Pvt Ltd"
  }'
```

---

## Troubleshooting

### "Invalid credentials or user not found"

- Check company name matches exactly (case-sensitive)
- Check email exists in HR database
- Use `/api/hr-mock/employees` to see all available users

### "OTP verification failed"

- Check backend console for the OTP
- OTP is 4 digits (e.g., 1234)
- OTP expires after 5 minutes

### "Access Denied" on Admin Dashboard

- Check user role (must be VENDOR or ADMIN)
- Regular USER role cannot access dashboard
- Register as vendor and get admin approval

---

**Use any of the test users above to login!** 🎉
