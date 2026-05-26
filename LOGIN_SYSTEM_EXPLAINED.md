# 🔐 SmartQ Login System - Complete Explanation

## 📋 Overview

The SmartQ application uses a **passwordless OTP-based authentication system** instead of traditional username/password login. Here's how employee data is stored and the complete login flow works.

---

## 🗄️ Employee Data Storage

### 1. Database Table: `users`
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,           -- Unique employee ID
    company_name VARCHAR(255) NOT NULL, -- Company/Organization name
    email VARCHAR(255) NOT NULL UNIQUE, -- Employee email (login identifier)
    account_type VARCHAR(50),           -- PROFESSIONAL or PERSONAL
    phone_number VARCHAR(50)            -- Optional phone number
);
```

### 2. Sample Employee Data
| id | company_name | email | account_type | phone_number |
|----|--------------|-------|--------------|--------------|
| 1 | Omoikane Innovations | john@omoikane.com | PROFESSIONAL | +91-9876543210 |
| 2 | Tech Corp | jane@techcorp.com | PROFESSIONAL | +91-9876543211 |
| 3 | StartupXYZ | bob@startupxyz.com | PERSONAL | +91-9876543212 |

### 3. Key Points About Employee Data
- ✅ **No passwords stored** - More secure than traditional systems
- ✅ **Email is unique identifier** - Each employee has unique email
- ✅ **Company association** - Employees belong to companies
- ✅ **Account types** - Different access levels (PROFESSIONAL/PERSONAL)
- ✅ **Optional phone** - For SMS notifications

---

## 🔄 Complete Login Flow

### Step 1: Employee Registration (One-time)
```
Employee fills signup form
  ↓
POST /api/auth/signup
  ↓
Backend validates data
  ↓
Employee record created in 'users' table
  ↓
Employee can now login
```

### Step 2: Login Process (Every time)

#### 2.1 Employee Enters Email
```javascript
// Frontend: LoginPage.jsx
const loginData = {
  companyName: "Omoikane Innovations",
  email: "john@omoikane.com",
  phoneNumber: "+91-9876543210",
  accountType: "PROFESSIONAL"
};

// Send to backend
POST /api/auth/login
```

#### 2.2 Backend Processes Login Request
```java
// AuthController.java
@PostMapping("/login")
public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
    // Validate and process login
    authService.validateLogin(
        request.getCompanyName(),
        request.getEmail(),
        request.getPhoneNumber(),
        request.getAccountType()
    );
}
```

#### 2.3 Employee Lookup & OTP Generation
```java
// AuthService.java
public boolean validateLogin(String companyName, String email, String phoneNumber, AccountType accountType) {
    
    // 1. Find or create employee record
    User user = userRepository.findByEmail(email)
        .orElseGet(() -> {
            // Create new employee if doesn't exist
            User newUser = new User();
            newUser.setCompanyName(companyName);
            newUser.setEmail(email);
            newUser.setAccountType(accountType);
            newUser.setPhoneNumber(phoneNumber);
            return newUser;
        });
    
    // 2. Update employee info
    user.setAccountType(accountType);
    if (phoneNumber != null) {
        user.setPhoneNumber(phoneNumber);
    }
    
    // 3. Save employee record
    userRepository.save(user);
    
    // 4. Generate and send OTP
    generateAndSendOtp(email, user.getPhoneNumber());
    
    return true;
}
```

#### 2.4 OTP Generation & Storage
```java
// AuthService.java
public void generateAndSendOtp(String email, String phoneNumber) {
    
    // 1. Delete any existing OTP for this email
    otpRepository.deleteByEmail(email);
    
    // 2. Generate new 4-digit OTP
    String otpValue = generateOtp(); // e.g., "1234"
    
    // 3. Store OTP in database
    Otp otp = new Otp();
    otp.setEmail(email);
    otp.setOtp(otpValue);
    otp.setExpiresAt(LocalDateTime.now().plusMinutes(5)); // 5-minute expiry
    otpRepository.save(otp);
    
    // 4. Send OTP via email and SMS
    emailService.sendOtpEmail(email, otpValue);
    if (phoneNumber != null) {
        smsService.sendOtpSms(phoneNumber, otpValue);
    }
    
    // 5. Log OTP for development
    System.out.println("🔐 OTP GENERATED FOR: " + email);
    System.out.println("📧 OTP CODE: " + otpValue);
}
```

#### 2.5 OTP Storage Table
```sql
CREATE TABLE otps (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,     -- Links to employee email
    otp VARCHAR(10) NOT NULL,        -- The 4-digit code
    expires_at TIMESTAMP NOT NULL    -- 5-minute expiry
);
```

#### 2.6 Employee Receives OTP
```
Employee checks email: "Your OTP is: 1234"
Employee checks SMS: "Your OTP is: 1234. Valid for 5 minutes."
Employee sees OTP in console (development): "📧 OTP CODE: 1234"
```

#### 2.7 Employee Enters OTP
```javascript
// Frontend: OTPPage.jsx
const otpData = {
  email: "john@omoikane.com",
  otp: "1234"
};

// Send to backend
POST /api/auth/verify-otp
Headers: {
  "X-Device-Id": "unique-device-identifier"
}
```

#### 2.8 Backend Verifies OTP
```java
// AuthController.java
@PostMapping("/verify-otp")
public ResponseEntity<LoginResponse> verifyOtp(
    @RequestBody OtpRequest request,
    @RequestHeader("X-Device-Id") String deviceId,
    HttpServletResponse response) {
    
    // 1. Verify OTP
    boolean isValid = authService.verifyOtp(request.getEmail(), request.getOtp());
    
    if (!isValid) {
        return ResponseEntity.badRequest().body(
            new LoginResponse(false, "Invalid or expired OTP", null));
    }
    
    // 2. Get employee record
    User user = authService.getUserByEmail(request.getEmail());
    
    // 3. Generate JWT tokens
    LoginResponse loginResponse = authService.loginSuccess(user, deviceId, response);
    
    return ResponseEntity.ok(loginResponse);
}
```

#### 2.9 OTP Verification Process
```java
// AuthService.java
public boolean verifyOtp(String email, String otpValue) {
    
    // 1. Find OTP record
    Optional<Otp> otpOpt = otpRepository.findByEmailAndOtp(email, otpValue);
    
    if (otpOpt.isEmpty()) {
        return false; // OTP not found
    }
    
    Otp otp = otpOpt.get();
    
    // 2. Check if OTP expired
    if (otp.getExpiresAt().isBefore(LocalDateTime.now())) {
        return false; // OTP expired
    }
    
    // 3. OTP is valid, delete it (one-time use)
    otpRepository.deleteByEmail(email);
    
    return true;
}
```

#### 2.10 JWT Token Generation
```java
// AuthService.java
public LoginResponse loginSuccess(User user, String deviceId, HttpServletResponse response) {
    
    // 1. Generate Access Token (short-lived, ~15 minutes)
    String accessToken = jwtUtil.generateToken(
        user.getEmail(),
        user.getAccountType()
    );
    
    // 2. Generate Refresh Token (long-lived, 7 days)
    RefreshToken refreshToken = new RefreshToken();
    refreshToken.setToken(jwtUtil.generateRefreshToken());
    refreshToken.setUser(user);
    refreshToken.setDeviceId(deviceId);
    refreshToken.setExpiresAt(LocalDateTime.now().plusDays(7));
    refreshToken.setRevoked(false);
    
    // 3. Store refresh token in database
    refreshTokenRepository.save(refreshToken);
    
    // 4. Set refresh token as HttpOnly cookie
    setRefreshCookie(response, refreshToken.getToken());
    
    // 5. Return access token to frontend
    return new LoginResponse(true, "Login successful", accessToken);
}
```

#### 2.11 Token Storage Tables
```sql
-- Refresh tokens for secure session management
CREATE TABLE refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(500) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,              -- Links to employee
    expires_at TIMESTAMP,
    last_used_at TIMESTAMP,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    device_id VARCHAR(255) NOT NULL,      -- Device binding for security
    CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### 2.12 Employee Successfully Logged In
```javascript
// Frontend receives response
{
  "success": true,
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

// Frontend stores access token
localStorage.setItem("authToken", accessToken);

// Employee redirected to dashboard
navigate("/dashboard");
```

---

## 🔍 Employee Data Fetching During Login

### 1. Email-Based Lookup
```java
// Primary method to find employee
Optional<User> user = userRepository.findByEmail("john@omoikane.com");
```

### 2. Database Query Generated
```sql
SELECT u.id, u.company_name, u.email, u.account_type, u.phone_number 
FROM users u 
WHERE u.email = 'john@omoikane.com';
```

### 3. Employee Record Retrieved
```java
User employee = {
    id: 1,
    companyName: "Omoikane Innovations",
    email: "john@omoikane.com",
    accountType: "PROFESSIONAL",
    phoneNumber: "+91-9876543210"
}
```

### 4. Employee Info Used For
- ✅ **OTP Delivery** - Send to email and phone
- ✅ **JWT Claims** - Include email and role in token
- ✅ **Session Management** - Link refresh tokens to employee
- ✅ **Authorization** - Check account type for permissions

---

## 🔐 Security Features

### 1. Device Binding
```java
// Each login is bound to a specific device
refreshToken.setDeviceId(deviceId);

// Prevents token theft across devices
if (!token.getDeviceId().equals(deviceId)) {
    throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Device mismatch");
}
```

### 2. Token Rotation
```java
// Refresh tokens are rotated on each use
token.setRevoked(true); // Invalidate old token
RefreshToken newToken = new RefreshToken(); // Create new token
```

### 3. OTP Expiry
```java
// OTPs expire after 5 minutes
otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));

// One-time use only
otpRepository.deleteByEmail(email); // Delete after verification
```

---

## 📊 Data Flow Diagram

```
Employee Registration:
Frontend → POST /api/auth/signup → AuthService → UserRepository → Database (users table)

Employee Login:
1. Frontend → POST /api/auth/login → AuthService
2. AuthService → UserRepository.findByEmail() → Database lookup
3. AuthService → Generate OTP → OtpRepository → Database (otps table)
4. AuthService → EmailService/SmsService → Send OTP
5. Employee receives OTP
6. Frontend → POST /api/auth/verify-otp → AuthService
7. AuthService → OtpRepository.findByEmailAndOtp() → Verify OTP
8. AuthService → Generate JWT tokens
9. AuthService → RefreshTokenRepository → Database (refresh_tokens table)
10. Frontend receives access token → Employee logged in
```

---

## 🗂️ Database Relationships

```sql
-- Employee (users) table
users (id, company_name, email, account_type, phone_number)
  ↓
-- OTP verification (temporary)
otps (email → users.email, otp, expires_at)
  ↓
-- Session management (persistent)
refresh_tokens (user_id → users.id, token, device_id, expires_at)
  ↓
-- Order history (business logic)
orders (customer_id → users.id, order_details...)
```

---

## 🎯 Key Advantages of This System

### 1. **Passwordless Security**
- ✅ No password storage or management
- ✅ No password reset flows needed
- ✅ Reduces security vulnerabilities

### 2. **Multi-Factor Authentication**
- ✅ Email verification (something you have)
- ✅ SMS verification (something you have)
- ✅ Device binding (something you are)

### 3. **Flexible Employee Management**
- ✅ Employees can update their info during login
- ✅ Support for multiple companies
- ✅ Different account types and permissions

### 4. **Secure Session Management**
- ✅ JWT tokens with expiry
- ✅ Refresh token rotation
- ✅ Device-bound sessions
- ✅ Automatic logout on security issues

---

## 🧪 Testing Employee Login

### 1. Create Test Employee
```sql
INSERT INTO users (company_name, email, account_type, phone_number)
VALUES ('Test Company', 'employee@test.com', 'PROFESSIONAL', '+91-9876543210');
```

### 2. Test Login Flow
```powershell
# Test login request
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Test Company",
    "email": "employee@test.com",
    "phoneNumber": "+91-9876543210",
    "accountType": "PROFESSIONAL"
  }'

# Check console for OTP
# Use OTP to verify
curl -X POST http://localhost:8080/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: test-device-123" \
  -d '{
    "email": "employee@test.com",
    "otp": "1234"
  }'
```

### 3. Verify Employee Data
```sql
-- Check employee record
SELECT * FROM users WHERE email = 'employee@test.com';

-- Check OTP was created and deleted
SELECT * FROM otps WHERE email = 'employee@test.com';

-- Check refresh token was created
SELECT * FROM refresh_tokens WHERE user_id = (
  SELECT id FROM users WHERE email = 'employee@test.com'
);
```

---

## 📋 Summary

The SmartQ login system is a **modern, secure, passwordless authentication system** that:

1. **Stores employee data** in the `users` table with company association
2. **Uses email as unique identifier** instead of usernames
3. **Generates time-limited OTPs** for authentication
4. **Delivers OTPs via email and SMS** for multi-factor security
5. **Creates JWT tokens** for session management
6. **Binds sessions to devices** for additional security
7. **Rotates refresh tokens** to prevent token reuse attacks

This approach is more secure than traditional password-based systems and provides a better user experience for employees.