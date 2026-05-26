# 🗄️ Where Signed-Up User Details Are Stored

## 📍 Database Table: `users`

The signed-up user details are stored in the **`users`** table in your PostgreSQL database.

---

## 🏗️ Database Schema

### Table Structure:
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,           -- Auto-generated unique ID
    company_name VARCHAR(255) NOT NULL, -- Company name from signup
    email VARCHAR(255) NOT NULL UNIQUE, -- Email (unique constraint)
    account_type VARCHAR(50),           -- PROFESSIONAL or PERSONAL
    phone_number VARCHAR(50)            -- Optional phone number
);
```

### Key Features:
- ✅ **Primary Key**: `id` (auto-incremented)
- ✅ **Unique Constraint**: `email` (prevents duplicate accounts)
- ✅ **Required Fields**: `company_name`, `email`
- ✅ **Optional Fields**: `account_type`, `phone_number`

---

## 💾 How Data Gets Saved

### 1. User Fills Signup Form:
```javascript
{
  "companyName": "Test Company",
  "email": "user@example.com",
  "password": "password123",
  "confirmPassword": "password123",
  "accountType": "PROFESSIONAL"
}
```

### 2. Backend Processing (AuthService.signup()):
```java
// Create new User entity
User newUser = new User();
newUser.setCompanyName(request.getCompanyName().trim());           // "Test Company"
newUser.setEmail(request.getEmail().trim().toLowerCase());         // "user@example.com"
newUser.setAccountType(AccountType.PROFESSIONAL);                 // "PROFESSIONAL"
newUser.setPhoneNumber(request.getPhoneNumber().trim());          // Optional

// Save to database
User savedUser = userRepository.save(newUser);
```

### 3. Database Record Created:
```sql
INSERT INTO users (company_name, email, account_type, phone_number)
VALUES ('Test Company', 'user@example.com', 'PROFESSIONAL', NULL);
```

---

## 🔍 View Stored Users

### Using pgAdmin 4:
1. Open pgAdmin 4
2. Connect to PostgreSQL 16
3. Navigate to: `Databases` → `omoiservespare_db` → `Schemas` → `public` → `Tables` → `users`
4. Right-click on `users` → `View/Edit Data` → `All Rows`

### Using SQL Query:
```sql
-- Connect to database
psql -U postgres -d omoiservespare_db

-- View all users
SELECT * FROM users;

-- View specific user
SELECT * FROM users WHERE email = 'user@example.com';

-- Count total users
SELECT COUNT(*) FROM users;
```

### Using PowerShell:
```powershell
# Connect and query
$env:PGPASSWORD="NikhitaMumbai123*"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c "SELECT * FROM users;"
```

---

## 📊 Sample Data

### After Signup:
| id | company_name | email | account_type | phone_number |
|----|--------------|-------|--------------|--------------|
| 1 | Test Company | user@example.com | PROFESSIONAL | NULL |
| 2 | ABC Corp | john@abc.com | PROFESSIONAL | +91-9876543210 |
| 3 | XYZ Ltd | jane@xyz.com | PERSONAL | +91-9876543211 |

---

## 🔐 Data Processing Details

### Email Processing:
```java
// Original: "User@Example.COM"
// Stored:   "user@example.com" (lowercase + trimmed)
newUser.setEmail(request.getEmail().trim().toLowerCase());
```

### Company Name Processing:
```java
// Original: "  Test Company  "
// Stored:   "Test Company" (trimmed)
newUser.setCompanyName(request.getCompanyName().trim());
```

### Account Type:
```java
// Default: PROFESSIONAL if not specified
newUser.setAccountType(request.getAccountType() != null ? 
    request.getAccountType() : AccountType.PROFESSIONAL);
```

---

## 🔄 Data Flow Diagram

```
Frontend Form
     ↓
SignupRequest DTO
     ↓
AuthService.signup()
     ↓
User Entity (JPA)
     ↓
UserRepository.save()
     ↓
PostgreSQL Database
     ↓
users table
```

---

## 🗂️ Related Tables

The `users` table connects to other tables:

### 1. `refresh_tokens` table:
```sql
-- Links to users for JWT refresh tokens
FOREIGN KEY (user_id) REFERENCES users(id)
```

### 2. `orders` table:
```sql
-- Links to users for order history
FOREIGN KEY (customer_id) REFERENCES users(id)
```

### 3. `otps` table:
```sql
-- Links by email for OTP verification
-- No foreign key, but email matches users.email
```

---

## 🧪 Test User Storage

### Create Test User:
```powershell
.\test-signup.ps1
```

### Verify in Database:
```sql
-- Check if user was created
SELECT id, company_name, email, account_type, phone_number 
FROM users 
WHERE email = 'testuser@example.com';
```

### Expected Result:
```
 id | company_name | email                | account_type | phone_number
----+--------------+----------------------+--------------+-------------
  1 | Test Company | testuser@example.com | PROFESSIONAL | 
```

---

## 📍 Database Location

### Physical Location:
- **Server**: localhost:5432
- **Database**: omoiservespare_db
- **Schema**: public
- **Table**: users

### Connection Details:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/omoiservespare_db
spring.datasource.username=postgres
spring.datasource.password=NikhitaMumbai123*
```

---

## 🔍 Verification Commands

### Check Table Exists:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'users';
```

### Check Table Structure:
```sql
\d users
```

### Check Constraints:
```sql
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'users';
```

### Check Indexes:
```sql
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'users';
```

---

## 🚨 Important Notes

### 1. Password Storage:
❌ **Passwords are NOT stored in the database**
- The signup form collects passwords for validation only
- Passwords are used to confirm user intent
- Authentication is done via OTP, not passwords
- This is more secure than storing password hashes

### 2. Email Uniqueness:
✅ **Email must be unique**
```sql
CONSTRAINT users_email_key UNIQUE (email)
```
- Prevents duplicate accounts
- Enforced at database level
- Returns error if duplicate email used

### 3. Data Validation:
✅ **Server-side validation applied**
- Company name: Required, trimmed
- Email: Required, unique, lowercase, trimmed
- Account type: Defaults to PROFESSIONAL
- Phone number: Optional, trimmed

---

## 📊 Storage Summary

| Field | Source | Processing | Storage |
|-------|--------|------------|---------|
| ID | Auto-generated | BIGSERIAL | Primary key |
| Company Name | Signup form | Trimmed | VARCHAR(255) |
| Email | Signup form | Lowercase + trimmed | VARCHAR(255) UNIQUE |
| Account Type | Signup form | Default PROFESSIONAL | VARCHAR(50) |
| Phone Number | Signup form | Trimmed | VARCHAR(50) |
| Password | Signup form | **NOT STORED** | N/A |

---

## ✅ Verification Checklist

To confirm user storage is working:

- [ ] Backend is running
- [ ] Database connection is working
- [ ] `users` table exists
- [ ] Signup endpoint responds
- [ ] Test user creation works
- [ ] User appears in database
- [ ] Unique email constraint works
- [ ] Login works with stored user

---

**Location**: PostgreSQL database `omoiservespare_db` → `public.users` table  
**Access**: Via pgAdmin 4, psql command line, or SQL queries  
**Security**: Passwords not stored, OTP-based authentication used