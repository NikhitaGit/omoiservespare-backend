# Apply Frontend Fixes - Complete Guide

## Issues Found in Your Frontend Files

### ❌ Problem 1: Hardcoded Mock Data
Your files use static arrays instead of fetching from the backend API.

### ❌ Problem 2: No Phone Auto-Fill
RaiseTicket.jsx doesn't fetch user profile to auto-populate phone number.

### ❌ Problem 3: No API Integration
None of the files make actual HTTP requests to the backend.

## Fixed Files Created

I've created 4 fixed files with full backend integration:

1. **FIXED_RaiseTicket.jsx** - Phone auto-fill + API submission
2. **FIXED_UserDashboard.jsx** - Fetches real tickets from backend
3. **FIXED_AgentDashboard.jsx** - Fetches real agent dashboard data
4. **FIXED_AgentTicketDetails.jsx** - Fetches ticket details + messaging

## How to Apply the Fixes

### Step 1: Install Axios (if not already installed)
```bash
cd your-frontend-project
npm install axios
```

### Step 2: Replace Your Files

Copy the content from the FIXED files and replace your existing files:

**File Mapping:**
```
FIXED_RaiseTicket.jsx       → Replace your RaiseTicket.jsx
FIXED_UserDashboard.jsx     → Replace your UserDashboard.jsx
FIXED_AgentDashboard.jsx    → Replace your AgentDashboard.jsx
FIXED_AgentTicketDetails.jsx → Replace your AgentTicketDetails.jsx
```

### Step 3: Keep Your CSS Files
Your CSS files are perfect! No changes needed:
- UserDashboard.css ✓
- RaiseTicket.css ✓
- AgentDashboard.css ✓
- AgentTicketDetails.css ✓

### Step 4: Test the Application

1. **Start Backend**
```powershell
cd omoiservespare
mvnw spring-boot:run
```

2. **Start Frontend**
```bash
cd your-frontend-project
npm run dev
```

3. **Test Each Feature**
- Login to your app
- Go to Raise Ticket page → Phone should auto-fill
- Create a ticket → Should submit to backend
- Go to User Dashboard → Should show real tickets
- Go to Agent Dashboard → Should show real data

## What Changed in Each File

### FIXED_RaiseTicket.jsx

**Added:**
- `useEffect` to fetch user profile on mount
- Auto-fills `userPhone` from `response.data.phoneNumber`
- `axios.post` to submit ticket to backend
- Loading states and error handling
- Success message with ticket number
- Proper category mapping (TECHNICAL, BILLING, etc.)

**Key Changes:**
```javascript
// OLD: Static phone field
userPhone: ''

// NEW: Auto-filled from API
useEffect(() => {
  const response = await axios.get('http://localhost:8080/api/me');
  setFormData(prev => ({
    ...prev,
    userPhone: response.data.phoneNumber
  }));
}, []);
```

### FIXED_UserDashboard.jsx

**Added:**
- `useEffect` to fetch tickets on mount
- `axios.get` to `/api/tickets/my-tickets`
- Loading and error states
- Real-time ticket data display
- Proper status mapping (OPEN, IN_PROGRESS, etc.)

**Key Changes:**
```javascript
// OLD: Hardcoded tickets
const [tickets] = useState([{ id: 101, ... }]);

// NEW: Fetched from backend
useEffect(() => {
  const response = await axios.get('http://localhost:8080/api/tickets/my-tickets');
  setTickets(response.data);
}, []);
```

### FIXED_AgentDashboard.jsx

**Added:**
- `useEffect` to fetch dashboard on mount
- `axios.get` to `/api/tickets/agent/dashboard`
- Statistics from backend (openCount, inProgressCount, etc.)
- Assign ticket functionality
- Combined view of assigned and unassigned tickets

**Key Changes:**
```javascript
// OLD: Hardcoded tickets
const [tickets] = useState([{ id: 201, ... }]);

// NEW: Fetched from backend
useEffect(() => {
  const response = await axios.get('http://localhost:8080/api/tickets/agent/dashboard');
  setDashboard(response.data);
}, []);
```

### FIXED_AgentTicketDetails.jsx

**Added:**
- `useEffect` to fetch ticket details
- `axios.get` to `/api/tickets/{ticketId}`
- Send message functionality with `axios.post`
- Update status functionality with `axios.patch`
- Real-time message display

**Key Changes:**
```javascript
// OLD: Static messages
const [messages, setMessages] = useState([]);

// NEW: Fetched from backend
useEffect(() => {
  const response = await axios.get(`http://localhost:8080/api/tickets/${ticketId}`);
  setMessages(response.data.messages);
}, [ticketId]);
```

## Testing Checklist

After applying the fixes, test these scenarios:

### Test 1: Phone Auto-Fill
- [ ] Login to the app
- [ ] Navigate to Raise Ticket page
- [ ] Phone number field should be auto-filled
- [ ] Check browser console for "Phone number auto-filled" message

### Test 2: Ticket Creation
- [ ] Fill in all fields in Raise Ticket form
- [ ] Click Submit
- [ ] Should see success message with ticket number
- [ ] Should redirect to dashboard after 2 seconds

### Test 3: User Dashboard
- [ ] Navigate to User Dashboard
- [ ] Should see all your tickets
- [ ] Statistics should show correct counts
- [ ] Filter should work (Open, In Progress, etc.)

### Test 4: Agent Dashboard
- [ ] Login as agent
- [ ] Navigate to Agent Dashboard
- [ ] Should see assigned and unassigned tickets
- [ ] Statistics should show correct counts
- [ ] Should be able to assign tickets

### Test 5: Ticket Details
- [ ] Click "View" on any ticket
- [ ] Should see ticket details
- [ ] Should see message history
- [ ] Should be able to send messages
- [ ] Should be able to change status

## Troubleshooting

### Issue: Phone number not auto-filling

**Check:**
1. User has phone number in database
```sql
SELECT phone_number FROM users WHERE email = 'your-email@example.com';
```

2. Browser console shows the API call
```
User profile loaded: { phoneNumber: "+1234567890", ... }
Phone number auto-filled: +1234567890
```

3. Token is valid
```javascript
console.log('Token:', localStorage.getItem('token'));
```

### Issue: Tickets not showing

**Check:**
1. Backend is running on port 8080
2. Browser console shows the API call
```
Fetching user tickets...
Tickets loaded: [...]
```

3. No CORS errors in console
4. Token is being sent in Authorization header

### Issue: 401 Unauthorized

**Fix:**
1. Clear localStorage: `localStorage.clear()`
2. Login again
3. Check token expiration

### Issue: 403 Forbidden (Agent Dashboard)

**Fix:**
User doesn't have AGENT role. Update in database:
```sql
UPDATE users SET account_type = 'AGENT' WHERE email = 'your-email@example.com';
```

## Backend Endpoints Used

The fixed files use these backend endpoints:

| Endpoint | Method | Purpose | File |
|----------|--------|---------|------|
| `/api/me` | GET | Get user profile | RaiseTicket.jsx |
| `/api/tickets` | POST | Create ticket | RaiseTicket.jsx |
| `/api/tickets/my-tickets` | GET | Get user tickets | UserDashboard.jsx |
| `/api/tickets/agent/dashboard` | GET | Get agent dashboard | AgentDashboard.jsx |
| `/api/tickets/{id}` | GET | Get ticket details | AgentTicketDetails.jsx |
| `/api/tickets/{id}/messages` | POST | Send message | AgentTicketDetails.jsx |
| `/api/tickets/{id}/status` | PATCH | Update status | AgentTicketDetails.jsx |
| `/api/tickets/{id}/assign` | POST | Assign ticket | AgentDashboard.jsx |

## Summary of Changes

| File | Lines Changed | Key Addition |
|------|---------------|--------------|
| RaiseTicket.jsx | ~50 lines | Phone auto-fill + API submission |
| UserDashboard.jsx | ~40 lines | Fetch tickets from backend |
| AgentDashboard.jsx | ~45 lines | Fetch dashboard from backend |
| AgentTicketDetails.jsx | ~60 lines | Fetch details + messaging |

## Next Steps

1. ✅ Copy the FIXED files to your frontend project
2. ✅ Test backend first: `.\test-ticket-backend.ps1`
3. ✅ Update user phone numbers in database if needed
4. ✅ Start both backend and frontend
5. ✅ Test all features using the checklist above

Your helpdesk system will be fully functional after applying these fixes!
