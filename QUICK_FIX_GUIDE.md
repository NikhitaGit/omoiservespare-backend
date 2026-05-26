# Quick Fix Guide - 5 Minutes

## The Problem
Your frontend uses hardcoded mock data instead of fetching from the backend.

## The Solution
I've created 4 fixed files with full backend integration.

## Apply Fix in 3 Steps

### Step 1: Install Axios (30 seconds)
```bash
cd your-frontend-project
npm install axios
```

### Step 2: Replace Files (2 minutes)

Copy these files to your frontend project:

```
omoiservespare/FIXED_RaiseTicket.jsx       → your-frontend/src/pages/RaiseTicket.jsx
omoiservespare/FIXED_UserDashboard.jsx     → your-frontend/src/pages/UserDashboard.jsx
omoiservespare/FIXED_AgentDashboard.jsx    → your-frontend/src/pages/AgentDashboard.jsx
omoiservespare/FIXED_AgentTicketDetails.jsx → your-frontend/src/pages/AgentTicketDetails.jsx
```

**Keep your CSS files unchanged!**

### Step 3: Test (2 minutes)

```powershell
# Terminal 1: Start Backend
cd omoiservespare
mvnw spring-boot:run

# Terminal 2: Start Frontend
cd your-frontend-project
npm run dev
```

Then test:
1. Login
2. Go to Raise Ticket → Phone should auto-fill ✓
3. Create a ticket → Should save to backend ✓
4. Go to User Dashboard → Should show real tickets ✓
5. Go to Agent Dashboard → Should show real data ✓

## What Changed

### Before:
- ❌ Hardcoded data: `const [tickets] = useState([{...}])`
- ❌ No API calls
- ❌ Phone field empty

### After:
- ✅ Real data: `useEffect(() => { fetch from backend })`
- ✅ Full API integration
- ✅ Phone auto-filled

## Files Created

| File | What It Does |
|------|--------------|
| FIXED_RaiseTicket.jsx | Phone auto-fill + API submission |
| FIXED_UserDashboard.jsx | Fetches real tickets |
| FIXED_AgentDashboard.jsx | Fetches real dashboard |
| FIXED_AgentTicketDetails.jsx | Ticket details + messaging |

## Need More Details?

Read these files:
- `FRONTEND_FIX_SUMMARY.md` - Overview
- `APPLY_FRONTEND_FIXES.md` - Detailed guide
- `BEFORE_AFTER_COMPARISON.md` - Code comparison

## Troubleshooting

**Phone not auto-filling?**
- Check user has phone in database: `SELECT phone_number FROM users WHERE email = 'your-email'`

**Tickets not showing?**
- Check backend is running on port 8080
- Check browser console for errors
- Check token exists: `localStorage.getItem('token')`

**401 Unauthorized?**
- Clear localStorage and login again

That's it! Your helpdesk system will work perfectly.
