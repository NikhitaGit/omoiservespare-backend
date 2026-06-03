# 📧 Email Not Working on Render - Fix Guide

## Problem
OTP is saved to database but email is NOT being sent. No email logs appear in Render logs.

---

## Root Cause Analysis

Looking at your Render logs, I see:
```
✅ Application started successfully
✅ Database connected
✅ OTP saved to database
❌ NO email sending logs
❌ NO SMTP connection attempts
```

This means **EmailService.sendOtpEmail() is not being called** OR environment variables are missing.

---

## Fix #1: Verify Environment Variables on Render

### Check These Variables Are Set:

Go to your Render dashboard → Your service → Environment tab

**Required for Email:**
```
SENDER_USERNAME=your_email@gmail.com
SENDER_PASSWORD=your_gmail_app_password
FROM_MAIL=your_email@gmail.com
```

### How to Get Gmail App Password:

1. Go to Google Account: https://myaccount.google.com/
2. Security → 2-Step Verification (must be enabled)
3. Scroll down → App passwords
4. Select app: Mail
5. Select device: Other (Custom name)
6. Name it: "OmoiServespare Render"
7. Click Generate
8. Copy the 16-character password
9. Use this as `SENDER_PASSWORD` on Render

---

## Fix #2: Check Auth Service is Calling Email Service

The issue might be that `AuthService` or `UnifiedAuthService` is not calling the email service.

Let me check which service handles OTP sending...

---

## Quick Test on Render

### Test Email Endpoint:

```bash
# Send test OTP
curl -X POST https://omoiservespare-backend.onrender.com/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"your_test_email@gmail.com"}'
```

### Check Render Logs:

After running the test, look for these logs:
```
✅ Should see: "📧 EMAIL SERVICE: OTP Send Initiated"
✅ Should see: "Sending email via SMTP..."
✅ Should see: "✅ EMAIL SENT SUCCESSFULLY"
```

If you DON'T see these logs, the email service is not being called.

---

## Fix #3: Verify OTP Generation Flow

Check which endpoint you're using:

### Option A: /api/auth/send-otp (UnifiedAuthController)
This should call `unifiedAuthService.sendOtp()` which should call `emailService.sendOtpEmail()`

### Option B: /api/auth/otp/send (AuthService)
This should call `authService.sendOtp()` which should call `emailService.sendOtpEmail()`

---

## Diagnostic Steps

### Step 1: Check Environment Variables

```bash
# SSH into Render (if available) or check env tab
echo $SENDER_USERNAME
echo $FROM_MAIL
# Don't echo password for security
```

### Step 2: Test OTP Endpoint

```bash
curl -X POST https://omoiservespare-backend.onrender.com/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}' \
  -v
```

Expected response:
```json
{
  "message": "OTP sent successfully",
  "success": true
}
```

### Step 3: Check Render Real-Time Logs

While testing, watch logs in real-time:
1. Go to Render dashboard
2. Click your service
3. Click "Logs" tab
4. Watch for email-related logs

---

## Common Issues & Solutions

### Issue 1: "SENDER_USERNAME not set"
**Solution**: Add all three email env vars to Render

### Issue 2: "Authentication failed"
**Solution**: 
- Use Gmail App Password, not regular password
- Enable 2-Step Verification first
- Generate new app password

### Issue 3: "Email sent but not received"
**Solution**:
- Check spam folder
- Verify Gmail account has sending enabled
- Check Gmail "Sent" folder
- Try different recipient email

### Issue 4: "No logs at all"
**Solution**: Email service not called
- Check which controller/service handles /send-otp
- Verify it calls emailService.sendOtpEmail()

---

## Immediate Action Required

### 1. Verify Environment Variables on Render

Go to Render Dashboard → Your Service → Environment

Make sure these are set:
- [  ] `SENDER_USERNAME`
- [  ] `SENDER_PASSWORD` 
- [  ] `FROM_MAIL`

### 2. Get Gmail App Password

If you don't have it:
1. Enable 2-Step Verification
2. Generate App Password
3. Update `SENDER_PASSWORD` on Render

### 3. Redeploy if Env Vars Changed

If you added/changed env vars:
- Render will auto-restart
- Wait 2-3 minutes
- Test again

---

## Testing Script

Save this as `test-email-render.ps1`:

```powershell
Write-Host "Testing OTP Email on Render..." -ForegroundColor Cyan

$email = Read-Host "Enter test email address"

$body = @{
    email = $email
} | ConvertTo-Json

Write-Host "`nSending OTP request..." -ForegroundColor Yellow

$response = Invoke-RestMethod -Uri "https://omoiservespare-backend.onrender.com/api/auth/send-otp" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

Write-Host "`nResponse:" -ForegroundColor Green
$response | ConvertTo-Json -Depth 3

Write-Host "`n✅ Check your email: $email" -ForegroundColor Green
Write-Host "✅ Check Render logs for email sending confirmation" -ForegroundColor Green
```

---

## Expected Render Logs (When Working)

```
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
SMTP Server: your_email@gmail.com
========================================
```

---

## Next Steps

1. **Check env vars on Render** (most likely issue)
2. **Get Gmail app password** if not done
3. **Test OTP endpoint** with curl
4. **Watch Render logs** in real-time
5. **Report back** what you see in logs

---

## Need More Help?

If still not working, provide:
1. Screenshot of Render environment variables (blur passwords!)
2. Render logs when you test /send-otp
3. Response from curl test
4. Which endpoint you're hitting (/api/auth/send-otp or /api/auth/otp/send)

The issue is most likely **missing environment variables** on Render!
