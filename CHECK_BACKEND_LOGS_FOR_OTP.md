# 🔍 Check Backend Logs for OTP Generation

## The Problem
- ✅ Redirect to OTP page works
- ❌ OTP not in database
- ❌ OTP not in email

## What To Check Now

### 1. Look at Backend Console Logs

When you clicked "Log In", you should see these log lines in your backend console:

#### Expected Log Sequence:

```
INFO  - User/Admin login attempt: nikita.a@omoikaneinnovations.com from company: Omoiservespare Pvt Ltd
INFO  - Created new user from HR data: nikita.a@omoikaneinnovations.com
===========================================
🔐 OTP GENERATED FOR: nikita.a@omoikaneinnovations.com
📧 OTP CODE: 1234
⏰ EXPIRES AT: 2026-06-02T09:05:00
===========================================
INFO  - OTP email sent successfully to nikita.a@omoikaneinnovations.com
INFO  - OTP sent to: nikita.a@omoikaneinnovations.com
```

### 2. What Do You See?

**Scenario A: You see NO logs at all**
- Problem: Request not reaching backend
- Solution: Check if backend is running on port 8080

**Scenario B: You see "User/Admin login attempt" but NO OTP logs**
- Problem: OTP generation is failing
- Solution: There's an error being thrown (check for ERROR logs)

**Scenario C: You see OTP generation logs but OTP not in database**
- Problem: Database save failing
- Solution: Check for SQL errors in logs

**Scenario D: You see OTP in logs and database but not in email**
- Problem: Email sending failing
- Solution: Vault email credentials not configured

## Run Diagnostic Script

```powershell
.\debug-otp-issue.ps1
```

This will:
1. Test the login endpoint
2. Check database for OTP
3. Test email configuration
4. List common issues

## Manual Tests

### Test 1: Check Database Connection
```sql
SELECT * FROM otps ORDER BY id DESC LIMIT 5;
```

### Test 2: Check Email Service
```powershell
curl http://localhost:8080/api/test/email-config
```

### Test 3: Test Direct Login
```powershell
curl -X POST http://localhost:8080/api/auth/user/login `
  -H "Content-Type: application/json" `
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "nikita.a@omoikaneinnovations.com",
    "phoneNumber": "+91-9876543210"
  }'
```

## Most Likely Issue: Vault Email Credentials

Your application uses HashiCorp Vault for storing email credentials. If Vault doesn't have the email configuration, the email sending will fail silently.

### Check Vault Configuration

Your Vault should have these secrets at `secret/OmoiServespare`:

```
vault.mail.username=your-gmail@gmail.com
vault.mail.password=your-gmail-app-password
vault.mail.from=your-gmail@gmail.com
```

### Quick Fix: Use Local Email Configuration

If Vault is not configured, temporarily use local configuration for testing:

1. Open `application.properties`
2. **Temporarily** replace these lines:

```properties
# CURRENT (uses Vault):
spring.mail.username=${vault.mail.username}
spring.mail.password=${vault.mail.password}
mail.from=${vault.mail.from}

# TEMPORARY (for testing):
spring.mail.username=your-gmail@gmail.com
spring.mail.password=your-gmail-app-password
mail.from=your-gmail@gmail.com
```

3. Restart backend
4. Test login again

⚠️ **Remember to revert these changes before deploying to production!**

## Expected Behavior After Fix

1. Login request sent
2. Backend logs show "User/Admin login attempt"
3. Backend logs show OTP generation (with code)
4. OTP saved to database
5. Email sent via SMTP
6. Frontend redirects to OTP page
7. User enters OTP
8. Login successful

## Next Steps

1. **Check your backend console RIGHT NOW**
2. Look for the log lines mentioned above
3. If you see an ERROR, share it with me
4. If you see NO logs, the request isn't reaching the backend
5. If you see OTP generated but not in DB, there's a database error

---

**What to do**: Look at your backend console logs and tell me what you see when you try to login.
