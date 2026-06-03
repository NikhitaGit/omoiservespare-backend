# 📧 Email Fix - Quick Card

## ✅ App is LIVE but emails not sending

**URL**: https://omoiservespare-backend.onrender.com

---

## 🔧 Fix in 3 Steps

### 1. Get Gmail App Password
1. Go to: https://myaccount.google.com/security
2. Enable 2-Step Verification
3. Create App Password → Mail → Other
4. Copy 16-character password

### 2. Set on Render
Dashboard → Service → Environment → Add:
```
SENDER_USERNAME=your_email@gmail.com
SENDER_PASSWORD=the_16_char_password
FROM_MAIL=your_email@gmail.com
```

### 3. Test
```powershell
.\test-email-render.ps1
```

---

## ✅ Expected Logs

When working, Render logs show:
```
📧 EMAIL SERVICE: OTP Send Initiated
✅ EMAIL SENT SUCCESSFULLY
```

---

## 🆘 Still Not Working?

Check: `EMAIL_NOT_WORKING_FIX.md`

Common issues:
- App password not generated
- 2-Step not enabled
- Typo in env var names
- Used regular password instead of app password

---

**The app is deployed! Just fix email env vars!** 🎉
