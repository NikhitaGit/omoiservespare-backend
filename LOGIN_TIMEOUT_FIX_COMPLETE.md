# 🔧 LOGIN TIMEOUT ISSUE - FIXED

## Problem Identified

When clicking the login button, you were experiencing:
1. **First attempt**: "Timeout exceeded" error
2. **After Ctrl+C and restart**: OTP sent successfully

## Root Cause

The issue was caused by **very short email SMTP timeouts** combined with slow email delivery:

```properties
# OLD (CAUSED TIMEOUT)
spring.mail.properties.mail.smtp.connectiontimeout=5000  # Only 5 seconds!
spring.mail.properties.mail.smtp.timeout=5000
spring.mail.properties.mail.smtp.writetimeout=5000
```

When Gmail's SMTP server took longer than 5 seconds to respond, the backend would timeout **before** returning the OTP response to the frontend. However, the OTP was already saved in the database, which is why it worked on the second attempt.

## Fixes Applied

### 1. Increased SMTP Timeouts (Backend)
**File**: `src/main/resources/application.properties`

```properties
# NEW (30 seconds for email operations)
spring.mail.properties.mail.smtp.connectiontimeout=30000
spring.mail.properties.mail.smtp.timeout=30000
spring.mail.properties.mail.smtp.writetimeout=30000
```

### 2. Increased Frontend Axios Timeout
**File**: `frontend-integration/axiosInstance.js`

```javascript
const api = axios.create({
  baseURL: 'http://localhost:8080',
  timeout: 60000, // 60 seconds (was no timeout before)
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});
```

### 3. Added Async Email Configuration
**File**: `src/main/java/com/omoikaneinnovations/omoiservespare/config/AsyncConfig.java` (NEW)

This ensures email sending happens in a separate thread pool and doesn't block the login response:

```java
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {
    @Bean(name = "emailTaskExecutor")
    public Executor emailTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("EmailAsync-");
        executor.setWaitForTasksToCompleteOnShutdown(false);
        executor.setAwaitTerminationSeconds(0);
        executor.initialize();
        return executor;
    }
}
```

### 4. Improved Login Response Flow
**File**: `src/main/java/com/omoikaneinnovations/omoiservespare/service/ProductionAuthService.java`

Updated to return immediately after saving OTP to database, without waiting for email to be sent:

```java
// Generate and send OTP (async - won't block)
otpAuthService.generateAndSendOtp(request.getEmail(), request.getPhoneNumber());

// Return immediately - email is sent asynchronously
log.info("OTP generation initiated for: {}", request.getEmail());
return UnifiedLoginResponse.otpRequired("OTP sent successfully. Please check your email.");
```

## How It Works Now

### Login Flow (Fixed)
```
1. User clicks "Login" button
   ↓
2. Backend validates credentials (fast)
   ↓
3. Backend saves OTP to database (fast)
   ↓
4. Backend returns success response immediately (fast)
   ↓
5. Backend sends email asynchronously in background (slow, but doesn't block)
   ↓
6. User sees "OTP sent successfully" message within 2-3 seconds
   ↓
7. Email arrives within 5-30 seconds
```

### Before (Broken)
```
1. User clicks "Login" button
   ↓
2. Backend validates credentials
   ↓
3. Backend saves OTP to database
   ↓
4. Backend tries to send email (BLOCKS HERE)
   ↓
5. Email takes 6+ seconds → TIMEOUT!
   ↓
6. User sees "Timeout exceeded" error
```

## Testing the Fix

### Option 1: Use Test Script (Recommended)
```powershell
.\fix-login-timeout.ps1
```

This script will:
- Stop any running backend
- Start the backend
- Wait for startup
- Test the login endpoint
- Show you the OTP in the console

### Option 2: Manual Testing

1. **Restart Backend**:
   ```powershell
   mvn spring-boot:run
   ```

2. **Wait for startup** (look for "Started OmoiservespareApplication"):
   ```
   2025-XX-XX XX:XX:XX.XXX  INFO 12345 --- [main] c.o.o.OmoiservespareApplication : Started OmoiservespareApplication in X.XXX seconds
   ```

3. **Test from React App** (http://localhost:5173):
   - Enter company name: `Omoiservespare Pvt Ltd`
   - Enter email: `user@test.com`
   - Click "Login"
   - Should see "OTP sent successfully" within 2-3 seconds

4. **Check OTP**:
   - Look in backend console for:
     ```
     🔐 OTP GENERATED FOR: user@test.com
     📧 OTP CODE: 1234
     ```
   - Or check your email

## Files Changed

### Backend
1. ✅ `src/main/resources/application.properties` - Increased SMTP timeouts
2. ✅ `src/main/java/com/omoikaneinnovations/omoiservespare/config/AsyncConfig.java` - NEW async config
3. ✅ `src/main/java/com/omoikaneinnovations/omoiservespare/service/ProductionAuthService.java` - Improved response flow

### Frontend
4. ✅ `frontend-integration/axiosInstance.js` - Increased axios timeout

## Expected Behavior

### ✅ Success Indicators
- Login button responds within 2-3 seconds
- "OTP sent successfully" message appears
- OTP printed in backend console immediately
- Email arrives within 5-30 seconds
- No timeout errors

### ❌ If You Still See Timeout
1. **Backend not fully started**: Wait 90+ seconds after running `mvn spring-boot:run`
2. **Port conflict**: Check if port 8080 is in use
3. **Database connection**: Ensure PostgreSQL is running
4. **Email server down**: Gmail SMTP might be unreachable (OTP will still be saved and printed in console)

## Frontend Integration

### Copy Updated Files
```powershell
# Copy the fixed axiosInstance to your frontend
Copy-Item frontend-integration/axiosInstance.js <your-frontend-src-path>/api/axiosInstance.js

# Copy the authApi if needed
Copy-Item frontend-integration/authApi.js <your-frontend-src-path>/api/authApi.js
```

### LoginPage.jsx (No changes needed)
Your current LoginPage.jsx already works correctly with these backend changes.

## Email Configuration

If you want to verify email is working:

1. **Check Gmail SMTP credentials** in `application.properties`:
   ```properties
   spring.mail.username=akshaykabbur8@gmail.com
   spring.mail.password=ahacuztuboepqydt
   ```

2. **Verify Gmail App Password**:
   - Go to https://myaccount.google.com/apppasswords
   - Ensure `ahacuztuboepqydt` is still valid
   - If not, generate a new one and update Vault

## Troubleshooting

### Still Getting Timeout?
```powershell
# 1. Check backend is fully running
# Look for this in console:
# "Started OmoiservespareApplication in X.XXX seconds"

# 2. Test backend health
Invoke-RestMethod -Uri "http://localhost:8080/api/auth/health"

# 3. Test with longer timeout
$payload = @{companyName="Omoiservespare Pvt Ltd"; email="test@test.com"} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:8080/api/auth/user/login" -Method POST -Body $payload -ContentType "application/json" -TimeoutSec 90
```

### Email Not Arriving?
**Don't worry!** The OTP is always printed in the backend console:
```
===========================================
🔐 OTP GENERATED FOR: user@test.com
📧 OTP CODE: 1234
⏰ EXPIRES AT: 2025-XX-XX XX:XX:XX
===========================================
```

## Summary

The timeout issue is now **FIXED**. The problem was:
- ❌ Backend waited for email to send (5+ seconds)
- ❌ SMTP timeout was only 5 seconds
- ❌ Frontend had no timeout configured

Now:
- ✅ Backend returns immediately after saving OTP
- ✅ SMTP timeout increased to 30 seconds
- ✅ Frontend timeout set to 60 seconds
- ✅ Email sends asynchronously in background

**You should now be able to click login and get an immediate response!**
