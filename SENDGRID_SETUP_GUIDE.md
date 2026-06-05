# 🚀 SendGrid Setup Guide - Production-Grade Email Configuration

## Why SendGrid?

✅ **99%+ Deliverability Rate** - Industry-leading email delivery  
✅ **Supports All Email Providers** - Gmail, Outlook, Yahoo, Zoho, Corporate Emails  
✅ **Scalable** - Send thousands of emails per day  
✅ **Real-time Analytics** - Track email opens, clicks, bounces  
✅ **Free Tier** - 100 emails/day forever free  
✅ **Production Ready** - Used by companies like Uber, Spotify, Airbnb

---

## Step-by-Step Setup Instructions

### Step 1: Create SendGrid Account

1. **Go to SendGrid Website**
   - Visit: https://signup.sendgrid.com/
   
2. **Sign Up**
   - Click "Start for Free"
   - Enter your email address
   - Create a password
   - Fill in your details
   
3. **Verify Your Email**
   - Check your inbox for verification email
   - Click the verification link

### Step 2: Complete Account Setup

1. **Tell SendGrid About Your Use Case**
   - Select "Transactional" (for OTP emails)
   - Company: Your company name
   - Website: Your website (or enter "n/a" if you don't have one yet)
   
2. **Get Started with Free Tier**
   - Free: 100 emails/day forever
   - No credit card required to start

### Step 3: Create API Key (IMPORTANT!)

1. **Navigate to API Keys**
   - Login to SendGrid dashboard
   - Click "Settings" in left sidebar
   - Click "API Keys"
   
2. **Create New API Key**
   - Click "Create API Key" button (top right)
   - Name: `HRMS_OTP_Production` (or any name you prefer)
   - API Key Permissions: Select **"Restricted Access"**
   
3. **Set Permissions**
   - Find "Mail Send" section
   - Enable **"Mail Send"** (Full Access)
   - Click "Create & View"
   
4. **COPY YOUR API KEY NOW!**
   ```
   ⚠️ CRITICAL: You can only see this API key ONCE!
   
   Your API key will look like:
   SG.xxxxxxxxxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
   
   COPY IT IMMEDIATELY and save it somewhere safe!
   ```

### Step 4: Verify Sender Identity

SendGrid requires sender verification to prevent spam.

#### Option A: Single Sender Verification (Quickest - Recommended for Development)

1. **Go to Sender Authentication**
   - Click "Settings" → "Sender Authentication"
   - Click "Get Started" under "Single Sender Verification"
   
2. **Create Verified Sender**
   - Click "Create New Sender"
   - Fill in the form:
     - **From Name**: HRMS Team (or your app name)
     - **From Email**: your-email@gmail.com (your real email)
     - **Reply To**: Same as From Email
     - **Company Address**: Your address
     - **Nickname**: HRMS OTP Sender
   
3. **Verify Email Address**
   - Check your email inbox
   - Click verification link
   - ✅ Your sender is now verified!

#### Option B: Domain Authentication (Recommended for Production)

1. **Go to Domain Authentication**
   - Click "Settings" → "Sender Authentication"
   - Click "Authenticate Your Domain"
   
2. **Select DNS Provider**
   - Choose your domain provider (GoDaddy, Namecheap, Cloudflare, etc.)
   - Enter your domain (e.g., `yourcompany.com`)
   
3. **Add DNS Records**
   - SendGrid will provide DNS records (CNAME records)
   - Add these to your domain's DNS settings
   - Wait for verification (can take up to 48 hours)

---

## Step 5: Configure Your Application

### Update Environment Variables

Add these to your `.env` file or deployment environment:

```properties
# SendGrid Configuration
SENDGRID_API_KEY=SG.your-actual-api-key-here
SENDGRID_FROM_EMAIL=your-verified-email@gmail.com
```

**Example:**
```properties
SENDGRID_API_KEY=SG.AbCdEfGhIjKlMnOpQrStUv.WxYzAbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGh
SENDGRID_FROM_EMAIL=noreply@yourcompany.com
```

### For Local Development

Create/update `.env` file in project root:

```properties
SENDGRID_API_KEY=SG.your-test-api-key-here
SENDGRID_FROM_EMAIL=your-email@gmail.com
```

### For Production Deployment (Render/Heroku/AWS)

Add environment variables in your hosting platform:

**Render:**
- Dashboard → Your Service → Environment
- Add: `SENDGRID_API_KEY` and `SENDGRID_FROM_EMAIL`

**Heroku:**
```bash
heroku config:set SENDGRID_API_KEY=SG.your-api-key
heroku config:set SENDGRID_FROM_EMAIL=your-email@gmail.com
```

**AWS/Docker:**
Add to environment variables or secrets manager

---

## Step 6: Test Your Configuration

### Test Script (PowerShell)

Save this as `test-sendgrid-email.ps1`:

```powershell
# Test SendGrid email configuration
$testEmail = "your-test-email@gmail.com"

Write-Host "🧪 Testing SendGrid Email Configuration..." -ForegroundColor Cyan

# 1. Check if backend is running
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method GET -ErrorAction Stop
    Write-Host "✅ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is not running. Start it first!" -ForegroundColor Red
    exit 1
}

# 2. Request OTP
Write-Host "`n📧 Requesting OTP for: $testEmail" -ForegroundColor Yellow

$otpRequest = @{
    employeeId = "12345"
    email = $testEmail
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/unified-auth/send-otp" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $otpRequest
    
    Write-Host "✅ OTP request sent successfully!" -ForegroundColor Green
    Write-Host "`n📬 Check your email inbox: $testEmail" -ForegroundColor Cyan
    Write-Host "   - Check Spam/Junk folder if not in inbox" -ForegroundColor Yellow
    Write-Host "`nResponse: $($response | ConvertTo-Json)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to send OTP" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✨ Check SendGrid Dashboard for email delivery stats:" -ForegroundColor Cyan
Write-Host "   https://app.sendgrid.com/statistics" -ForegroundColor Blue
```

Run the test:
```powershell
./test-sendgrid-email.ps1
```

---

## Troubleshooting

### Issue 1: API Key Not Working

**Error:** `401 Unauthorized` or `403 Forbidden`

**Solutions:**
1. Double-check API key is copied correctly (no spaces)
2. Ensure "Mail Send" permission is enabled
3. Create a new API key with Full Access
4. Restart your application after updating API key

### Issue 2: Sender Email Not Verified

**Error:** `Sender identity verification required`

**Solutions:**
1. Complete Single Sender Verification (Step 4)
2. Check verification email in your inbox
3. Use the exact email address you verified

### Issue 3: Emails Going to Spam

**Solutions:**
1. Complete Domain Authentication (better deliverability)
2. Avoid spammy words in subject/content
3. Implement SPF, DKIM, DMARC records
4. Warm up your sending domain gradually

### Issue 4: Rate Limit Exceeded

**Error:** `Too many requests`

**Solutions:**
- Free tier: 100 emails/day
- Upgrade to Essentials: 40,000 emails/month ($15/month)
- Upgrade to Pro: 120,000 emails/month ($60/month)

---

## SendGrid Dashboard - Monitor Your Emails

### View Email Activity
1. Go to: https://app.sendgrid.com/
2. Click "Activity" in sidebar
3. See real-time email delivery status

### View Statistics
1. Click "Statistics" in sidebar
2. See:
   - Emails delivered
   - Opens
   - Clicks
   - Bounces
   - Spam reports

---

## Pricing (As of 2026)

| Tier | Price | Emails/Month | Best For |
|------|-------|--------------|----------|
| **Free** | $0 | 100/day (3,000/month) | Development, Testing |
| **Essentials** | $15/month | 40,000 | Small Production Apps |
| **Pro** | $60/month | 120,000 | Medium Production Apps |
| **Premier** | Custom | Unlimited | Enterprise |

**Free tier is usually enough for:**
- Development and testing
- Small apps with < 100 users
- OTP emails for authentication

---

## Production Checklist

- [ ] SendGrid account created
- [ ] API key created with "Mail Send" permission
- [ ] API key added to environment variables
- [ ] Sender email verified (Single Sender or Domain)
- [ ] Test email sent successfully
- [ ] Emails arriving in inbox (not spam)
- [ ] Environment variables configured for production
- [ ] Monitoring setup in SendGrid dashboard

---

## Security Best Practices

1. **Never Commit API Keys to Git**
   - Use environment variables
   - Add `.env` to `.gitignore`

2. **Use Restricted API Keys**
   - Only enable "Mail Send" permission
   - Don't use Full Access unless needed

3. **Rotate API Keys Regularly**
   - Create new keys every 6-12 months
   - Delete old keys after rotation

4. **Monitor Usage**
   - Check SendGrid dashboard for unusual activity
   - Set up alerts for suspicious sends

---

## Support & Resources

- **SendGrid Documentation:** https://docs.sendgrid.com/
- **API Reference:** https://docs.sendgrid.com/api-reference/mail-send/mail-send
- **Support:** https://support.sendgrid.com/
- **Status Page:** https://status.sendgrid.com/

---

## Next Steps

1. ✅ Complete SendGrid setup (Steps 1-4)
2. ✅ Add API key to environment variables (Step 5)
3. ✅ Run test script (Step 6)
4. ✅ Deploy to production with environment variables
5. ✅ Monitor email delivery in SendGrid dashboard

**Your OTP emails are now production-ready! 🎉**
