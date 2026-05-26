# App_Feedback.jsx Update Instructions

## ✅ What Was Changed

Your `App_Feedback.jsx` file has been updated with **full backend integration**. Here's what changed:

### Before (Hardcoded Data)
```javascript
const feedbackData = [
  { name: "John Doe", rating: 5, comment: "Excellent app!" },
  // ... hardcoded array
];
```

### After (Backend Integration)
```javascript
const [feedbackData, setFeedbackData] = useState([]);

// Fetches from: http://localhost:8080/api/feedback
const fetchFeedback = async () => {
  const response = await fetch(url, {
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json"
    }
  });
  // ... updates state with real data
};
```

## 🎯 Key Features Added

1. **Real-time Backend Integration**
   - Fetches feedback from Spring Boot API
   - Auto-refreshes every 30 seconds
   - Displays actual user submissions

2. **JWT Authentication**
   - Auto-detects token from localStorage
   - Tries multiple key names: "token", "authToken", "jwt", "accessToken", "jwtToken"
   - Shows clear error messages if not authenticated

3. **Status Management**
   - Filter by: All, New, Reviewed
   - Mark feedback as reviewed with one click
   - Visual status badges (yellow for NEW, green for REVIEWED)

4. **Real CSV/Excel Export**
   - Downloads from backend API
   - Includes all feedback data
   - Proper file naming with date

5. **Pagination**
   - 20 items per page
   - Previous/Next navigation
   - Shows total count

6. **Error Handling**
   - Clear error messages
   - Network error detection
   - 401/403 authentication errors

## 📋 How to Use the Updated File

### Step 1: Copy to Your React Project

Copy the file `omoiservespare/App_Feedback.jsx` to your React project's component directory:

```
your-react-project/
  src/
    components/
      App_Feedback.jsx  ← Copy here
      App_Feedback.css  ← Keep your existing CSS
```

### Step 2: Verify Backend is Running

Make sure your Spring Boot backend is running on port 8080:

```powershell
# Check if backend is running
curl http://localhost:8080/api/feedback
```

### Step 3: Login First

Before viewing the feedback page, make sure you're logged in as a PROFESSIONAL user:
- Email: nikita.a@omoikaneinnovations.com
- The login will store JWT token in localStorage

### Step 4: Test the Page

1. Navigate to the feedback admin page in your React app
2. You should see the 2 existing feedback entries (IDs 2 and 3)
3. Try filtering by status
4. Try downloading CSV/Excel
5. Try marking feedback as reviewed

## 🔍 Troubleshooting

### If you see "Not logged in" error:

1. Open browser console (F12)
2. Check what's logged by the `getToken()` function
3. Verify your JWT token is stored in localStorage

Run this in browser console:
```javascript
// Check all localStorage keys
console.log(Object.keys(localStorage));

// Check for token
["token", "authToken", "jwt", "accessToken", "jwtToken"].forEach(key => {
  const val = localStorage.getItem(key);
  if (val) console.log(key, ":", val.substring(0, 20) + "...");
});
```

### If you see 401 Unauthorized:

- Your token might be expired
- Log out and log back in
- The new token will be stored automatically

### If you see 403 Forbidden:

- Only PROFESSIONAL account types can view feedback
- Check your user's account_type in the database
- You're currently logged in as: nikita.a@omoikaneinnovations.com (PROFESSIONAL ✓)

### If you see "Network error":

- Backend is not running on port 8080
- Start your Spring Boot application:
  ```powershell
  cd omoiservespare
  .\mvnw.cmd spring-boot:run
  ```

## 📊 What Data You'll See

Based on your backend logs, you have 2 feedback entries:

| ID | User Email | Rating | Status | Company |
|----|-----------|--------|--------|---------|
| 2 | (user email) | 3 | NEW | Omoiservespare Pvt Ltd |
| 3 | (user email) | 3 | NEW | Omoiservespare Pvt Ltd |

## 🎨 CSS Compatibility

The updated component uses the same CSS classes as your original:
- `.feedback-page`
- `.rating-summary`
- `.download-buttons`
- `.feedback-table`

Your existing `App_Feedback.css` should work without changes.

## 🚀 Next Steps

1. **Test the integration** - Verify feedback appears correctly
2. **Submit more feedback** - Use your `Feedback.jsx` page to submit new feedback
3. **Test exports** - Download CSV and Excel files
4. **Test status updates** - Mark feedback as reviewed
5. **Monitor real-time updates** - Wait 30 seconds to see auto-refresh

## 📝 API Endpoints Used

The component calls these backend endpoints:

1. `GET /api/feedback?page=0&size=20` - Fetch feedback list
2. `PUT /api/feedback/{id}/review` - Mark as reviewed
3. `GET /api/feedback/export/csv` - Download CSV
4. `GET /api/feedback/export/excel` - Download Excel

All endpoints require JWT authentication via `Authorization: Bearer <token>` header.

## ✨ Production-Grade Features

- ✅ Real-time data from database
- ✅ JWT authentication
- ✅ Multi-tenant (company-specific data)
- ✅ Role-based access (PROFESSIONAL users only)
- ✅ Auto-refresh every 30 seconds
- ✅ Pagination for large datasets
- ✅ Status filtering
- ✅ Error handling and user feedback
- ✅ Proper file downloads (CSV/Excel)
- ✅ Loading states
- ✅ Empty state handling

Your feedback system is now production-ready! 🎉
