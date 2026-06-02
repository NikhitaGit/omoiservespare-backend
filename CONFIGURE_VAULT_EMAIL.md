# 🔧 Configure HashiCorp Vault Email Credentials

## The Problem

Your application is configured to read email credentials from HashiCorp Vault, but Vault doesn't have these secrets configured:
- `vault.mail.username` ❌
- `vault.mail.password` ❌
- `vault.mail.from` ❌

## Solution: Add Secrets to Vault

### Step 1: Access Your Vault

Your Vault is running at: `http://localhost:8200`
Token: `myroot` (from application.properties)

### Step 2: Add Email Secrets

Use Vault CLI or UI to add these secrets to `secret/OmoiServespare`:

```bash
# Using Vault CLI:
vault kv put secret/OmoiServespare \
  mail.username=your-gmail@gmail.com \
  mail.password=your-gmail-app-password \
  mail.from=your-gmail@gmail.com
```

### Step 3: Verify Secrets

```bash
vault kv get secret/OmoiServespare
```

You should see:
```
====== Data ======
Key              Value
---              -----
mail.username    your-gmail@gmail.com
mail.password    xxxx-xxxx-xxxx-xxxx
mail.from        your-gmail@gmail.com
```

### Step 4: Restart Backend

```powershell
# Stop backend (Ctrl+C)
# Start again
mvn spring-boot:run
```

### Step 5: Test OTP

```powershell
.\test-otp-generation.ps1
```

## Alternative: Temporary Direct Configuration

If you don't have Vault set up yet or want to test quickly, you can temporarily use direct Gmail configuration:

### TEMPORARY FIX (For Testing Only):

1. Open `src/main/resources/application.properties`

2. Find these lines:
```properties
spring.mail.username=${vault.mail.username}
spring.mail.password=${vault.mail.password}
mail.from=${vault.mail.from}
```

3. **TEMPORARILY** replace with your actual Gmail credentials:
```properties
# TEMPORARY - FOR TESTING ONLY
spring.mail.username=lata.b@omoikaneinnovations.com
spring.mail.password=your-gmail-app-password-here
mail.from=lata.b@omoikaneinnovations.com
```

4. Restart backend

5. Test OTP generation

6. **IMPORTANT**: Revert these changes before committing to Git or deploying!

## Gmail App Password Setup

If you haven't created a Gmail App Password:

1. Go to https://myaccount.google.com/security
2. Enable 2-Factor Authentication
3. Go to App Passwords
4. Generate password for "Mail"
5. Use this 16-character password (not your regular Gmail password)

## Production Deployment

For Render deployment, you'll set these as environment variables:
- `VAULT_MAIL_USERNAME=your-gmail@gmail.com`
- `VAULT_MAIL_PASSWORD=your-app-password`
- `VAULT_MAIL_FROM=your-gmail@gmail.com`

---

**Choose one approach**: Either configure Vault properly OR use temporary direct configuration for testing.
