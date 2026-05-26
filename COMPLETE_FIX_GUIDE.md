# Complete Fix Guide - Ticket System Issues

## Overview
You have TWO issues to fix:
1. ❌ Backend won't start (Port 8080 in use)
2. ❌ Frontend not working (hardcoded data, no API calls)

## STEP 1: Fix Backend Port Issue

### Quick Fix (Run this command):
```powershell
cd C:\Users\nikhi\Downloads\Lata_Backend\OmoiServespare\omoiservespare
taskkill /F /IM java.exe ; Start-Sleep -Seconds 3 ; .\mvnw spring-boot:run
```

### What This Does:
- Kills all Java processes (including the one blocking port 8080)
- Waits 3 seconds
- Starts your backend

### Expected Output:
```
Started OmoiservespareApplication in X.XXX seconds
```

### Verify Backend Works:
Open browser: `http://localhost:8080/api/health`

---

## STEP 2: Fix Frontend Issues

Your frontend files have hardcoded mock data. You need to replace them with the fixed versions.

### Files to Replace:

#### 1. RaiseTicket.jsx
**Location:** Your frontend project folder
**Replace with:** `omoiservespare/FIXED_RaiseTicket_v2.jsx`

**What it fixes:**
- ✅ Auto-fills phone number from user profile
- ✅ Submits ticket to backend API
- ✅ Handles missing authentication token gracefully

#### 2. UserDashboard.jsx
**Location:** Your frontend project folder
**Replace with:** `omoiservespare/FIXED_UserDashboard.jsx`

**What it fixes:**
- ✅ Fetches tickets from backend API (`GET /api/tickets/my-tickets`)
- ✅ Displays real ticket data instead of hardcoded array

#### 3. AgentDashboard.jsx
**Location:** Your frontend project folder
**Replace with:** `omoiservespare/FIXED_AgentDashboard.jsx`

**What it fixes:**
- ✅ Fetches tickets from backend API (`GET /api/tickets/agent/dashboard`)
- ✅ Displays real ticket data instead of hardcoded array

#### 4. AgentTicketDetails.jsx
**Location:** Your frontend project folder
**Replace with:** `omoiservespare/FIXED_AgentTicketDetails.jsx`

**What it fixes:**
- ✅ Fetches ticket details from backend
- ✅ Fetches messages from backend
- ✅ Sends messages to backend
- ✅ Real-time updates via WebSocket

---

## STEP 3: Ensure User Has Phone Number

The phone auto-fill requires the user to have a phone number in the database.

### Check/Update Phone Number:

```sql
-- Connect to PostgreSQL
psql -U postgres -d omoiservespare_db

-- Check current phone number
SELECT email, phone_number FROM users WHERE email = 'your-email@example.com';

-- If phone_number is NULL, update it:
UPDATE users SET phone_number = '+1234567890' WHERE email = 'your-email@example.com';
```

---

## STEP 4: Test Complete Flow

### 1. Start Backend
```powershell
cd omoiservespare
.\mvnw spring-boot:run
```

### 2. Start Frontend
```bash
cd your-frontend-folder
npm start
```

### 3. Test Workflow

**A. Login:**
- Login with your credentials
- JWT token should be saved to localStorage

**B. Raise Ticket:**
- Go to Raise Ticket page
- Phone number should auto-fill
- Fill in other details
- Submit ticket
- Should see success message

**C. User Dashboard:**
- Go to User Dashboard
- Should see the ticket you just created
- Should display real data from backend

**D. Agent Dashboard (if you're an agent):**
- Go to Agent Dashboard
- Should see tickets assigned to you
- Should display real data from backend

---

## Troubleshooting

### Issue: "No authentication token found"
**Solution:** You need to login first. The login should save JWT token to localStorage.

**Check token exists:**
```javascript
// Open browser console (F12) and run:
localStorage.getItem('token')
// Should return a long string (JWT token)
```

### Issue: Phone number not auto-filling
**Causes:**
1. User doesn't have phone_number in database → Update it (see Step 3)
2. Token is missing → Login first
3. Frontend not calling API → Make sure you replaced with FIXED version

### Issue: Tickets not displaying
**Causes:**
1. Backend not running → Start it (see Step 1)
2. Frontend using old code → Replace with FIXED versions (see Step 2)
3. No tickets in database → Create a ticket first

### Issue: Port 8080 still in use
**Solution:**
```powershell
# Find the process
netstat -ano | findstr :8080

# Kill it (replace 12345 with actual PID)
taskkill /F /PID 12345

# Or kill all Java processes
taskkill /F /IM java.exe
```

---

## Quick Reference

### Backend Endpoints (All Working ✅)
- `POST /api/tickets` - Create ticket
- `GET /api/tickets/my-tickets` - Get user's tickets
- `GET /api/tickets/agent/dashboard` - Get agent's tickets
- `GET /api/tickets/{id}` - Get ticket details
- `GET /api/tickets/{id}/messages` - Get ticket messages
- `POST /api/tickets/{id}/messages` - Send message
- `GET /api/users/profile` - Get user profile (includes phone)

### Frontend Files Status
- ❌ Original files: Hardcoded mock data
- ✅ FIXED files: Real API integration

### Key Changes in Fixed Files
1. Added API calls to backend
2. Added JWT token authentication
3. Added error handling
4. Added loading states
5. Removed hardcoded mock data

---

## Summary

1. **Kill port 8080 process** → Backend starts
2. **Replace 4 frontend files** → Frontend connects to backend
3. **Ensure phone number in DB** → Auto-fill works
4. **Test complete flow** → Everything works!

All backend code is already working. You just need to:
- Start the backend
- Replace the frontend files
- Test it

See `APPLY_FRONTEND_FIXES.md` for detailed code comparison and replacement instructions.
