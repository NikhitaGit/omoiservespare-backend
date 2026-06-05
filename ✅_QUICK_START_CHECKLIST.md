# ✅ SendGrid Quick Start Checklist

Print this out and check off as you go!

---

## 🎯 Goal
Set up SendGrid for production-grade OTP email delivery in ~10 minutes.

---

## 📋 Step-by-Step Checklist

### Part 1: SendGrid Account Setup (5 min)

- [ ] **1.1** Go to https://signup.sendgrid.com/
- [ ] **1.2** Fill in signup form (email, password, name)
- [ ] **1.3** Click "Create Account"
- [ ] **1.4** Check email inbox
- [ ] **1.5** Click verification link in email
- [ ] **1.6** Complete account setup form
  - [ ] Select "Transactional" email type
  - [ ] Enter company name
  - [ ] Select "Developer" role
- [ ] **1.7** Click "Get Started"

### Part 2: Create API Key (2 min)

- [ ] **2.1** In SendGrid dashboard, click "Settings" (left sidebar)
- [ ] **2.2** Click "API Keys"
- [ ] **2.3** Click "Create API Key" button (top right)
- [ ] **2.4** Enter name: `HRMS_OTP_Production`
- [ ] **2.5** Select "Restricted Access" radio button
- [ ] **2.6** Scroll down to find "Mail Send"
- [ ] **2.7** Toggle "Mail Send" to ON (green)
- [ ] **2.8** Click "Create & View" button
- [ ] **2.9** ⚠️ **COPY THE API KEY NOW!** (You'll never see it again)
  - [ ] Click "Copy" button OR
  - [ ] Manually select entire key and copy
- [ ] **2.10** Paste API key somewhere safe (Notepad, password manager)
- [ ] **2.11** Click "Done"

**Your API key looks like:**
```
SG.AbCdEfGhIjKlMnOpQr.StUvWxYzAbCdEfGhIjKlMnOpQrStUv
```

### Part 3: Verify Sender Email (2 min)

- [ ] **3.1** Click "Settings" → "Sender Authentication"
- [ ] **3.2** Under "Single Sender Verification", click "Get Started"
- [ ] **3.3** Click "Create New Sender"
- [ ] **3.4** Fill in form:
  - [ ] From Name: `HRMS Team`
  - [ ] From Email: `your-email@gmail.com` (your real email)
  - [ ] Reply To: Same as From Email
  - [ ] Nickname: `HRMS OTP Sender`
  - [ ] Company: Your company name
  - [ ] Address: Your address
  - [ ] City, State, Zip, Country
- [ ] **3.5** Click "Create"
- [ ] **3.6** Check your email inbox
- [ ] **3.7** Open email: "SendGrid Sender Verification"
- [ ] **3.8** Click "Verify Single Sender" button
- [ ] **3.9** See success message: "Sender verified successfully!"

### Part 4: Configure Application (1 min)

- [ ] **4.1** Open your project in IDE/Editor
- [ ] **4.2** Create file named `.env` in project root
- [ ] **4.3** Add these lines to `.env`:
  ```properties
  SENDGRID_API_KEY=SG.your-actual-api-key-here
  SENDGRID_FROM_EMAIL=your-verified-email@gmail.com
  ```
- [ ] **4.4** Replace `SG.your-actual-api-key-here` with your copied API key
- [ ] **4.5** Replace `your-verified-email@gmail.com` with the email you verified
- [ ] **4.6** Save the `.env` file

**Example `.env` file:**
```properties
SENDGRID_API_KEY=SG.AbCdEfGhIjKlMnOpQr.StUvWxYzAbCdEfGhIjKlMnOpQrStUv
SENDGRID_FROM_EMAIL=noreply@mycompany.com
```

### Part 5: Test Configuration (2 min)

- [ ] **5.1** Open terminal/PowerShell in project directory
- [ ] **5.2** Start backend:
  ```powershell
  mvnw spring-boot:run
  ```
- [ ] **5.3** Wait for message: "Started OmoiservespareApplication in X seconds"
- [ ] **5.4** Open NEW terminal/PowerShell window
- [ ] **5.5** Run test script:
  ```powershell
  ./test-sendgrid-email.ps1
  ```
- [ ] **5.6** When prompted, enter your email address
- [ ] **5.7** Press Enter
- [ ] **5.8** See success message: "✅ OTP request successful!"
- [ ] **5.9** Check your email inbox
- [ ] **5.10** Look for email: "Your Login OTP - Secure Authentication"
- [ ] **5.11** If not in inbox, check Spam/Junk folder

**✨ If you received the email, YOU'RE DONE! 🎉**

---

## 🎉 Success Criteria

You've successfully set up SendGrid when:

- ✅ API key created and copied
- ✅ Sender email verified
- ✅ `.env` file configured
- ✅ Test script runs without errors
- ✅ Email arrives in inbox
- ✅ SendGrid dashboard shows delivery

---

## 🐛 Troubleshooting

### Problem: "401 Unauthorized"
**Fix:**
- [ ] Check API key is copied correctly (no spaces, no line breaks)
- [ ] Recreate API key with "Mail Send" permission
- [ ] Restart application

### Problem: "403 Forbidden - Sender not verified"
**Fix:**
- [ ] Complete sender verification (Part 3 above)
- [ ] Check verification email and click link
- [ ] Use exact email address you verified

### Problem: Email goes to spam
**Fix:**
- [ ] Complete Domain Authentication (Settings → Sender Authentication)
- [ ] Wait 24-48 hours for DNS propagation
- [ ] Check email content for spam-trigger words

### Problem: "Rate limit exceeded"
**Info:** Free tier = 100 emails/day
**Fix:**
- [ ] Upgrade to paid plan (Essentials: $15/mo = 40,000/mo)

---

## 📊 Verify in SendGrid Dashboard

- [ ] **6.1** Go to: https://app.sendgrid.com/activity
- [ ] **6.2** See your test email in activity log
- [ ] **6.3** Status should be "Delivered"
- [ ] **6.4** Go to: https://app.sendgrid.com/statistics
- [ ] **6.5** See delivery statistics

---

## 🚀 Production Deployment

When deploying to production:

- [ ] **7.1** Create production SendGrid API key
- [ ] **7.2** Add environment variables to hosting platform:
  - Render: Dashboard → Environment
  - Heroku: `heroku config:set SENDGRID_API_KEY=...`
  - AWS: Add to environment configuration
- [ ] **7.3** Set these variables:
  ```
  SENDGRID_API_KEY=SG.production-key
  SENDGRID_FROM_EMAIL=noreply@company.com
  ```
- [ ] **7.4** Deploy application
- [ ] **7.5** Test login flow in production
- [ ] **7.6** Monitor SendGrid dashboard

---

## 📚 Documentation Reference

If you get stuck, read these in order:

1. **`🚀_START_HERE_SENDGRID.md`** - Quick overview
2. **`SENDGRID_API_KEY_CREATION_GUIDE.md`** - Visual step-by-step
3. **`SENDGRID_SETUP_GUIDE.md`** - Complete details
4. **`SENDGRID_QUICK_REFERENCE.md`** - Quick answers

---

## ⏱️ Time Estimate

| Task | Time |
|------|------|
| Create account | 2 min |
| Verify email | 1 min |
| Create API key | 2 min |
| Verify sender | 2 min |
| Configure app | 1 min |
| Test | 2 min |
| **TOTAL** | **~10 min** |

---

## 🎯 Final Check

Before marking this complete:

- [ ] SendGrid account exists
- [ ] API key created and saved
- [ ] Sender email verified
- [ ] `.env` file configured
- [ ] Test email received
- [ ] Production environment configured (if deploying)

---

## 🆘 Need Help?

**SendGrid Support:**
- Docs: https://docs.sendgrid.com/
- Support: https://support.sendgrid.com/
- Status: https://status.sendgrid.com/

**Project Documentation:**
- See all `.md` files in project root
- Start with: `🚀_START_HERE_SENDGRID.md`

---

**✅ Congratulations! Your production-grade email system is ready! 🎉**

Print this checklist and keep it handy for future reference.
