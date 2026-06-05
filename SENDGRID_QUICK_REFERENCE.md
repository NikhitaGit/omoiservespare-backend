# ⚡ SendGrid Quick Reference Card

## 🔑 Essential URLs

| Purpose | URL |
|---------|-----|
| **Sign Up** | https://signup.sendgrid.com/ |
| **Dashboard** | https://app.sendgrid.com/ |
| **API Keys** | https://app.sendgrid.com/settings/api_keys |
| **Sender Auth** | https://app.sendgrid.com/settings/sender_auth |
| **Email Activity** | https://app.sendgrid.com/activity |
| **Statistics** | https://app.sendgrid.com/statistics |
| **Documentation** | https://docs.sendgrid.com/ |
| **Support** | https://support.sendgrid.com/ |

---

## 📋 Setup Checklist

```
□ Create SendGrid account
□ Verify email address
□ Create API key with "Mail Send" permission
□ Copy API key (you only see it once!)
□ Verify sender email (Single Sender Verification)
□ Add SENDGRID_API_KEY to .env file
□ Add SENDGRID_FROM_EMAIL to .env file
□ Restart application
□ Run test: ./test-sendgrid-email.ps1
□ Check email inbox
□ Monitor SendGrid dashboard
```

---

## 🔐 Environment Variables

```properties
# Required
SENDGRID_API_KEY=SG.your-api-key-here
SENDGRID_FROM_EMAIL=your-verified-email@gmail.com
```

---

## 🧪 Test Commands

```powershell
# Start backend
mvnw spring-boot:run

# Test email sending
./test-sendgrid-email.ps1

# Check with custom email
./test-sendgrid-email.ps1 -TestEmail "yourname@gmail.com"
```

---

## 💰 Pricing (2026)

| Plan | Price | Emails | Best For |
|------|-------|--------|----------|
| **Free** | $0 | 100/day | Development, Testing |
| **Essentials** | $15/mo | 40K/mo | Small Production |
| **Pro** | $60/mo | 120K/mo | Medium Production |
| **Premier** | Custom | Unlimited | Enterprise |

---

## 🐛 Common Issues & Fixes

### Issue: 401 Unauthorized
```
✗ Symptom: "Unauthorized" error when sending
✓ Fix: Check API key is copied correctly
✓ Fix: Recreate API key with "Mail Send" permission
✓ Fix: Restart application after changing API key
```

### Issue: 403 Forbidden
```
✗ Symptom: "Sender identity not verified"
✓ Fix: Complete Single Sender Verification
✓ Fix: Check verification email and click link
✓ Fix: Use exact email address you verified
```

### Issue: Emails in Spam
```
✗ Symptom: Emails landing in spam folder
✓ Fix: Complete Domain Authentication
✓ Fix: Avoid spammy words in email content
✓ Fix: Warm up sender reputation gradually
```

### Issue: Rate Limit
```
✗ Symptom: "Too many requests"
✓ Fix: Upgrade to paid plan (Essentials: $15/mo)
✓ Info: Free tier = 100 emails/day
```

---

## 📊 Monitor Email Delivery

### Activity Dashboard
```
View real-time email status:
→ https://app.sendgrid.com/activity

See: Delivered, Bounced, Deferred, Dropped
```

### Statistics
```
View analytics and trends:
→ https://app.sendgrid.com/statistics

See: Opens, Clicks, Bounces, Spam Reports
```

---

## 🔒 Security Best Practices

```
✓ Never commit .env file to Git
✓ Use Restricted API keys (not Full Access)
✓ Only enable "Mail Send" permission
✓ Rotate API keys every 6 months
✓ Monitor usage in dashboard
✓ Set up alerts for unusual activity
✓ Use different API keys for dev/prod
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `🚀_START_HERE_SENDGRID.md` | Quick start guide |
| `SENDGRID_SETUP_GUIDE.md` | Complete setup instructions |
| `SENDGRID_API_KEY_CREATION_GUIDE.md` | Visual step-by-step guide |
| `SENDGRID_PRODUCTION_DEPLOYMENT.md` | Production deployment guide |
| `.env.example` | Environment variables template |
| `test-sendgrid-email.ps1` | Email testing script |

---

## 🚀 Quick Start (30 seconds)

```bash
# 1. Get API key from SendGrid (see SENDGRID_SETUP_GUIDE.md)
# 2. Add to .env file:
echo "SENDGRID_API_KEY=SG.your-key" >> .env
echo "SENDGRID_FROM_EMAIL=you@gmail.com" >> .env

# 3. Start and test
mvnw spring-boot:run
./test-sendgrid-email.ps1
```

---

## ✨ Features

- ✅ Supports Gmail, Outlook, Yahoo, Zoho, all email providers
- ✅ 99%+ deliverability rate
- ✅ Beautiful HTML email templates
- ✅ Real-time analytics and monitoring
- ✅ Automatic retry on failure (3 attempts)
- ✅ Async sending (non-blocking)
- ✅ Production-grade reliability
- ✅ Free tier (100 emails/day)

---

## 🆘 Get Help

**Official Support:**
- Documentation: https://docs.sendgrid.com/
- Support Ticket: https://support.sendgrid.com/
- Status Page: https://status.sendgrid.com/
- API Reference: https://docs.sendgrid.com/api-reference/mail-send

**Community:**
- Stack Overflow: Tag `sendgrid`
- GitHub Issues: https://github.com/sendgrid/sendgrid-java

---

**⚡ That's it! Keep this handy for quick reference.**
