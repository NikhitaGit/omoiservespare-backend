# 📸 SendGrid API Key Creation - Step-by-Step Visual Guide

## Overview
This guide shows you EXACTLY where to click to create your SendGrid API key.

---

## Part 1: Create SendGrid Account

### Step 1: Visit SendGrid
🔗 Go to: **https://signup.sendgrid.com/**

### Step 2: Fill Registration Form
- **Email**: Your work/personal email
- **Password**: Strong password (min 8 characters)
- **First Name**: Your first name
- **Last Name**: Your last name
- Click **"Create Account"** button

### Step 3: Verify Email
- Check your email inbox
- Look for email from SendGrid (check spam if not found)
- Click the **"Verify Your Account"** link
- You'll be redirected to SendGrid dashboard

---

## Part 2: Complete Account Setup

### Step 4: Tell SendGrid About Your Use Case

**You'll see a form with these questions:**

1. **What type of email will you send?**
   - Select: **"Transactional"**
   - (This is for OTP emails)

2. **How do you plan to send email?**
   - Select: **"Integrate using Web API or SMTP"**

3. **Tell us about yourself**
   - Company: Enter your company name or "Personal Project"
   - Website: Enter your website or "N/A"
   - Role: Select "Developer"

4. **Click "Get Started"**

---

## Part 3: Create API Key (MOST IMPORTANT!)

### Step 5: Navigate to API Keys Page

**In the SendGrid Dashboard:**

```
Left Sidebar:
├── Dashboard (home icon)
├── Marketing
├── Email API
└── Settings <--- CLICK HERE
    ├── Sender Authentication
    ├── API Keys <--- THEN CLICK HERE
    ├── Teammates
    └── ...
```

**OR Direct Link:** https://app.sendgrid.com/settings/api_keys

### Step 6: Create New API Key

You'll see a page titled **"API Keys"**

1. **Click the blue "Create API Key" button** (top right corner)

A modal/popup will appear titled **"Create API Key"**

### Step 7: Configure API Key

**In the modal, you'll see:**

1. **API Key Name** (text field)
   - Enter: `HRMS_OTP_Production`
   - Or any descriptive name like: `MyApp_Production_2026`

2. **API Key Permissions** (radio buttons)
   - You'll see 3 options:
     - ⚪ Full Access (NOT RECOMMENDED)
     - ⚪ **Restricted Access** ← SELECT THIS ONE
     - ⚪ Billing Access

3. **Select "Restricted Access"**

### Step 8: Set Mail Send Permission

**After selecting "Restricted Access":**

A long list of permissions will appear. Scroll down to find:

```
Mail Send
  [Toggle Switch] <-- Turn this ON/Green
```

**Make sure ONLY "Mail Send" is enabled!**

### Step 9: Create and View Key

1. Click the blue **"Create & View"** button at the bottom

2. **⚠️ CRITICAL: COPY YOUR API KEY NOW!**

You'll see a screen like:

```
╔══════════════════════════════════════════════════════════╗
║  Your API Key                                            ║
║  ───────────────────────────────────────────────────     ║
║                                                          ║
║  SG.AbCdEfGhIjKlMnOpQr.StUvWxYzAbCdEfGhIjKlMnOpQrStUv  ║
║                                                          ║
║  [Copy] button                                          ║
║                                                          ║
║  ⚠️ Store this in a safe place. You won't be able      ║
║     to see it again!                                    ║
╚══════════════════════════════════════════════════════════╝
```

3. **Click "Copy" button** or manually select and copy the entire key

4. **Paste it somewhere safe immediately!**
   - Notepad
   - Password manager
   - Your `.env` file

5. Click **"Done"** when you've copied it

---

## Part 4: Verify Sender Email

### Step 10: Navigate to Sender Authentication

**In the SendGrid Dashboard:**

```
Left Sidebar:
└── Settings
    ├── Sender Authentication <--- CLICK HERE
    └── ...
```

**OR Direct Link:** https://app.sendgrid.com/settings/sender_auth

### Step 11: Single Sender Verification

You'll see two options:

```
┌─────────────────────────────────┐  ┌──────────────────────────────┐
│ Domain Authentication           │  │ Single Sender Verification   │
│                                 │  │                              │
│ Authenticate your domain to    │  │ Verify a single email        │
│ improve deliverability          │  │ address quickly              │
│                                 │  │                              │
│ [Get Started]                   │  │ [Get Started] <-- CLICK THIS │
└─────────────────────────────────┘  └──────────────────────────────┘
```

**Click "Get Started" under "Single Sender Verification"**

### Step 12: Create Verified Sender

Click **"Create New Sender"** button

Fill in the form:

**From:**
- **From Name**: `HRMS Team` (or your app name)
- **From Email**: `your-email@gmail.com` (YOUR real email)

**Reply To:**
- **Reply To Email**: Same as From Email
- (Or use a support email if you have one)

**Address:**
- **Nickname**: `HRMS OTP Sender` (internal label)
- **Company**: Your company name
- **Address Line 1**: Your address
- **City**: Your city
- **State**: Your state
- **Zip Code**: Your zip
- **Country**: Your country

Click **"Create"** button

### Step 13: Verify Your Email Address

1. Check your email inbox (the email you entered in "From Email")
2. Look for email with subject: **"SendGrid Sender Verification"**
3. Click the **"Verify Single Sender"** link in the email
4. You'll see: **"Sender verified successfully!"**

---

## Part 5: Configure Your Application

### Step 14: Update Environment Variables

**Create/Edit `.env` file in your project root:**

```properties
# SendGrid Configuration
SENDGRID_API_KEY=SG.your-actual-api-key-you-copied
SENDGRID_FROM_EMAIL=your-verified-email@gmail.com
```

**Example:**
```properties
SENDGRID_API_KEY=SG.AbCdEfGhIjKlMnOpQr.StUvWxYzAbCdEfGhIjKlMnOpQrStUv
SENDGRID_FROM_EMAIL=noreply@mycompany.com
```

⚠️ Make sure:
- No spaces around the `=` sign
- No quotes around values
- Use the EXACT email you verified in Step 13

---

## Part 6: Test Your Setup

### Step 15: Start Your Application

```powershell
# In PowerShell/Terminal
mvnw clean install
mvnw spring-boot:run
```

Wait for: `Started OmoiservespareApplication in X seconds`

### Step 16: Run Test Script

**In another PowerShell window:**

```powershell
./test-sendgrid-email.ps1
```

**When prompted, enter your email address:**
```
Enter your email: your-personal-email@gmail.com
```

### Step 17: Check Your Email

1. Check inbox for your personal email
2. Subject: **"Your Login OTP - Secure Authentication"**
3. Look for a beautifully formatted email with your OTP code

**If not in inbox:**
- Check Spam/Junk folder
- Wait 1-2 minutes
- Check SendGrid dashboard for delivery status

---

## Troubleshooting Common Issues

### ❌ "401 Unauthorized"
**Cause:** API key is incorrect or doesn't have permission

**Fix:**
1. Double-check API key is copied correctly (no spaces, no line breaks)
2. Create a new API key
3. Ensure "Mail Send" permission is enabled
4. Restart your application

### ❌ "403 Forbidden - Sender identity not verified"
**Cause:** You haven't verified your sender email

**Fix:**
1. Go to Settings → Sender Authentication
2. Complete Single Sender Verification (Steps 11-13)
3. Check email and click verification link
4. Use the exact email you verified in `SENDGRID_FROM_EMAIL`

### ❌ Emails going to spam
**Cause:** Sender reputation not established yet

**Fix:**
1. Complete Domain Authentication (takes 24-48 hours)
2. Avoid spam-trigger words in email content
3. Gradually increase sending volume
4. Monitor SendGrid reputation dashboard

### ❌ "Rate limit exceeded"
**Cause:** Free tier limit of 100 emails/day exceeded

**Fix:**
- Upgrade to paid plan
- Or wait until tomorrow (resets at midnight UTC)

---

## Visual Summary - What You'll See

### SendGrid Dashboard Home
```
╔════════════════════════════════════════════════════════╗
║  SendGrid Dashboard                            [User]  ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  Quick Stats:                                         ║
║  ├─ Emails Sent Today: 5                             ║
║  ├─ Delivered: 5 (100%)                              ║
║  └─ Bounced: 0                                       ║
║                                                        ║
║  [View Activity] [View Statistics]                   ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

### API Keys Page
```
╔════════════════════════════════════════════════════════╗
║  API Keys                        [Create API Key]     ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  API Key Name          Created        Action          ║
║  ─────────────────────────────────────────────────    ║
║  HRMS_OTP_Production   Jan 1, 2026   [Delete]        ║
║  MyApp_Test            Dec 20, 2025  [Delete]        ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

---

## Success! 🎉

You should now have:
- ✅ SendGrid account created
- ✅ API key created and copied
- ✅ Sender email verified
- ✅ Application configured
- ✅ Test email sent successfully

**Your OTP emails are now production-ready and will work with any email provider!**

---

## Quick Reference Card

**SendGrid URLs:**
- Dashboard: https://app.sendgrid.com/
- API Keys: https://app.sendgrid.com/settings/api_keys
- Sender Auth: https://app.sendgrid.com/settings/sender_auth
- Activity: https://app.sendgrid.com/activity
- Statistics: https://app.sendgrid.com/statistics

**Support:**
- Docs: https://docs.sendgrid.com/
- Support: https://support.sendgrid.com/
- Status: https://status.sendgrid.com/
