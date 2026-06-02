# 🔐 Vault Email Configuration Guide

## What Was Fixed

Your application was failing because:
1. ❌ Vault was not running
2. ❌ Email credentials needed to be stored in Vault
3. ❌ `vault.jwt.secret` and database credentials reference Vault (which is correct)

## Current Configuration

### ✅ application.properties now references Vault for email:

```properties
# Email credentials from Vault (NOT hardcoded)
spring.mail.username=${vault.mail.username}
spring.mail.password=${vault.mail.password}
mail.from=${vault.mail.from}

# Vault is ENABLED
spring.config.import=vault://
spring.cloud.vault.uri=http://localhost:8200
spring.cloud.vault.token=myroot
```

---

## 🚀 Quick Start (3 Steps)

### Step 1: Start Vault and Add Email Config

Run this script (it does everything):
```bash
.\start-vault-and-configure-email.ps1
```

This will:
- ✓ Start Vault server on port 8200
- ✓ Store email credentials in Vault
- ✓ Verify the configuration

**OR** If Vault is already running, just add email config:
```bash
.\add-email-to-vault.ps1
```

### Step 2: Start Your Backend

```bash
mvn spring-boot:run
```

### Step 3: Test OTP Email

```bash
.\test-email-sending.ps1
```

---

## 📋 What Gets Stored in Vault

### Email Credentials (Now Added):
```json
{
  "mail.username": "akshaykabbur8@gmail.com",
  "mail.password": "ahacuztuboepqydt",
  "mail.from": "akshaykabbur8@gmail.com"
}
```

### Other Secrets (You already have):
- `vault.db.url` - Database connection string
- `vault.db.username` - Database username
- `vault.db.password` - Database password
- `vault.jwt.secret` - JWT signing key
- `vault.cloudinary.*` - Cloudinary credentials

---

## 🔍 Verify Vault Data

### Check if Vault is Running:
```bash
curl http://localhost:8200/v1/sys/health
```

### View Stored Email Config:
```bash
curl -H "X-Vault-Token: myroot" http://localhost:8200/v1/secret/data/OmoiServespare
```

### Expected Response:
```json
{
  "data": {
    "data": {
      "mail.username": "akshaykabbur8@gmail.com",
      "mail.password": "ahacuztuboepqydt",
      "mail.from": "akshaykabbur8@gmail.com",
      "db.url": "...",
      "db.username": "...",
      ... (your other secrets)
    }
  }
}
```

---

## 🎯 How Email Flow Works Now

### 1. Application Starts:
```
Spring Boot → Reads application.properties
            → Sees ${vault.mail.username}
            → Connects to Vault (localhost:8200)
            → Fetches actual value from Vault
            → Injects into spring.mail.username
```

### 2. OTP Generation:
```
User Login → AuthService.generateOtp()
          → EmailService.sendOtpEmail(toEmail, otp)
          → Uses vault.mail.username for SMTP auth
          → Uses vault.mail.from as sender
          → Sends to user's email (toEmail parameter)
```

### 3. Email Addresses:
- **FROM (Sender)**: `vault.mail.from` = `akshaykabbur8@gmail.com`
- **TO (Recipient)**: User's email from login input
- **SMTP Auth**: Uses `vault.mail.username` and `vault.mail.password`

---

## 🛠️ Manual Vault Operations

### Start Vault Manually:
```bash
vault server -dev -dev-root-token-id=myroot
```
(Keep this terminal open)

### Add Email Config Manually:
```bash
$env:VAULT_ADDR="http://localhost:8200"
$env:VAULT_TOKEN="myroot"

curl -X POST -H "X-Vault-Token: myroot" -H "Content-Type: application/json" `
  -d '{"data":{"mail.username":"akshaykabbur8@gmail.com","mail.password":"ahacuztuboepqydt","mail.from":"akshaykabbur8@gmail.com"}}' `
  http://localhost:8200/v1/secret/data/OmoiServespare
```

---

## ⚠️ Important Notes

### Vault in Development Mode:
- Data is stored in memory (lost on restart)
- Not suitable for production
- Use file backend or production Vault for real deployment

### Gmail App Password:
Your current password (`ahacuztuboepqydt`) looks like a Gmail App Password ✅
- If emails still don't send, generate a new one at:
  https://myaccount.google.com/apppasswords

### Production Setup:
For production, consider:
1. Use Vault in production mode with persistent storage
2. Use TLS for Vault communication
3. Use proper authentication (not dev token)
4. Rotate secrets regularly

---

## 🐛 Troubleshooting

### Error: "Could not resolve placeholder 'vault.jwt.secret'"
**Cause**: Vault not running or missing secrets
**Solution**: Run `.\start-vault-and-configure-email.ps1`

### Error: "Failed to connect to localhost port 8200"
**Cause**: Vault server not started
**Solution**: Start Vault with `vault server -dev -dev-root-token-id=myroot`

### Error: "Authentication failed" (SMTP)
**Cause**: Wrong Gmail App Password
**Solution**: Generate new App Password at https://myaccount.google.com/apppasswords

### Emails Not Received:
1. Check backend logs for "OTP email sent successfully"
2. Check spam/junk folder
3. Verify Gmail App Password is correct
4. Check Gmail account security settings

---

## 📝 Next Steps

1. **Start Vault**: `.\start-vault-and-configure-email.ps1`
2. **Start Backend**: `mvn spring-boot:run`
3. **Test Email**: Try logging in with OTP
4. **Check Logs**: Look for "OTP email sent successfully"

---

## 🔗 Quick Command Reference

```bash
# Start everything
.\start-vault-and-configure-email.ps1
mvn spring-boot:run

# Test email
.\test-email-sending.ps1

# Check Vault
curl http://localhost:8200/v1/sys/health

# View secrets
curl -H "X-Vault-Token: myroot" http://localhost:8200/v1/secret/data/OmoiServespare
```

---

## ✅ Success Checklist

- [ ] Vault is running on port 8200
- [ ] Email credentials are stored in Vault
- [ ] Backend starts without "Could not resolve placeholder" errors
- [ ] OTP is generated and saved to database
- [ ] Email is sent (check logs for success message)
- [ ] OTP received in email inbox
