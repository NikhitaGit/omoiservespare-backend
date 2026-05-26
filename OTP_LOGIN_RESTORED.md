# ✅ OTP-BASED LOGIN SYSTEM RESTORED

## Status: WORKING

Your original OTP-based login system has been restored and is working!

## How It Works

### Step 1: User Login Request
**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "companyName": "Omoi Innovations",
  "email": "user@company.com",
  "phoneNumber": "+91-1234567890",
  "accountType": "PROFESSIONAL"
}
```

**What Happens:**
1. System validates company exists in HR system
2. System looks up employee by email in HR data
3. System validates employee is active
4. System creates/updates user in local database
5. System generates 6-digit OTP
6. System sends OTP to email (console for now)
7. Returns: `{ "success": true, "message": "OTP sent successfully to your email" }`

### Step 2: Verify OTP
**Endpoint:** `POST /api/auth/verify-otp`

**Headers:**
```
X-Device-Id: unique-device-id
```

**Request Body:**
```json
{
  "email": "user@company.com",
  "otp": "123456"
}
```

**What Happens:**
1. System validates OTP matches and not expired (5 min validity)
2. System generates JWT access token
3. System generates refresh token (stored in HTTP-only cookie)
4. Returns user info + access token

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@company.com",
  "companyName": "Omoi Innovations",
  "phoneNumber": "+91-1234567890",
  "accountType": "PROFESSIONAL"
}
```

## Testing

### Quick Test
```powershell
.\test-otp-login.ps1
```

This script will:
1. Send login request
2. Show OTP from backend console
3. Prompt you to enter OTP
4. Verify OTP and show JWT token

### Manual Test

**Step 1: Request OTP**
```powershell
$body = @{
    companyName = "Omoi Innovations"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $body -ContentType "application/json"
```

**Step 2: Check Backend Console**
Look for output like:
```
===========================================
🔐 OTP GENERATED FOR: nikita.a@omoikaneinnovations.com
📧 OTP CODE: 123456
⏰ EXPIRES AT: 2026-05-11T20:25:19.578
===========================================
```

**Step 3: Verify OTP**
```powershell
$otpBody = @{
    email = "nikita.a@omoikaneinnovations.com"
    otp = "123456"
} | ConvertTo-Json

$headers = @{ "X-Device-Id" = "test-device-123" }

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/verify-otp" -Method POST -Body $otpBody -ContentType "application/json" -Headers $headers
```

## HR System Integration

Your system fetches user data from HR API:

**Mock HR Data Available:**
- Company: "Omoi Innovations"
- Employees:
  - nikita.a@omoikaneinnovations.com
  - lata.b@omoikaneinnovations.com
  - And 8 more...

**HR Validation:**
- Company must exist in HR system
- Employee must exist in HR system
- Employee must be "active" status
- Employee data is synced to local database

## Email Configuration

Currently, OTP is only shown in console. To send real emails:

### Option 1: SendGrid (Recommended)

1. Get SendGrid API key from https://sendgrid.com
2. Update `application.properties`:
```properties
sendgrid.api.key=YOUR_SENDGRID_API_KEY
sendgrid.from.email=noreply@yourcompany.com
sendgrid.enabled=true
```

### Option 2: SMTP

Add to `application.properties`:
```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```

## Frontend Integration

### Login Flow

```javascript
// Step 1: Request OTP
const loginResponse = await fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    companyName: 'Omoi Innovations',
    email: 'user@company.com',
    phoneNumber: '+91-1234567890',
    accountType: 'PROFESSIONAL'
  })
});

// Step 2: Show OTP input form

// Step 3: Verify OTP
const verifyResponse = await fetch('http://localhost:8080/api/auth/verify-otp', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Device-Id': 'unique-device-id'
  },
  credentials: 'include', // Important for refresh token cookie
  body: JSON.stringify({
    email: 'user@company.com',
    otp: '123456'
  })
});

const data = await verifyResponse.json();
// Store access token
localStorage.setItem('accessToken', data.accessToken);
```

## Security Features

✅ **OTP Expiry:** 5 minutes
✅ **One-time use:** OTP deleted after verification
✅ **HR Validation:** Users must exist in HR system
✅ **Active Status:** Only active employees can login
✅ **JWT Tokens:** Secure token-based authentication
✅ **Refresh Tokens:** HTTP-only cookies for security
✅ **Device Tracking:** X-Device-Id header for device management

## Current Configuration

- **Backend:** http://localhost:8080
- **OTP Validity:** 5 minutes
- **Email Sending:** Disabled (console only)
- **SMS Sending:** Disabled (Twilio not configured)
- **HR Integration:** Mock data (10 employees)

## Next Steps

1. ✅ Backend running with OTP system
2. ⏳ Configure SendGrid for real email sending
3. ⏳ Update frontend to use OTP flow
4. ⏳ Connect to real HR API (currently using mock data)

---

**Your OTP-based login system is fully functional!** 🎉
