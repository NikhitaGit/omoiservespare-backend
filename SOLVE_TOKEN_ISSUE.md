# Solve "No Authentication Token Found" Issue

## What You're Seeing

Your Raise Ticket page shows:
```
❌ No authentication token found
Redirecting to login page...
```

## Root Cause

You haven't logged in yet, so there's no JWT token in localStorage. The frontend needs this token to:
1. Fetch your user profile (to auto-fill phone number)
2. Submit tickets to the backend
3. Access any protected API endpoints

## Solution: Login First

### Step 1: Ensure Backend is Running

Open a NEW PowerShell window and run:

```powershell
cd C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare
taskkill /F /IM java.exe
Start-Sleep -Seconds 3
.\mvnw spring-boot:run
```

Wait until you see:
```
Started OmoiservespareApplication in X.XXX seconds
```

### Step 2: Login to Your Application

1. Go to your login page: `http://localhost:5173/login` (or wherever your login is)
2. Enter your credentials
3. Click Login

### Step 3: Verify Token is Saved

After successful login, open browser console (F12) and run:

```javascript
localStorage.getItem('token')
```

You should see a long string (JWT token). If you see `null`, your login component isn't saving the token correctly.

### Step 4: Go Back to Raise Ticket

After logging in, navigate to Raise Ticket page again. The error should be gone and:
- Phone number should auto-fill
- You can submit tickets

## If Login Doesn't Save Token

Your login component needs to save the token after successful login. It should look like this:

```javascript
// After successful login API call
const response = await axios.post('http://localhost:8080/api/auth/login', {
  email: email,
  password: password
});

// Save token to localStorage
localStorage.setItem('token', response.data.token);

// Redirect to dashboard or home
navigate('/dashboard');
```

## Quick Test: Manual Token Setup

If you want to test quickly without fixing login, you can manually set a token:

1. Login via API directly (use Postman or curl):
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your-email@example.com","password":"your-password"}'
```

2. Copy the token from response
3. Open browser console (F12) and run:
```javascript
localStorage.setItem('token', 'paste-your-token-here');
```

4. Refresh the Raise Ticket page

## Verify Complete Flow

Once logged in:

1. ✅ Go to Raise Ticket page
2. ✅ Phone number should auto-fill
3. ✅ Fill in title, description, category, priority
4. ✅ Click Submit Ticket
5. ✅ Should see success message
6. ✅ Go to User Dashboard - ticket should appear
7. ✅ Go to Agent Dashboard (if you're an agent) - ticket should appear

## Troubleshooting

### Issue: Backend not responding
**Check if backend is running:**
```powershell
curl http://localhost:8080/api/health
```

If it fails, backend isn't running. Start it (see Step 1).

### Issue: Login fails with 401
**Possible causes:**
- Wrong email/password
- User doesn't exist in database
- Backend not running

**Solution:** Check your database:
```sql
SELECT email, password FROM users WHERE email = 'your-email@example.com';
```

### Issue: Token exists but still shows error
**Check token format:**
```javascript
// Should start with "eyJ"
console.log(localStorage.getItem('token'));
```

If token doesn't start with "eyJ", it's not a valid JWT token.

### Issue: Phone number not auto-filling even after login
**Check if user has phone number in database:**
```sql
SELECT email, phone_number FROM users WHERE email = 'your-email@example.com';
```

If `phone_number` is NULL:
```sql
UPDATE users SET phone_number = '+1234567890' WHERE email = 'your-email@example.com';
```

## Summary

The error you're seeing is EXPECTED behavior when not logged in. The fixed frontend (v2) handles this gracefully by showing the error and redirect button.

To fix:
1. Start backend
2. Login to your application
3. Token gets saved to localStorage
4. Raise Ticket page works correctly

Your frontend is already using the FIXED version - you just need to login first!
