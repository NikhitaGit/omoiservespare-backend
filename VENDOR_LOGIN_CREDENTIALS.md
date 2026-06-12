# 🔐 Vendor Login Credentials

## Test Vendor Account

**Email**: `vendor@restaurant.com`  
**Password**: `vendor123`

## Login URL

- Vendor Login: `http://localhost:5174/login` (or your vendor portal URL)

## How to Login

1. Open the vendor login page
2. Enter email: `vendor@restaurant.com`
3. Enter password: `vendor123`
4. Click "Login"

## If Login Fails

The vendor account might need to be created in the database. Run this script:

```powershell
.\create-test-vendor.ps1
```

Or manually run this SQL:

```sql
-- Delete existing vendor if exists
DELETE FROM vendor_profiles WHERE user_id IN (SELECT id FROM users WHERE email = 'vendor@restaurant.com');
DELETE FROM users WHERE email = 'vendor@restaurant.com';

-- Create vendor account
INSERT INTO users (
    email, 
    phone_number, 
    password_hash, 
    role, 
    account_active, 
    vendor_status, 
    created_at, 
    updated_at
)
VALUES (
    'vendor@restaurant.com',
    '+91-9999999991',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', -- vendor123
    'VENDOR',
    true,
    'APPROVED',
    NOW(),
    NOW()
);
```

## Other Test Accounts

| Account Type | Email | Password | Status |
|-------------|-------|----------|--------|
| Admin | admin@omoikaneinnovations.com | admin123 | Active |
| User | nikita.a@omoikaneinnovations.com | OTP-based | Active |
| Vendor | vendor@restaurant.com | vendor123 | Approved |

## Troubleshooting

### "Invalid credentials" error

1. Check if vendor exists in database:
```powershell
.\check-vendor-user.ps1
```

2. Verify password hash is correct:
```sql
SELECT email, role, vendor_status, 
       SUBSTRING(password_hash, 1, 20) as hash_preview
FROM users 
WHERE email = 'vendor@restaurant.com';
```

3. Reset vendor password:
```sql
UPDATE users 
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE email = 'vendor@restaurant.com';
```

### Vendor status is "PENDING"

Update vendor status to APPROVED:
```sql
UPDATE users 
SET vendor_status = 'APPROVED' 
WHERE email = 'vendor@restaurant.com';
```

## Backend Login Endpoint

The vendor login uses this endpoint:
```
POST http://localhost:8080/api/auth/vendor/login

Body:
{
  "email": "vendor@restaurant.com",
  "password": "vendor123"
}
```

## Need a New Vendor?

To register a new vendor account:
```
POST http://localhost:8080/api/vendor/register

Body:
{
  "email": "newvendor@example.com",
  "phoneNumber": "+91-1234567890",
  "password": "yourpassword",
  "restaurantName": "Restaurant Name",
  "restaurantAddress": "Address",
  "gstNumber": "GST123456",
  "fssaiNumber": "FSSAI123456"
}
```

Then an admin needs to approve the vendor.
