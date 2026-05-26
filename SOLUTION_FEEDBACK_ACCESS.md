# Feedback Access Issue - SOLUTION

## The Problem

Your feedback system has **role-based access control**:

- ✅ **ALL users** can SUBMIT feedback
- ❌ **ONLY PROFESSIONAL users** can VIEW feedback list and export CSV/Excel
- ❌ **PERSONAL users** get 403 Forbidden when trying to view feedback

## Why This Happens

In `FeedbackController.java`:

```java
@GetMapping
public ResponseEntity<Page<FeedbackDTO>> getFeedback(...) {
    // Check if user is PROFESSIONAL
    if (user.getAccountType() != AccountType.PROFESSIONAL) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }
    // ...
}
```

## Solutions

### Option 1: Change User to PROFESSIONAL (Quick Fix)

Update your test user in the database:

```sql
-- Check current account type
SELECT email, account_type, company_name FROM users WHERE email = 'your@email.com';

-- Change to PROFESSIONAL
UPDATE users 
SET account_type = 'PROFESSIONAL' 
WHERE email = 'your@email.com';

-- Verify
SELECT email, account_type, company_name FROM users WHERE email = 'your@email.com';
```

### Option 2: Create Separate Admin View (Recommended)

Keep two separate pages:

1. **User Feedback Form** (`/feedback`) - All users can submit
2. **Admin Feedback Dashboard** (`/admin/feedback`) - Only PROFESSIONAL users can view

### Option 3: Allow All Users to View Their Own Feedback

Modify the backend to let users see their own feedback:

```java
// In FeedbackController.java
@GetMapping("/my-feedback")
public ResponseEntity<Page<FeedbackDTO>> getMyFeedback(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        Authentication auth) {
    
    String userEmail = auth.getName();
    User user = userRepository.findByEmail(userEmail)
        .orElseThrow(() -> new RuntimeException("User not found"));
    
    // Get only this user's feedback
    Page<FeedbackDTO> feedbackPage = feedbackService.getFeedbackByUser(
        user.getId(), page, size);
    
    return ResponseEntity.ok(feedbackPage);
}
```

## Recommended Setup

### For Regular Users (PERSONAL):
- Can submit feedback via `/api/feedback` (POST)
- Can view their own feedback via `/api/feedback/my-feedback` (GET)
- Cannot view all company feedback
- Cannot export CSV/Excel

### For Admin Users (PROFESSIONAL):
- Can submit feedback
- Can view ALL company feedback via `/api/feedback` (GET)
- Can mark feedback as reviewed
- Can export CSV/Excel

## Quick Test

Run this to check your account type:

```powershell
.\verify-feedback-flow.ps1
```

If you see "403 Forbidden" when retrieving feedback list, you need to:
1. Change your user to PROFESSIONAL, OR
2. Use a PROFESSIONAL account to view the admin dashboard

## Implementation Steps

### Step 1: Check Your Account Type

```sql
SELECT email, account_type FROM users WHERE email = 'your@email.com';
```

### Step 2A: If You Want to View as Admin

```sql
UPDATE users SET account_type = 'PROFESSIONAL' WHERE email = 'your@email.com';
```

### Step 2B: If You Want Separate User/Admin Views

Keep your account as PERSONAL and create a separate PROFESSIONAL admin account:

```sql
-- Create admin user (you'll need to signup first, then update)
UPDATE users 
SET account_type = 'PROFESSIONAL' 
WHERE email = 'admin@example.com';
```

### Step 3: Update Frontend Routes

```jsx
// User routes (all users)
<Route path="/feedback" element={<FeedbackForm />} />
<Route path="/my-feedback" element={<MyFeedbackList />} />

// Admin routes (PROFESSIONAL only)
<Route path="/admin/feedback" element={<AdminFeedbackDashboard />} />
```

## Testing

### Test as Regular User (PERSONAL):
1. Login with PERSONAL account
2. Submit feedback - Should work ✓
3. Try to view `/admin/feedback` - Should show 403 error ✓

### Test as Admin (PROFESSIONAL):
1. Login with PROFESSIONAL account
2. Submit feedback - Should work ✓
3. View `/admin/feedback` - Should show all feedback ✓
4. Export CSV/Excel - Should work ✓

## Current Status

Your backend is working correctly! The issue is:
- ✅ Feedback IS being saved to database
- ✅ API endpoints work correctly
- ❌ You're trying to view feedback with a PERSONAL account (not allowed)

**Solution:** Change your account to PROFESSIONAL or create a separate admin account.
