# 🎯 Quick Start Guide

## One Command to Start Everything

```bash
.\START_BACKEND_WITH_EMAIL.ps1
```

That's it! This command will:
1. ✅ Start Vault (if not running)
2. ✅ Add email configuration to Vault
3. ✅ Start your backend application

---

## What Email Addresses Are Used?

### Sender (FROM):
- **Email**: `akshaykabbur8@gmail.com`
- **Stored in**: Vault as `vault.mail.from`
- **All OTPs are sent from this address**

### Recipient (TO):
- **Email**: User's input during login
- **Example**: User enters `customer@example.com` → OTP sent there

---

## Test OTP Email

After backend starts, test with:

```bash
curl -X POST http://localhost:8080/api/auth/generate-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"your-email@example.com","userType":"USER"}'
```

Check backend logs for:
```
✓ OTP email sent successfully to your-email@example.com
```

---

## Need Help?

- **Full Guide**: Read `VAULT_EMAIL_SETUP_GUIDE.md`
- **Troubleshooting**: Check `✅_EMAIL_FIX_COMPLETE.md`
- **Configuration Details**: See `EMAIL_CONFIGURATION_COMPLETE.md`

---

## Common Questions

**Q: Do I need an email template?**
A: No! Plain text is perfect for OTP emails.

**Q: Where are email credentials stored?**
A: In HashiCorp Vault (secure, not hardcoded).

**Q: What if Vault stops?**
A: Just run `.\START_BACKEND_WITH_EMAIL.ps1` again.

**Q: How to change email address?**
A: Run `.\add-email-to-vault.ps1` with new credentials.

---

## ✅ Success Checklist

- [ ] Run `.\START_BACKEND_WITH_EMAIL.ps1`
- [ ] Backend starts without errors
- [ ] Test OTP generation
- [ ] Receive OTP email
- [ ] Done! 🎉
