# Complete Feedback Solution - Step by Step

## The Real Problem

Your feedback **IS being saved** to the database! The issue is:

**Only PROFESSIONAL users can view the feedback list and export CSV/Excel.**

When a PERSONAL user tries to view feedback, they get **403 Forbidden**.

## Quick Fix (5 minutes)

### Step 1: Connect to PostgreSQL

```bash
psql -U postgres -d omoiservespare_db
```

Or use pgAdmin, DBeaver, or any PostgreSQL client.

### Step 2: Check Your Account Type

```sql
SELECT email, account_type, company_name FROM users;
```

### Step 3: Change to PROFESSIONAL

```sql
UPDATE users 
SET account_type = 'PROFESSIONAL' 
WHERE email = 'your@email.com';
```

Replace `'your@email.com'` with your actual email.

### Step 4: Verify Feedback Exists

```sql
SELECT * FROM feedback ORDER BY created_at DESC LIMIT 5;
```

You should see your submitted feedback!

### Step 5: Logout and Login Again

1. Logout from your app
2. Login again (to refresh the token with new account type)
3. Navigate to feedback admin page
4. You should now see all feedback!

## Detailed Explanation

### User Types

Your system has two account types:

1. **PERSONAL** - Regular users
   - ✅ Can submit feedback
   - ❌ Cannot view feedback list
   - ❌ Cannot export CSV/Excel
   - ❌ Cannot mark as reviewed

2. **PROFESSIONAL** - Admin users
   - ✅ Can submit feedback
   - ✅ Can view ALL company feedback
   - ✅ Can export CSV/Excel
   - ✅ Can mark feedback as reviewed

### Why This Design?

This is a **multi-tenant system**:
- Each company has its own feedback
- PROFESSIONAL users (admins) can manage their company's feedback
- PERSONAL users (regular employees) can only submit feedback

### Access Control in Code

From `FeedbackController.java`:

```java
@GetMapping
public ResponseEntity<Page<FeedbackDTO>> getFeedback(...) {
    // Check if user is PROFESSIONAL
    if (user.getAccountType() != AccountType.PROFESSIONAL) {
        log.warn("Access denied: user {} is not PROFESSIONAL", userEmail);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }
    // ... rest of code
}
```

## Complete Testing Guide

### Test 1: Verify Backend API

```powershell
.\verify-feedback-flow.ps1
```

Enter your email and password. This will:
1. Login
2. Submit test feedback
3. Try to retrieve feedback list
4. Try to export CSV/Excel

**Expected Results:**
- If PERSONAL: Submit works ✓, View fails with 403 ✗
- If PROFESSIONAL: Everything works ✓

### Test 2: Check Database

```sql
-- See all feedback
SELECT 
    f.id,
    u.email,
    u.account_type,
    f.rating,
    f.comments,
    f.status,
    f.created_at
FROM feedback f
JOIN users u ON f.user_id = u.id
ORDER BY f.created_at DESC;
```

### Test 3: Frontend Testing

1. **As PERSONAL User:**
   - Go to feedback form
   - Submit feedback
   - Check browser console - should show success
   - Try to view admin feedback page - should get 403 error

2. **As PROFESSIONAL User:**
   - Go to feedback form
   - Submit feedback
   - Go to admin feedback page
   - Should see all feedback
   - Download CSV/Excel should work

## Frontend Setup

### Option 1: Single Admin Dashboard (Current)

Use `FIXED_App_Feedback.jsx` - only accessible to PROFESSIONAL users.

**Route:**
```jsx
<Route path="/admin/feedback" element={<AppFeedback />} />
```

**Access Control:**
```jsx
// In your route guard or component
const user = getCurrentUser();
if (user.accountType !== 'PROFESSIONAL') {
  navigate('/unauthorized');
}
```

### Option 2: Separate User and Admin Views

**User View** - All users can see their own feedback:
```jsx
<Route path="/my-feedback" element={<MyFeedbackList />} />
```

**Admin View** - Only PROFESSIONAL users:
```jsx
<Route path="/admin/feedback" element={<AdminFeedbackDashboard />} />
```

## SQL Scripts Provided

1. **fix-user-account-type.sql** - Change user to PROFESSIONAL
2. Run queries to verify feedback exists

## PowerShell Scripts Provided

1. **verify-feedback-flow.ps1** - Complete end-to-end test
2. **test-feedback-api.ps1** - Simple API test

## Common Issues

### Issue 1: "No feedback showing in admin page"

**Cause:** You're logged in as PERSONAL user

**Solution:** 
```sql
UPDATE users SET account_type = 'PROFESSIONAL' WHERE email = 'your@email.com';
```
Then logout and login again.

### Issue 2: "403 Forbidden when viewing feedback"

**Cause:** Same as Issue 1

**Solution:** Change account type to PROFESSIONAL

### Issue 3: "Feedback submitted but not in database"

**Cause:** Submission actually failed (check console)

**Solution:** 
- Check browser console for errors
- Check backend logs
- Verify token is valid
- Run `.\verify-feedback-flow.ps1` to test

### Issue 4: "CSV/Excel download not working"

**Cause:** You're not PROFESSIONAL user

**Solution:** Change account type to PROFESSIONAL

## Verification Checklist

- [ ] Backend is running on port 8080
- [ ] User account exists in database
- [ ] User account_type is PROFESSIONAL (for viewing)
- [ ] Feedback exists in database (check with SQL)
- [ ] User is logged in (token in localStorage)
- [ ] Token is valid (not expired)
- [ ] Frontend is calling correct API endpoints
- [ ] No CORS errors in browser console

## Final Steps

1. Run SQL script to change your account to PROFESSIONAL:
   ```sql
   UPDATE users SET account_type = 'PROFESSIONAL' WHERE email = 'your@email.com';
   ```

2. Logout and login again in your app

3. Navigate to admin feedback page

4. You should now see all feedback!

5. CSV/Excel export should work!

## Summary

Your feedback system is working correctly! The "issue" is actually a **security feature**:
- Regular users (PERSONAL) can submit but not view
- Admin users (PROFESSIONAL) can view and manage

Change your account to PROFESSIONAL to access the admin features.
