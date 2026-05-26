# 🏗️ Signup System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRODUCTION SIGNUP SYSTEM                      │
│                                                                   │
│  ┌──────────────┐              ┌──────────────┐                │
│  │   ADMIN      │              │   VENDOR     │                │
│  │   SIGNUP     │              │   SIGNUP     │                │
│  └──────────────┘              └──────────────┘                │
│         │                              │                         │
│         ▼                              ▼                         │
│  ┌──────────────┐              ┌──────────────┐                │
│  │ Secret Key   │              │   Public     │                │
│  │  Required    │              │Registration  │                │
│  └──────────────┘              └──────────────┘                │
│         │                              │                         │
│         └──────────────┬───────────────┘                        │
│                        ▼                                         │
│              ┌──────────────────┐                               │
│              │  Authentication  │                               │
│              │   & JWT Tokens   │                               │
│              └──────────────────┘                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Vendor Registration Flow

```
┌─────────────┐
│   Vendor    │
│  Applies    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ POST /api/vendor/register               │
│                                         │
│ {                                       │
│   email, phone, restaurantName,        │
│   ownerName, address, license, etc.    │
│ }                                       │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ VendorRegistrationService               │
│                                         │
│ 1. Validate email/phone unique         │
│ 2. Create User record                  │
│    - role = VENDOR                     │
│    - vendorStatus = PENDING            │
│    - accountActive = false             │
│ 3. Create Vendor record                │
│    - Store restaurant details          │
│ 4. Send notifications                  │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│         DATABASE                        │
│                                         │
│  users table:                          │
│  ┌────────────────────────────────┐   │
│  │ id: 1                          │   │
│  │ email: vendor@example.com      │   │
│  │ role: VENDOR                   │   │
│  │ vendorStatus: PENDING          │   │
│  │ accountActive: false           │   │
│  └────────────────────────────────┘   │
│                                         │
│  vendors table:                        │
│  ┌────────────────────────────────┐   │
│  │ id: 1                          │   │
│  │ user_id: 1                     │   │
│  │ restaurantName: My Restaurant  │   │
│  │ ownerName: John Doe            │   │
│  │ address: 123 Main St           │   │
│  │ businessLicense: BL123456      │   │
│  └────────────────────────────────┘   │
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Response to Vendor                      │
│                                         │
│ {                                       │
│   success: true,                       │
│   status: "PENDING",                   │
│   message: "Application submitted"     │
│ }                                       │
└─────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Vendor waits for admin approval        │
│ Can check status via:                  │
│ GET /api/vendor/status/{email}         │
└─────────────────────────────────────────┘
```

---

## 👑 Admin Creation Flow

### First Admin (One-Time Setup)

```
┌─────────────┐
│   System    │
│   Setup     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ POST /api/admin/create-first            │
│                                         │
│ {                                       │
│   email: "admin@company.com",          │
│   phoneNumber: "+1234567890",          │
│   fullName: "Admin User",              │
│   secretKey: "SECRET_KEY"              │
│ }                                       │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ AdminManagementService                  │
│                                         │
│ 1. Verify secret key                   │
│ 2. Check no admin exists               │
│ 3. Create User record                  │
│    - role = ADMIN                      │
│    - accountActive = true              │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ First Admin Created ✅                  │
│                                         │
│ Can now login and manage system        │
└─────────────────────────────────────────┘
```

### Additional Admins (By Existing Admin)

```
┌─────────────┐
│   Admin     │
│  Logged In  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ POST /api/admin/create                  │
│ Authorization: Bearer <JWT>             │
│                                         │
│ {                                       │
│   email: "newadmin@company.com",       │
│   phoneNumber: "+1234567890",          │
│   fullName: "New Admin"                │
│ }                                       │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ AdminManagementService                  │
│                                         │
│ 1. Verify JWT token                    │
│ 2. Verify creator is ADMIN             │
│ 3. Create new admin user               │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ New Admin Created ✅                    │
└─────────────────────────────────────────┘
```

---

## ✅ Vendor Approval Flow

```
┌─────────────┐
│   Admin     │
│  Reviews    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ GET /api/admin/vendors/pending          │
│ Authorization: Bearer <JWT>             │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Returns list of pending vendors         │
│                                         │
│ [                                       │
│   {                                     │
│     id: 1,                             │
│     email: "vendor@example.com",       │
│     vendorStatus: "PENDING",           │
│     restaurantName: "My Restaurant"    │
│   }                                     │
│ ]                                       │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Admin decides: APPROVE or REJECT        │
└──────┬──────────────────────────────────┘
       │
       ├─────────────┬─────────────┐
       │             │             │
       ▼             ▼             ▼
   APPROVE       REJECT       SUSPEND
       │             │             │
       ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│ status:  │  │ status:  │  │ status:  │
│ APPROVED │  │ REJECTED │  │SUSPENDED │
│ active:  │  │ active:  │  │ active:  │
│ true ✅  │  │ false ❌ │  │ false ❌ │
└──────────┘  └──────────┘  └──────────┘
       │             │             │
       ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Vendor   │  │ Vendor   │  │ Vendor   │
│ can      │  │ cannot   │  │ cannot   │
│ login ✅ │  │ login ❌ │  │ login ❌ │
└──────────┘  └──────────┘  └──────────┘
```

---

## 🔐 Authentication Flow

```
┌─────────────────────────────────────────┐
│ User Login Attempt                      │
│ POST /api/auth/login                    │
│                                         │
│ { email, phoneNumber }                 │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ AuthService validates:                  │
│                                         │
│ 1. User exists?                        │
│ 2. Account active?                     │
│ 3. If VENDOR: status = APPROVED?       │
└──────┬──────────────────────────────────┘
       │
       ├─────────────┬─────────────┐
       │             │             │
       ▼             ▼             ▼
    ADMIN         VENDOR         USER
  (active)      (approved)     (active)
       │             │             │
       └─────────────┴─────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│ Generate & Send OTP                     │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ User verifies OTP                       │
│ POST /api/auth/verify-otp               │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Generate JWT Token                      │
│                                         │
│ Token contains:                         │
│ - userId                               │
│ - email                                │
│ - role (USER/VENDOR/ADMIN)             │
│ - expiration                           │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ User can access protected endpoints     │
│ with JWT token                          │
└─────────────────────────────────────────┘
```

---

## 🗄️ Database Schema

```
┌─────────────────────────────────────────┐
│              users                      │
├─────────────────────────────────────────┤
│ id (PK)                    BIGINT       │
│ email                      VARCHAR(255) │
│ phone_number               VARCHAR(20)  │
│ company_name               VARCHAR(255) │
│ role                       ENUM         │
│   - USER                               │
│   - VENDOR                             │
│   - ADMIN                              │
│ vendor_status              ENUM         │
│   - PENDING                            │
│   - APPROVED                           │
│   - REJECTED                           │
│   - SUSPENDED                          │
│ account_active             BOOLEAN     │
│ created_at                 TIMESTAMP   │
│ updated_at                 TIMESTAMP   │
└─────────────────────────────────────────┘
                │
                │ 1:1
                │
                ▼
┌─────────────────────────────────────────┐
│             vendors                     │
├─────────────────────────────────────────┤
│ id (PK)                    BIGINT       │
│ user_id (FK, UNIQUE)       BIGINT       │
│ restaurant_name            VARCHAR(255) │
│ owner_name                 VARCHAR(255) │
│ address                    TEXT         │
│ business_license           VARCHAR(255) │
│ description                TEXT         │
│ created_at                 TIMESTAMP   │
│ updated_at                 TIMESTAMP   │
└─────────────────────────────────────────┘
```

---

## 🔒 Security Layers

```
┌─────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                       │
└─────────────────────────────────────────────────────────┘

Layer 1: Public Endpoints
┌─────────────────────────────────────────┐
│ ✅ /api/vendor/register                 │
│ ✅ /api/vendor/status/{email}           │
│ ✅ /api/admin/create-first              │
│                                         │
│ No authentication required              │
│ (Secret key for admin creation)         │
└─────────────────────────────────────────┘

Layer 2: JWT Authentication
┌─────────────────────────────────────────┐
│ JwtAuthFilter validates:                │
│ - Token present in Authorization header │
│ - Token not expired                     │
│ - Token signature valid                 │
│ - User exists in database               │
└─────────────────────────────────────────┘

Layer 3: Role-Based Access Control (RBAC)
┌─────────────────────────────────────────┐
│ @RequireRole(Role.ADMIN)                │
│                                         │
│ RoleAuthorizationAspect checks:         │
│ - User has required role                │
│ - Account is active                     │
│ - Vendor is approved (if VENDOR)        │
└─────────────────────────────────────────┘

Layer 4: Account Status Validation
┌─────────────────────────────────────────┐
│ For VENDOR:                             │
│ - vendorStatus must be APPROVED         │
│ - accountActive must be true            │
│                                         │
│ For ADMIN:                              │
│ - accountActive must be true            │
└─────────────────────────────────────────┘
```

---

## 📊 State Diagram: Vendor Lifecycle

```
┌─────────────┐
│   START     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│         VENDOR APPLIES                  │
│  POST /api/vendor/register              │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│           PENDING                       │
│  - Cannot login                         │
│  - Waiting for admin review             │
└──────┬──────────────────────────────────┘
       │
       ├─────────────┬─────────────┐
       │             │             │
       ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│ APPROVED │  │ REJECTED │  │SUSPENDED │
│          │  │          │  │          │
│ Can      │  │ Cannot   │  │ Cannot   │
│ login ✅ │  │ login ❌ │  │ login ❌ │
└────┬─────┘  └──────────┘  └────┬─────┘
     │                            │
     │                            │
     └────────────┬───────────────┘
                  │
                  ▼
          ┌──────────────┐
          │   ACTIVE     │
          │   VENDOR     │
          │              │
          │ Can manage   │
          │ restaurant   │
          └──────────────┘
```

---

## 🔄 Complete System Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPLETE SYSTEM FLOW                          │
└─────────────────────────────────────────────────────────────────┘

1. INITIAL SETUP
   ┌──────────────────────────────────────┐
   │ Deploy application                   │
   │ Run database migrations              │
   │ Set admin secret key                 │
   │ Create first admin                   │
   └──────────────────────────────────────┘

2. VENDOR ONBOARDING
   ┌──────────────────────────────────────┐
   │ Vendor registers                     │
   │ → Status: PENDING                    │
   │ → Account: INACTIVE                  │
   │                                      │
   │ Admin reviews application            │
   │ → Checks documents                   │
   │ → Verifies business license          │
   │                                      │
   │ Admin approves                       │
   │ → Status: APPROVED                   │
   │ → Account: ACTIVE                    │
   │                                      │
   │ Vendor can login                     │
   │ → Manages restaurant                 │
   │ → Adds menu items                    │
   │ → Processes orders                   │
   └──────────────────────────────────────┘

3. ADMIN MANAGEMENT
   ┌──────────────────────────────────────┐
   │ Admin logs in                        │
   │ → Views pending vendors              │
   │ → Approves/rejects applications      │
   │ → Creates additional admins          │
   │ → Monitors system                    │
   │ → Suspends vendors if needed         │
   └──────────────────────────────────────┘

4. ONGOING OPERATIONS
   ┌──────────────────────────────────────┐
   │ Vendors operate restaurants          │
   │ Admins monitor and manage            │
   │ Users order food                     │
   │ System processes transactions        │
   └──────────────────────────────────────┘
```

---

## 🎯 Key Design Decisions

### 1. Separate Vendor Table
**Why?** Keep user authentication separate from vendor-specific details.

```
users table → Authentication & roles
vendors table → Restaurant details
```

### 2. Vendor Status Enum
**Why?** Clear state management for vendor lifecycle.

```
PENDING → Initial state
APPROVED → Can operate
REJECTED → Application denied
SUSPENDED → Temporarily disabled
```

### 3. Account Active Flag
**Why?** System-wide account control independent of vendor status.

```
accountActive = false → Cannot login (any role)
accountActive = true + vendorStatus = APPROVED → Vendor can login
```

### 4. Secret Key for First Admin
**Why?** Prevent unauthorized admin creation during initial setup.

```
First admin → Requires secret key
Additional admins → Requires existing admin JWT
```

### 5. Public Vendor Registration
**Why?** Allow restaurants to apply without admin intervention.

```
Anyone can apply → Admin reviews → Admin approves/rejects
```

---

## 📈 Scalability Considerations

### Current Implementation
- Single database
- Synchronous processing
- In-memory OTP storage

### Future Enhancements
- Email notification queue (Kafka)
- Redis for OTP storage
- Admin dashboard for vendor management
- Vendor application analytics
- Automated document verification
- Multi-level approval workflow

---

## 🔗 Integration Points

```
┌─────────────────────────────────────────┐
│     External Systems Integration        │
└─────────────────────────────────────────┘

Email Service
├─ Vendor application confirmation
├─ Admin notification (new vendor)
├─ Vendor approval/rejection notification
└─ Admin creation notification

SMS Service (Optional)
├─ OTP delivery
└─ Status updates

Document Verification (Future)
├─ Business license verification
└─ Identity verification

Payment Gateway (Future)
├─ Vendor subscription
└─ Commission processing
```

---

This architecture provides a solid foundation for a production-ready signup system with proper separation of concerns, security, and scalability.
