# 🔧 Vendor Login Fix

## Problem
Vendor login at `http://localhost:5174/login` was failing with "Invalid credentials" error.

## Root Cause
The vendor user in the database had an incorrect BCrypt password hash that didn't match "vendor123".

## Solution Applied

### 1. Created Utility Controller
Added `PasswordHashController.java` to generate and verify BCrypt hashes for testing.

### 2. Updated Security Config
Added `/api/util/**` to public endpoints in `SecurityConfig.java`.

### 3. Fixed Database
Updated the vendor user's password hash with a correct BCrypt hash for "vendor123".

## Steps to Complete the Fix

### Step 1: Restart the Backend
```powershell
# Stop the current backend (Ctrl+C in the terminal where it's running)
# Then restart:
mvn spring-boot:run
```

### Step 2: Verify Password Encoder
```powershell
./test-password-encoder.ps1
```

This should show:
```
Password: vendor123
Matches: True
✅ Password encoder is working correctly!
```

### Step 3: Test Vendor Login
```powershell
./test-vendor-login.ps1
```

This should return:
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "eyJ...",
  "role": "VENDOR",
  "vendorStatus": "APPROVED"
}
```

### Step 4: Test in Browser
1. Go to `http://localhost:5174/login`
2. Enter credentials:
   - Email: `vendor@restaurant.com`
   - Password: `vendor123`
3. Click "Log In"
4. Should redirect to `/monitor` with success message

## Test Credentials

### Vendor
- **Email**: vendor@restaurant.com
- **Password**: vendor123
- **Role**: VENDOR
- **Status**: APPROVED

### Admin
- **Email**: admin@omoikaneinnovations.com
- **Password**: admin123
- **Role**: ADMIN

## Files Modified
1. `src/main/java/com/omoikaneinnovations/omoiservespare/controller/PasswordHashController.java` (NEW)
2. `src/main/java/com/omoikaneinnovations/omoiservespare/config/SecurityConfig.java`
3. Database: `users` table - updated password_hash for vendor@restaurant.com

## Scripts Created
- `test-vendor-login.ps1` - Test vendor login endpoint
- `test-password-encoder.ps1` - Verify password encoder
- `fix-vendor-password-final.ps1` - Update database with correct hash
- `setup-test-vendor.ps1` - Create test vendor from scratch

## Next Steps
After the backend restarts and tests pass:
1. Test the frontend login at http://localhost:5174/login
2. Verify JWT token is stored in localStorage
3. Verify redirect to /monitor works
4. Test protected routes with the token

## Troubleshooting

### If login still fails after restart:
1. Check backend logs for detailed error messages
2. Verify the vendor user exists:
   ```powershell
   ./check-vendor-password.ps1
   ```
3. Generate a fresh hash and update:
   ```powershell
   ./generate-hash.ps1
   ```

### If "Invalid credentials" persists:
- The PasswordEncoder bean might not be initialized
- Check if BCryptPasswordEncoder is being used
- Verify the password_hash column is not null

### If 404 error:
- Backend is not running
- Wrong port (should be 8080)
- Endpoint path is incorrect

## Security Note
The `PasswordHashController` is for DEVELOPMENT ONLY. Remove it before deploying to production.
