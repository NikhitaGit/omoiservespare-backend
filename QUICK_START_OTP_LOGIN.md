# 🚀 QUICK START - OTP Login

## Your System is Ready!

✅ Backend running on http://localhost:8080
✅ OTP-based login working
✅ HR system integration active

## Test Now (30 seconds)

```powershell
.\test-otp-login.ps1
```

Follow the prompts:
1. Script sends login request
2. Check backend console for OTP
3. Enter OTP when prompted
4. Get JWT token!

## Login Flow

```
User enters:
  - Company Name: "Omoi Innovations"
  - Email: "nikita.a@omoikaneinnovations.com"
  - Phone: "+91-9876543210"
       ↓
System validates with HR data
       ↓
OTP sent to email (console for now)
       ↓
User enters OTP
       ↓
System returns JWT token
       ↓
User is logged in!
```

## Available Test Users

From HR Mock Data:
- nikita.a@omoikaneinnovations.com
- lata.b@omoikaneinnovations.com
- john.doe@omoikaneinnovations.com
- jane.smith@omoikaneinnovations.com
- And 6 more...

All work with company: "Omoi Innovations"

## API Endpoints

### 1. Request OTP
```
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "companyName": "Omoi Innovations",
  "email": "user@company.com",
  "phoneNumber": "+91-1234567890",
  "accountType": "PROFESSIONAL"
}
```

### 2. Verify OTP
```
POST http://localhost:8080/api/auth/verify-otp
Content-Type: application/json
X-Device-Id: unique-device-id

{
  "email": "user@company.com",
  "otp": "123456"
}
```

## Where to Find OTP

Since email is not configured, OTP appears in backend console:

```
===========================================
🔐 OTP GENERATED FOR: user@company.com
📧 OTP CODE: 123456
⏰ EXPIRES AT: 2026-05-11T20:25:19
===========================================
```

## Enable Real Email Sending

Update `application.properties`:
```properties
sendgrid.api.key=YOUR_API_KEY
sendgrid.enabled=true
```

Get API key from: https://sendgrid.com

## Frontend Integration

Your frontend at http://localhost:5173 should:
1. Show login form with company name + email
2. Call `/api/auth/login`
3. Show OTP input form
4. Call `/api/auth/verify-otp`
5. Store JWT token
6. Redirect to dashboard

## Differences from Password Login

| Feature | OTP Login | Password Login |
|---------|-----------|----------------|
| Credentials | Company + Email | Email + Password |
| Verification | OTP via email | Password hash |
| HR Integration | ✅ Yes | ❌ No |
| User Creation | Auto from HR | Manual signup |
| Security | Time-limited OTP | Stored password |

## Your Current Setup

✅ **OTP System:** Working
✅ **HR Integration:** Mock data (10 users)
✅ **Email:** Console only (configure SendGrid)
✅ **SMS:** Disabled (configure Twilio)
✅ **JWT Tokens:** Working
✅ **Refresh Tokens:** Working

---

**Test it now with `.\test-otp-login.ps1`!** 🎉
