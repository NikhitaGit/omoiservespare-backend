# Quick Fix for Feedback 401 Error

## The Problem
Your logs show:
- ✅ Feedback submission works (you see `Feedback submitted: id=4`)
- ❌ Feedback retrieval fails with 401 Unauthorized errors

## The Solution (3 Steps)

### Step 1: Test with the HTML Test Page (Fastest Way)

Open `test-feedback-frontend.html` in your browser:

```powershell
# Just double-click the file or:
start test-feedback-frontend.html
```

This standalone page will:
1. Let you login and get a token
2. Test feedback submission
3. Test feedback retrieval
4. Test CSV/Excel downloads
5. Show you exactly what's working and what's not

### Step 2: Run the Diagnostic Script

```powershell
.\diagnose-feedback-token.ps1
```

Follow the prompts to:
- Test your backend
- Get a valid token
- Test all feedback endpoints

### Step 3: Update Your React Component

Replace your current `App_Feedback.jsx` with the fixed version:

```powershell
copy App_Feedback_COMPLETE_FIX.jsx <your-frontend-path>\App_Feedback.jsx
```

## What Was Wrong?

The frontend wasn't sending the JWT token in the Authorization header when fetching feedback. The new component:

1. **Auto-detects tokens** from multiple localStorage keys
2. **Shows debug info** so you can see what's happening
3. **Better error messages** to help troubleshoot
4. **Proper token handling** in all API calls

## Quick Test

1. **Open test-feedback-frontend.html** in browser
2. **Login** with: nikita.a@omoikaneinnovations.com (PROFESSIONAL)
3. **Submit feedback** (should work)
4. **Load feedback** (should now work!)
5. **Download CSV/Excel** (should now work!)

## If It Still Doesn't Work

Check these:

1. **Backend running?**
   ```powershell
   # Check if port 8080 is listening
   netstat -an | findstr :8080
   ```

2. **Token stored?**
   - Open browser console (F12)
   - Type: `localStorage.getItem("token")`
   - Should see a long string starting with "eyJ"

3. **User is PROFESSIONAL?**
   - Only PROFESSIONAL users can view feedback
   - Regular users can only submit feedback

4. **Token expired?**
   - Logout and login again to get a fresh token

## Files Created

- `test-feedback-frontend.html` - Standalone test page
- `App_Feedback_COMPLETE_FIX.jsx` - Fixed React component
- `diagnose-feedback-token.ps1` - Diagnostic script
- `FEEDBACK_401_FIX_GUIDE.md` - Detailed guide

## Next Steps

Once the test page works:
1. Copy the token handling logic to your actual frontend
2. Make sure your login component stores the token
3. Make sure your feedback component reads the token

The key is this line after successful login:
```javascript
localStorage.setItem("token", data.token);
```

And this line when making API calls:
```javascript
headers: {
  "Authorization": `Bearer ${localStorage.getItem("token")}`
}
```

That's it! 🎉
