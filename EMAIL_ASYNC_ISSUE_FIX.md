# 🔍 Email Async Issue - Diagnostic & Fix

## Problem Identified

Your email IS being called:
```java
// Line 177 in AuthService.java
emailService.sendOtpEmail(email, otpValue);
```

BUT it's marked as `@Async`, which means:
- It runs in a background thread
- Exceptions are swallowed silently
- No error logs appear in Render output

---

## Why No Email Logs Appear

The `EmailService.sendOtpEmail()` is `@Async`, so if it fails:
- No exception is thrown to the caller
- Error logs might be suppressed
- Email fails silently

**Possible causes:**
1. Gmail app password is wrong
2. Gmail account has "Less secure apps" blocking
3. SMTP connection is being blocked
4. Email credentials have typos

---

## Quick Test

### Test on Render Now:

```bash
curl -X POST https://omoiservespare-backend.onrender.com/api/auth/user/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "YOUR_TEST_EMAIL@gmail.com",
    "phoneNumber": "+91-9876543210"
  }'
```

### Expected Response:
```json
{
  "success": true,
  "message": "OTP sent successfully. Please check your email.",
  "otpRequired": true
}
```

### Check Render Logs For:
```
🔐 OTP GENERATED FOR: YOUR_TEST_EMAIL@gmail.com
📧 OTP CODE: 1234
```

Then look for:
```
📧 EMAIL SERVICE: OTP Send Initiated
✅ EMAIL SENT SUCCESSFULLY
```

---

## If No Email Logs Appear

The async method is failing silently. Common issues:

### Issue 1: Wrong App Password
- Gmail app password must be 16 characters
- Format: `xxxx xxxx xxxx xxxx` (with spaces) OR `xxxxxxxxxxxxxxxx` (no spaces)
- Must be generated from Google Account Security

### Issue 2: Wrong Email in SENDER_USERNAME
- Must match the Gmail account
- Format: `your_email@gmail.com`

### Issue 3: FROM_MAIL Mismatch
- Should be same as SENDER_USERNAME
- Gmail rejects if FROM doesn't match authenticated user

---

## Fix: Verify Environment Variables

Go to Render Dashboard → Your Service → Environment

**Double-check these EXACT values:**

```
SENDER_USERNAME=aishushettar95@gmail.com
SENDER_PASSWORD=bbfskhrhtnjkokk  (your actual app password)
FROM_MAIL=aishushettar95@gmail.com
```

### Common Mistakes:
- ❌ Typo in email address
- ❌ Using regular password instead of app password
- ❌ App password has spaces (remove them!)
- ❌ FROM_MAIL different from SENDER_USERNAME

---

## Manual Test Email

Test directly without async:

```bash
# Test endpoint (synchronous, will show errors)
curl -X POST https://omoiservespare-backend.onrender.com/api/test/send-otp \
  -H "Content-Type: application/json" \
  "email=YOUR_EMAIL@gmail.com&otp=1234"
```

This will show SMTP errors if any.

---

## Enable More Logging

Your current config already has:
```properties
logging.level.org.springframework.mail=DEBUG
logging.level.org.eclipse.angus.mail=DEBUG
```

But async errors might still be hidden.

---

## Quick Fix Checklist

1. [ ] Verify `SENDER_USERNAME` is correct
2. [ ] Verify `SENDER_PASSWORD` is app password (16 chars)
3. [ ] Verify `FROM_MAIL` matches `SENDER_USERNAME`
4. [ ] Remove any spaces from app password
5. [ ] Try generating a NEW app password
6. [ ] Test with curl command above
7. [ ] Watch Render logs in real-time

---

## Generate New App Password

If current one doesn't work:

1. Go to: https://myaccount.google.com/apppasswords
2. Delete old "Render" app password
3. Create new one:
   - App: Mail
   - Device: Render Production
4. Copy the 16-character password (no spaces)
5. Update `SENDER_PASSWORD` on Render
6. Wait for automatic restart (2-3 min)
7. Test again

---

## Test Command (Copy-Paste Ready)

Replace YOUR_EMAIL with your test email:

```powershell
$body = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "YOUR_EMAIL@gmail.com"
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://omoiservespare-backend.onrender.com/api/auth/user/login" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

---

## Expected Render Logs (When Working)

```
🔐 OTP GENERATED FOR: test@example.com
📧 OTP CODE: 1234
⏰ EXPIRES AT: 2026-06-03T11:03:00

========================================
📧 EMAIL SERVICE: OTP Send Initiated
Recipient: test@example.com
OTP: 1234
Timestamp: 2026-06-03T10:58:00
========================================
Sending email via SMTP...
========================================
✅ EMAIL SENT SUCCESSFULLY
Recipient: test@example.com
Duration: 1234 ms
SMTP Server: aishushettar95@gmail.com
========================================
```

---

## If Still Not Working

### Check Gmail Account:

1. **Verify 2-Step Verification is ON**
   - https://myaccount.google.com/security

2. **Check "Less secure app access"**
   - Should be OFF (use app passwords instead)

3. **Check Gmail "Sent" folder**
   - Email might be sent but delayed

4. **Try Different Email Provider**
   - Test with Outlook, Yahoo to rule out Gmail issue

---

## Alternative: Use Test Endpoint

If you need emails NOW, use the test endpoint:

```bash
# This bypasses async and shows errors
curl -X POST "https://omoiservespare-backend.onrender.com/api/test/send-otp?email=test@example.com&otp=1234"
```

Check response for actual SMTP error.

---

## Next Steps

1. **Verify env vars** (most likely issue)
2. **Generate new app password** if current one fails
3. **Test with curl** command above
4. **Watch Render logs** in real-time
5. **Check spam folder**
6. **Report back** with any error messages you see

The issue is almost certainly the **app password** or **email configuration**.
