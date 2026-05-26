# Feedback Not Saving - Troubleshooting Steps

## Step 1: Test Backend API (5 minutes)

Run this command to test if your backend API works:

```powershell
.\test-feedback-api.ps1
```

**If this works:** Your backend is fine, the issue is in your frontend code.
**If this fails:** Check backend logs and database connection.

## Step 2: Use Debug Version of Frontend (10 minutes)

Replace your `Feedback.jsx` with `Feedback_Debug_Version.jsx`

This version includes:
- ✅ Console logging for every step
- ✅ Proper field names (`rating` and `comments`)
- ✅ Visual debug info at bottom of form
- ✅ Better error messages
- ✅ Validation before submission

## Step 3: Test in Browser

1. Open your app in browser
2. Open Developer Tools (F12)
3. Go to Console tab
4. Navigate to feedback page
5. Fill out the form:
   - Click on stars to select rating
   - Type feedback in text area
6. Click "Submit feedback"
7. Watch the console for debug output

## What to Look For

### In Browser Console:
```
=== FEEDBACK SUBMISSION DEBUG ===
Rating: 5
Comments: Test feedback
Token exists: true
Sending payload: {"rating":5,"comments":"Test feedback"}
Response status: 201
Response ok: true
Success! Feedback ID: 123
```

### In Backend Logs:
```
Feedback submission request from: user@example.com
Feedback submitted: id=123, userId=45, companyName=TestCo, rating=5
```

### In Database:
```sql
SELECT * FROM feedback ORDER BY created_at DESC LIMIT 1;
```

Should show your new feedback record.

## Common Problems & Solutions

### Problem 1: "Token exists: false"
**Solution:** You're not logged in. Login first, then try again.

### Problem 2: "Response status: 401"
**Solution:** Token is invalid or expired. Logout and login again.

### Problem 3: "Response status: 400"
**Solution:** Validation error. Check:
- Rating is between 1-5
- Comments is not empty
- Comments is less than 2000 characters

### Problem 4: "Network error: Failed to fetch"
**Solution:** Backend is not running. Start backend with `mvn spring-boot:run`

### Problem 5: "CORS policy" error
**Solution:** Frontend is not running on port 5173. Update CORS in FeedbackController.

## Quick Fix Checklist

- [ ] Backend is running (`mvn spring-boot:run`)
- [ ] Backend shows "Started OmoiservespareApplication"
- [ ] Frontend is running (usually `npm run dev`)
- [ ] You are logged in (check localStorage for "authToken")
- [ ] Using correct field names: `rating` and `comments` (not `comment` or `feedback`)
- [ ] Rating is a number 1-5 (not 0, not string)
- [ ] Comments is a string (not empty, not null)

## Files to Use

1. **Backend Test:** `test-feedback-api.ps1`
2. **Frontend Debug Version:** `Feedback_Debug_Version.jsx`
3. **Full Debug Guide:** `DEBUG_FEEDBACK_ISSUE.md`

## Still Not Working?

Share these details:
1. Console output from browser
2. Backend log output
3. Response status code
4. Error message

The debug version will show you exactly where it's failing!
