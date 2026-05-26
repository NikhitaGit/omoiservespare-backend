# 🔐 Production-Ready Signup System

## Overview

This system implements **separate signup flows** for Admins and Vendors with proper security and approval workflows.

---

## 🎯 Key Features

### ✅ Admin Signup
- **First Admin**: Created using a secret key (one-time setup)
- **Additional Admins**: Created by existing admins only
- **No Public Signup**: Admins cannot self-register

### ✅ Vendor Signup
- **Public Registration**: Anyone can apply to become a vendor
- **Approval Workflow**: Applications are PENDING until admin approves
- **Account Activation**: Vendors can only login after approval
- **Vendor Details**: Stores restaurant information separately

### ✅ Security
- Secret key for first admin creation
- JWT authentication for all protected endpoints
- Role-based access control (RBAC)
- Account status validation

---

## 📋 API Endpoints

### 1️⃣ Vendor Registration (Public)

#### **POST** `/api/vendor/register`
Register as a vendor (restaurant owner)

**Request Body:**
```json
{
  "email": "restaurant@example.com",
  "phoneNumber": "+1234567890",
  "restaurantName": "My Restaurant",
  "ownerName": "John Doe",
  "address": "123 Main St, City, State",
  "businessLicense": "BL123456",
  "description": "We serve authentic Italian cuisine"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Vendor application submitted successfully",
  "status": "PENDING",
  "email": "restaurant@example.com",
  "info": "Your application is under review. You will receive an email once approved."
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "User with this email already exists"
}
```

---

#### **GET** `/api/vendor/status/{email}`
Check vendor application status

**Response:**
```json
{
  "success": true,
  "email": "restaurant@example.com",
  "status": "PENDING",
  "message": "Your application is under review. We'll notify you once it's processed."
}
```

**Possible Statuses:**
- `PENDING` - Application under review
- `APPROVED` - Can login and operate
- `REJECTED` - Application denied
- `SUSPENDED` - Account suspended

---

### 2️⃣ Admin Creation

#### **POST** `/api/admin/create-first` (Public - Secret Key Required)
Create the **first admin** in the system

**Request Body:**
```json
{
  "email": "admin@company.com",
  "phoneNumber": "+1234567890",
  "fullName": "Admin User",
  "secretKey": "SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD"
}
```

**Response:**
```json
{
  "success": true,
  "message": "First admin created successfully",
  "email": "admin@company.com",
  "role": "ADMIN"
}
```

**⚠️ Important:**
- This endpoint can only be used **once**
- After first admin is created, it will return an error
- Change the secret key in production (see Configuration section)

---

#### **POST** `/api/admin/create` (Protected - Admin Only)
Create additional admins

**Headers:**
```
Authorization: Bearer <admin-jwt-token>
```

**Request Body:**
```json
{
  "email": "newadmin@company.com",
  "phoneNumber": "+1234567890",
  "fullName": "New Admin"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Admin created successfully",
  "email": "newadmin@company.com",
  "role": "ADMIN"
}
```

---

### 3️⃣ Admin - Vendor Management

#### **GET** `/api/admin/vendors/pending` (Protected - Admin Only)
Get all pending vendor applications

**Headers:**
```
Authorization: Bearer <admin-jwt-token>
```

**Response:**
```json
[
  {
    "id": 1,
    "email": "restaurant@example.com",
    "phoneNumber": "+1234567890",
    "companyName": "My Restaurant",
    "role": "VENDOR",
    "vendorStatus": "PENDING",
    "accountActive": false,
    "createdAt": "2024-01-15T10:30:00"
  }
]
```

---

#### **GET** `/api/admin/vendors` (Protected - Admin Only)
Get all vendors (any status)

**Headers:**
```
Authorization: Bearer <admin-jwt-token>
```

---

#### **POST** `/api/admin/vendors/{vendorId}/process` (Protected - Admin Only)
Approve or reject vendor application

**Headers:**
```
Authorization: Bearer <admin-jwt-token>
```

**Request Body:**
```json
{
  "action": "APPROVE",
  "reason": "All documents verified"
}
```

**Actions:**
- `APPROVE` - Activate vendor account
- `REJECT` - Deny application

**Response:**
```json
{
  "success": true,
  "message": "Vendor approved successfully",
  "vendor": {
    "id": 1,
    "email": "restaurant@example.com",
    "status": "APPROVED"
  }
}
```

---

#### **POST** `/api/admin/vendors/{vendorId}/suspend` (Protected - Admin Only)
Suspend a vendor account

**Headers:**
```
Authorization: Bearer <admin-jwt-token>
```

**Query Parameters:**
- `reason` - Reason for suspension

**Example:**
```
POST /api/admin/vendors/1/suspend?reason=Policy%20violation
```

---

## 🔧 Configuration

### Secret Key Setup

The admin secret key is configured in `application.properties`:

```properties
# Admin Secret Key (CHANGE IN PRODUCTION!)
app.admin.secret-key=SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD
```

**🚨 CRITICAL: Change this in production!**

**Recommended approach:**
1. Generate a strong random key:
   ```bash
   openssl rand -base64 32
   ```

2. Store it as an environment variable:
   ```properties
   app.admin.secret-key=${ADMIN_SECRET_KEY}
   ```

3. Set the environment variable on your server:
   ```bash
   export ADMIN_SECRET_KEY="your-generated-key-here"
   ```

---

## 🗄️ Database Schema

### Users Table (Enhanced)
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    company_name VARCHAR(255),
    role ENUM('USER', 'VENDOR', 'ADMIN') NOT NULL DEFAULT 'USER',
    vendor_status ENUM('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'),
    account_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Vendors Table (New)
```sql
CREATE TABLE vendors (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNIQUE NOT NULL,
    restaurant_name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    address TEXT,
    business_license VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 🔄 Workflow Diagrams

### Vendor Registration Flow
```
1. Vendor submits application
   ↓
2. System creates User (role=VENDOR, status=PENDING, active=false)
   ↓
3. System creates Vendor record (restaurant details)
   ↓
4. Admin receives notification
   ↓
5. Admin reviews application
   ↓
6a. APPROVE → status=APPROVED, active=true (vendor can login)
6b. REJECT → status=REJECTED, active=false (vendor cannot login)
```

### Admin Creation Flow
```
FIRST ADMIN:
1. Use secret key → POST /api/admin/create-first
   ↓
2. Admin created (role=ADMIN, active=true)

ADDITIONAL ADMINS:
1. Existing admin logs in
   ↓
2. POST /api/admin/create (with JWT token)
   ↓
3. New admin created
```

---

## 🧪 Testing

### Test Vendor Registration

**PowerShell:**
```powershell
$body = @{
    email = "testvendor@example.com"
    phoneNumber = "+1234567890"
    restaurantName = "Test Restaurant"
    ownerName = "Test Owner"
    address = "123 Test St"
    businessLicense = "BL123456"
    description = "Test restaurant"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/vendor/register" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

**cURL:**
```bash
curl -X POST http://localhost:8080/api/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testvendor@example.com",
    "phoneNumber": "+1234567890",
    "restaurantName": "Test Restaurant",
    "ownerName": "Test Owner",
    "address": "123 Test St",
    "businessLicense": "BL123456",
    "description": "Test restaurant"
  }'
```

---

### Test First Admin Creation

**PowerShell:**
```powershell
$body = @{
    email = "admin@company.com"
    phoneNumber = "+1234567890"
    fullName = "Admin User"
    secretKey = "SUPER_SECRET_ADMIN_KEY_CHANGE_IN_PROD"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/admin/create-first" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

---

### Test Vendor Approval (Admin)

**PowerShell:**
```powershell
# 1. Login as admin to get JWT token
$loginBody = @{
    email = "admin@company.com"
    phoneNumber = "+1234567890"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginBody

$token = $loginResponse.token

# 2. Get pending vendors
$vendors = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/vendors/pending" `
    -Method GET `
    -Headers @{ Authorization = "Bearer $token" }

# 3. Approve vendor
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

---

## 🔒 Security Best Practices

### 1. Secret Key Management
- ✅ Use environment variables in production
- ✅ Never commit secret keys to version control
- ✅ Rotate keys periodically
- ✅ Use strong, randomly generated keys

### 2. Admin Creation
- ✅ Create first admin immediately after deployment
- ✅ Disable `/api/admin/create-first` after first admin is created
- ✅ Use strong authentication for admin accounts
- ✅ Implement admin activity logging

### 3. Vendor Approval
- ✅ Verify business licenses before approval
- ✅ Check for duplicate registrations
- ✅ Implement email verification
- ✅ Add admin approval notifications

### 4. Rate Limiting
Consider adding rate limiting to prevent abuse:
```java
// Example: Limit vendor registrations to 5 per hour per IP
@RateLimiter(name = "vendorRegistration", fallbackMethod = "rateLimitFallback")
public User registerVendor(VendorRegistrationRequest request) {
    // ...
}
```

---

## 📧 Email Notifications (TODO)

The system has placeholders for email notifications:

1. **Vendor Application Confirmation**
   - Sent to vendor after registration
   - Contains application status and next steps

2. **Admin Notification**
   - Sent to admins when new vendor applies
   - Contains vendor details and approval link

3. **Vendor Approval/Rejection**
   - Sent to vendor after admin decision
   - Contains login instructions (if approved)

**Implementation:**
- Configure email service in `EmailService.java`
- Update email templates
- Enable email sending in production

---

## 🚀 Deployment Checklist

- [ ] Change admin secret key
- [ ] Configure email service
- [ ] Set up database migrations
- [ ] Enable HTTPS
- [ ] Configure CORS for production domain
- [ ] Set up rate limiting
- [ ] Enable logging and monitoring
- [ ] Create first admin account
- [ ] Test vendor registration flow
- [ ] Test admin approval workflow
- [ ] Document admin procedures

---

## 📊 Monitoring

### Key Metrics to Track
1. Number of pending vendor applications
2. Average approval time
3. Rejection rate and reasons
4. Admin activity logs
5. Failed registration attempts

### Database Queries

**Count pending vendors:**
```sql
SELECT COUNT(*) FROM users 
WHERE role = 'VENDOR' AND vendor_status = 'PENDING';
```

**Get vendor registration stats:**
```sql
SELECT 
    vendor_status,
    COUNT(*) as count,
    DATE(created_at) as date
FROM users 
WHERE role = 'VENDOR'
GROUP BY vendor_status, DATE(created_at)
ORDER BY date DESC;
```

---

## 🆘 Troubleshooting

### Issue: "Admin already exists" error
**Solution:** First admin was already created. Use `/api/admin/create` with existing admin credentials.

### Issue: "Invalid secret key" error
**Solution:** Check the secret key in `application.properties` or environment variables.

### Issue: Vendor can't login after approval
**Solution:** Verify `account_active = true` and `vendor_status = 'APPROVED'` in database.

### Issue: Email notifications not working
**Solution:** Configure email service in `application.properties` and implement email templates.

---

## 📝 Summary

✅ **Admins**: Secure creation with secret key, no public signup
✅ **Vendors**: Public registration with admin approval workflow
✅ **Security**: JWT authentication, RBAC, account status validation
✅ **Database**: Separate tables for users and vendor details
✅ **Production-Ready**: Configurable secret keys, proper error handling

**Next Steps:**
1. Change admin secret key
2. Create first admin
3. Test vendor registration
4. Configure email notifications
5. Deploy to production
