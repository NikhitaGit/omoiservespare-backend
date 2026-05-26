# How to Use the Updated App_Feedback Component

## Step 1: Replace Your Current File

Replace your current `App_Feedback.jsx` with the content from `App_Feedback_UPDATED.jsx`

**Location:** Copy the code from `App_Feedback_UPDATED.jsx` to your actual `App_Feedback.jsx` file in your React project.

## Step 2: Verify JWT Token Storage

Make sure your JWT token is stored in localStorage with the key `"token"`. 

If you use a different key, update this line in the component:
```javascript
const token = localStorage.getItem("token"); // Change "token" to your key
```

## Step 3: Test the Component

1. **Start your backend** (if not already running):
   ```powershell
   cd omoiservespare
   mvnw spring-boot:run
   ```

2. **Start your frontend**:
   ```powershell
   npm run dev
   ```

3. **Login as PROFESSIONAL user**:
   - Email: nikita.a@omoikaneinnovations.com
   - (Your password)

4. **Navigate to the feedback page**

## What You'll See

Based on your logs, you should see:
- ✅ **2 feedback entries** (ID 2 and 3)
- ✅ **Rating: 3 stars** for both
- ✅ **Status: NEW** (not yet reviewed)
- ✅ **User: nikita.a@omoikaneinnovations.com**
- ✅ **Company: Omoiservespare Pvt Ltd**

## Features Available

### 1. View Feedback
- Automatically loads when page opens
- Shows all feedback from your company
- Auto-refreshes every 30 seconds

### 2. Filter by Status
- Use dropdown to filter: ALL / NEW / REVIEWED
- Instantly updates the table

### 3. Mark as Reviewed
- Click "Mark Reviewed" button on any NEW feedback
- Status changes to REVIEWED
- Records the review timestamp

### 4. Export to CSV
- Click "Download CSV" button
- Downloads file: `feedback_2024-03-31.csv`
- Contains all feedback from your company

### 5. Export to Excel
- Click "Download Excel" button
- Downloads file: `feedback_2024-03-31.xlsx`
- Formatted with bold headers and proper columns

### 6. Pagination
- Shows 20 feedback items per page
- Navigate with Previous/Next buttons
- Shows current page number

## Key Changes from Original

| Original | Updated |
|----------|---------|
| Hardcoded data | Real API data |
| Static array | Dynamic from backend |
| Client-side CSV | Server-generated CSV |
| Client-side Excel | Server-generated Excel |
| No authentication | JWT token required |
| No real-time updates | Auto-refresh every 30s |
| No status management | Mark as reviewed feature |
| No pagination | Full pagination support |

## Troubleshooting

### Issue: "Access denied" error
**Solution:** Make sure you're logged in as a PROFESSIONAL user. Only PROFESSIONAL account types can view feedback.

### Issue: No data showing
**Check:**
1. Backend is running on port 8080
2. JWT token is in localStorage
3. Open browser console (F12) and check for errors
4. Check Network tab to see if API call is made

### Issue: "Network error"
**Check:**
1. Backend is running: `http://localhost:8080`
2. CORS is configured correctly (already done in SecurityConfig)
3. No firewall blocking the connection

### Issue: Token not found
**Solution:** Make sure you're logged in. The token should be automatically stored in localStorage after login.

## Testing the API Directly

Open browser console (F12) and run:

```javascript
const token = localStorage.getItem("token");
console.log("Token:", token);

fetch("http://localhost:8080/api/feedback?page=0&size=20", {
  headers: {
    "Authorization": `Bearer ${token}`
  }
})
.then(res => res.json())
.then(data => console.log("Feedback:", data))
.catch(err => console.error("Error:", err));
```

You should see your 2 feedback entries in the console!

## Next Steps

1. ✅ Replace your App_Feedback.jsx with the updated version
2. ✅ Test the page - you should see your 2 feedback entries
3. ✅ Try marking one as reviewed
4. ✅ Try exporting to CSV and Excel
5. ✅ Submit more feedback and watch it appear automatically

---

**Your feedback system is now fully functional!** 🎉

All feedback submitted by users will automatically appear in this admin dashboard, and you can manage, filter, and export it as needed.
