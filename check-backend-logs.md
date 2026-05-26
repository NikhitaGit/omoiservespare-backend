# 🔍 Check Backend Logs for Error Details

## The 400 Error is Coming from Backend

Your frontend is sending the request correctly:
```javascript
{
  email: 'nikita.a@omoikaneinnovations.com',
  otp: '6974'
}
```

But the backend is rejecting it with 400 Bad Request.

## What to Check in Backend Console

Look for these error messages in your Spring Boot console:

### 1. Validation Errors
```
Validation failed for argument...
Field error in object 'otpRequest'...
```

### 2. OTP Errors
```
Invalid or expired OTP
OTP not found for email
OTP verification failed
```

### 3. User Errors
```
User not found
Account is disabled
Invalid credentials
```

### 4. Exception Stack Traces
```
java.lang.RuntimeException: ...
org.springframework.web.bind.MethodArgumentNotValidException: ...
```

## Common Causes of 400 Error

### 1. OTP Expired (5 minutes)
**Solution:** Request a new login to get a fresh OTP

### 2. Wrong OTP
**Solution:** Check backend console for the exact OTP:
```
=== OTP GENERATED ===
Email: nikita.a@omoikaneinnovations.com
OTP: 1234
=====================
```

### 3. Email Mismatch
**Solution:** Ensure email in OTP verification matches the login email exactly

### 4. Validation Error
**Solution:** Check OtpRequest DTO validation rules

### 5. User Not Found
**Solution:** User might not exist in database after login

## Steps to Diagnose

### Step 1: Check Backend Console
Look at the Spring Boot console output when you click "CONFIRM" on OTP page.

### Step 2: Look for These Patterns

**Pattern 1: Validation Error**
```
2024-01-15 10:30:00.123 WARN  --- [nio-8080-exec-1] .w.s.m.s.DefaultHandlerExceptionResolver : 
Resolved [org.springframework.web.bind.MethodArgumentNotValidException: 
Validation failed for argument [0] in public org.springframework.http.ResponseEntity...]
```

**Pattern 2: OTP Error**
```
2024-01-15 10:30:00.123 ERROR --- [nio-8080-exec-1] c.o.o.c.UnifiedAuthController : 
OTP verification failed: Invalid or expired OTP
```

**Pattern 3: User Error**
```
2024-01-15 10:30:00.123 ERROR --- [nio-8080-exec-1] c.o.o.s.ProductionAuthService : 
VALIDATION FAILED: Employee not found in HR system
```

### Step 3: Share the Error

Copy the error message from backend console and share it.

## Quick Test

Run this to test the backend directly:

```powershell
# Test with PowerShell
$headers = @{
    "Content-Type" = "application/json"
}

$body = @{
    email = "nikita.a@omoikaneinnovations.com"
    otp = "1234"  # Use actual OTP from backend console
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/verify-otp" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -UseBasicParsing
    
    Write-Host "Success!" -ForegroundColor Green
    $response.Content
} catch {
    Write-Host "Error!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)"
    
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "Error Body: $errorBody"
}
```

## What to Share

Please share:
1. **Backend console output** when OTP verification fails
2. **Exact OTP** shown in backend console
3. **Email** you're using for login
4. **Time difference** between login and OTP entry (OTP expires in 5 minutes)

## Possible Issues

| Issue | How to Check | Solution |
|-------|--------------|----------|
| OTP Expired | Check timestamp in backend logs | Request new login |
| Wrong OTP | Compare OTP in console vs entered | Use exact OTP from console |
| Email mismatch | Check email in request vs database | Use exact email from login |
| User not created | Check database for user | Restart backend, try again |
| Validation error | Check backend logs for validation | Fix request format |

## Next Steps

1. **Check backend console** for error message
2. **Share the error** so I can fix it
3. **Try with fresh OTP** (request new login)
4. **Verify email matches** exactly

---

**Without seeing the backend error, I can't determine the exact cause.**
**Please share the backend console output when the 400 error occurs.**
