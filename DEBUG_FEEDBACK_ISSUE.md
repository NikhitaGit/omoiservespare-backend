# Debug Feedback Not Saving Issue

## Quick Diagnosis Steps

### Step 1: Test Backend API Directly

Run this PowerShell script to test if the backend API works:

```powershell
.\test-feedback-api.ps1
```

This will:
1. Login and get auth token
2. Submit test feedback
3. Show if it was saved

### Step 2: Check Browser Console

Open your browser's Developer Tools (F12) and check:

1. **Network Tab**: Look for the POST request to `/api/feedback`
   - Check the request payload
   - Check the response status code
   - Check for any errors

2. **Console Tab**: Look for JavaScript errors

### Step 3: Check Backend Logs

Look at your Spring Boot console for:
- "Feedback submission request from: [email]"
- "Feedback submitted: id=X, userId=Y..."
- Any error messages

## Common Issues & Fixes

### Issue 1: Authentication Token Missing

**Symptom:** 401 Unauthorized error

**Fix:** Make sure your login stores the token correctly:

```javascript
// After successful login:
localStorage.setItem("authToken", response.token);

// Check if token exists:
const token = localStorage.getItem("authToken");
console.log("Token:", token);
```

### Issue 2: Wrong Field Names

**Backend expects:**
```json
{
  "rating": 5,
  "comments": "Your feedback here"
}
```

**Check your frontend sends exactly this format!**

### Issue 3: CORS Error

**Symptom:** "CORS policy" error in browser console

**Fix:** Backend already has CORS enabled for `http://localhost:5173`

If your frontend runs on a different port, update FeedbackController:

```java
@CrossOrigin(origins = "http://localhost:YOUR_PORT")
```

### Issue 4: User Not Found

**Symptom:** "User not found" error

**Fix:** Make sure you're logged in with a valid user account

### Issue 5: Validation Errors

**Symptom:** 400 Bad Request with validation messages

**Possible causes:**
- Rating not between 1-5
- Comments empty or > 2000 characters
- Missing required fields

## Manual API Test with cURL

Test the API directly:

```bash
# 1. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpassword"}'

# Copy the token from response

# 2. Submit feedback
curl -X POST http://localhost:8080/api/feedback \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"rating":5,"comments":"Test feedback"}'
```

## Check Database Directly

Connect to PostgreSQL and run:

```sql
-- Check if feedback table exists
\dt feedback

-- Check feedback records
SELECT * FROM feedback ORDER BY created_at DESC LIMIT 10;

-- Check user info
SELECT id, email, company_name FROM users WHERE email = 'your@email.com';
```

## Frontend Debugging Code

Add this to your Feedback.jsx to debug:

```javascript
const handleSubmit = async () => {
  console.log("=== FEEDBACK SUBMISSION DEBUG ===");
  console.log("Rating:", rating);
  console.log("Comments:", comments);
  
  const token = localStorage.getItem("authToken");
  console.log("Token exists:", !!token);
  console.log("Token preview:", token ? token.substring(0, 20) + "..." : "MISSING");
  
  const payload = {
    rating: rating,
    comments: comments
  };
  console.log("Payload:", JSON.stringify(payload));
  
  try {
    const response = await fetch("http://localhost:8080/api/feedback", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`
      },
      body: JSON.stringify(payload)
    });
    
    console.log("Response status:", response.status);
    console.log("Response ok:", response.ok);
    
    const responseText = await response.text();
    console.log("Response body:", responseText);
    
    if (response.ok) {
      const data = JSON.parse(responseText);
      console.log("Success! Feedback ID:", data.id);
      alert("Thank you for your feedback!");
    } else {
      console.error("Error response:", responseText);
      alert(`Failed: ${responseText}`);
    }
  } catch (error) {
    console.error("Network error:", error);
    alert(`Network error: ${error.message}`);
  }
};
```

## Checklist

- [ ] Backend is running on port 8080
- [ ] Frontend is running on port 5173
- [ ] User is logged in (token in localStorage)
- [ ] Token is valid (not expired)
- [ ] Request payload has correct field names: `rating` and `comments`
- [ ] Rating is between 1-5
- [ ] Comments is not empty and < 2000 chars
- [ ] No CORS errors in browser console
- [ ] Backend logs show the request

## Still Not Working?

1. Run `.\test-feedback-api.ps1` - if this works, the issue is in your frontend
2. Check browser console for exact error message
3. Check backend logs for exact error message
4. Share the error messages for further help

## Expected Flow

1. User fills form (rating + comments)
2. Click submit
3. Frontend sends POST to `/api/feedback` with token
4. Backend validates token → finds user
5. Backend validates data (rating 1-5, comments not empty)
6. Backend saves to database
7. Backend returns saved feedback with ID
8. Frontend shows success message

If any step fails, check that specific step!
