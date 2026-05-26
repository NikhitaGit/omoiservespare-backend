# 🎟️ Production-Grade Coupon System Implementation Guide

## Overview
This is a complete, production-ready coupon system similar to Zomato/Swiggy with real-time validation, distributed locking, caching, and seamless cart integration.

---

## 🏗️ Architecture

### Backend Components
1. **Database Layer** - PostgreSQL with Flyway migrations
2. **Service Layer** - Business logic with Redis caching
3. **Controller Layer** - REST APIs
4. **Security** - Distributed locks to prevent race conditions

### Frontend Components
1. **CouponsPage** - Browse all available coupons
2. **Cart with Coupon Integration** - Apply/remove coupons in real-time
3. **API Layer** - Axios-based coupon services

---

## 📦 What's Included

### Backend Files Created:
```
src/main/java/com/omoikaneinnovations/omoiservespare/
├── entity/
│   ├── Coupon.java                    # Coupon entity with enums
│   └── CouponUsage.java               # Usage tracking
├── repository/
│   ├── CouponRepository.java          # JPA repository with custom queries
│   └── CouponUsageRepository.java     # Usage tracking repository
├── dto/
│   ├── CouponDTO.java                 # Data transfer object
│   ├── CouponValidationRequest.java   # Validation request
│   └── CouponValidationResponse.java  # Validation response
├── service/
│   └── CouponService.java             # Core business logic
├── controller/
│   └── CouponController.java          # REST endpoints
└── exception/
    └── InvalidCouponException.java    # Custom exception

src/main/resources/db/migration/
└── V7__create_coupon_tables.sql       # Database schema + sample data
```

### Frontend Files Created:
```
COUPON_SYSTEM_FRONTEND/
├── api/
│   └── couponApi.js                   # API service layer
├── pages/
│   ├── CouponsPage.jsx                # Coupons listing page
│   └── Cart.jsx                       # Updated cart with coupons
└── styles/
    ├── coupons.css                    # Coupon page styles
    └── cart-coupon-additions.css      # Cart coupon styles
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Backend Setup

#### 1.1 Copy Backend Files
Copy all the backend files to your project:
```bash
# All files are already created in the correct locations
# Just restart your Spring Boot application
```

#### 1.2 Run Database Migration
The migration will run automatically when you start the application. It will:
- Create 4 tables: `coupons`, `coupon_usage`, `coupon_restaurants`, `user_coupons`
- Insert 5 sample coupons
- Create necessary indexes

#### 1.3 Verify Database
```sql
-- Check if tables are created
SELECT * FROM coupons;

-- You should see 5 sample coupons:
-- WELCOME200, SAVE50, FLAT100, CASHBACK20, MEGA30
```

### Step 2: Frontend Setup

#### 2.1 Copy Frontend Files
```bash
# Copy the files from COUPON_SYSTEM_FRONTEND to your React project

# API
cp COUPON_SYSTEM_FRONTEND/api/couponApi.js src/api/

# Pages
cp COUPON_SYSTEM_FRONTEND/pages/CouponsPage.jsx src/pages/
cp COUPON_SYSTEM_FRONTEND/pages/Cart.jsx src/pages/

# Styles
cp COUPON_SYSTEM_FRONTEND/styles/coupons.css src/styles/
# Merge cart-coupon-additions.css into your existing cart.css
```

#### 2.2 Update Routes
Add the coupons route to your React Router:

```jsx
// In your App.js or Routes file
import CouponsPage from './pages/CouponsPage';

<Route path="/coupons" element={<CouponsPage />} />
```

#### 2.3 Merge CSS
Append the content of `cart-coupon-additions.css` to your existing `cart.css` file.

---

## 🎯 Features Implemented

### 1. Real-Time Coupon Validation
- ✅ Validates coupon code existence
- ✅ Checks expiry dates
- ✅ Verifies minimum order value
- ✅ Enforces usage limits (total & per-user)
- ✅ Validates first-order conditions

### 2. Discount Calculation
- ✅ **PERCENTAGE**: e.g., 50% OFF up to ₹150
- ✅ **FLAT**: e.g., Flat ₹200 OFF
- ✅ **CASHBACK**: e.g., 20% Cashback (credited later)

### 3. Performance Optimizations
- ✅ Redis caching for frequently used coupons
- ✅ Distributed locking to prevent race conditions
- ✅ Database indexes for fast queries

### 4. User Experience
- ✅ Browse all coupons on dedicated page
- ✅ Apply coupon from cart with manual code entry
- ✅ View available coupons in modal
- ✅ Navigate to coupons page from cart
- ✅ Real-time discount calculation
- ✅ Visual feedback for applied coupons

---

## 🔌 API Endpoints

### 1. Get All Active Coupons
```http
GET /api/coupons
```
**Response:**
```json
[
  {
    "id": 1,
    "code": "WELCOME200",
    "description": "Flat ₹200 OFF on orders above ₹999",
    "discountType": "FLAT",
    "discountValue": 200.00,
    "minOrderValue": 999.00,
    "endDate": "2026-05-14T10:30:00"
  }
]
```

### 2. Get Available Coupons for Cart
```http
GET /api/coupons/available?orderValue=1500&restaurantId=1
```
**Response:**
```json
[
  {
    "id": 1,
    "code": "SAVE50",
    "isApplicable": true,
    "calculatedDiscount": 150.00,
    "notApplicableReason": null
  },
  {
    "id": 2,
    "code": "WELCOME200",
    "isApplicable": false,
    "calculatedDiscount": 0,
    "notApplicableReason": "You have already used this coupon"
  }
]
```

### 3. Validate Coupon
```http
POST /api/coupons/validate
Content-Type: application/json

{
  "couponCode": "SAVE50",
  "orderValue": 1500,
  "restaurantId": 1
}
```
**Response:**
```json
{
  "isValid": true,
  "discount": 150.00,
  "message": "Coupon applied successfully! You saved ₹150",
  "couponCode": "SAVE50"
}
```

---

## 🎨 User Flow

### Flow 1: Apply Coupon from Cart
1. User adds items to cart
2. User enters coupon code in input field
3. Clicks "Apply" button
4. System validates in real-time
5. Discount reflects immediately in bill
6. User proceeds to payment

### Flow 2: Browse and Apply Coupons
1. User clicks "View all coupons" in cart
2. Navigates to coupons page with order value
3. Sees all available coupons
4. Clicks "Apply" on desired coupon
5. System validates and navigates back to cart
6. Coupon is applied automatically

### Flow 3: View Available Coupons Modal
1. User clicks on coupon section in cart
2. Modal opens showing applicable coupons
3. Green coupons are applicable
4. Gray coupons show reason for non-applicability
5. User clicks "Apply" on valid coupon
6. Modal closes and discount applies

---

## 🧪 Testing Guide

### Test Case 1: Valid Coupon
```bash
# Order value: ₹1500
# Coupon: SAVE50 (50% OFF up to ₹150, min ₹500)
# Expected: ₹150 discount
```

### Test Case 2: Minimum Order Not Met
```bash
# Order value: ₹400
# Coupon: SAVE50 (min ₹500)
# Expected: Error "Minimum order value of ₹500 required"
```

### Test Case 3: Already Used
```bash
# User has used WELCOME200 before
# Expected: Error "You have already used this coupon"
```

### Test Case 4: Expired Coupon
```bash
# Coupon end date passed
# Expected: Error "This coupon has expired"
```

---

## 🔒 Security Features

### 1. Distributed Locking
Prevents multiple simultaneous applications of the same coupon:
```java
String lockKey = "coupon_lock:" + couponCode + ":" + userId;
Boolean acquired = redisTemplate.opsForValue()
    .setIfAbsent(lockKey, "locked", 10, TimeUnit.SECONDS);
```

### 2. Server-Side Validation
All validation happens on the backend. Frontend only displays results.

### 3. Transaction Management
Coupon application is wrapped in `@Transactional` to ensure atomicity.

---

## 📊 Database Schema

### Coupons Table
```sql
CREATE TABLE coupons (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    max_discount DECIMAL(10,2),
    min_order_value DECIMAL(10,2) DEFAULT 0,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    total_usage_limit INTEGER,
    per_user_limit INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    applicable_on VARCHAR(50) DEFAULT 'ALL'
);
```

### Coupon Usage Table
```sql
CREATE TABLE coupon_usage (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT,
    discount_applied DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🎯 Sample Coupons Included

| Code | Type | Value | Min Order | Max Discount | Limit |
|------|------|-------|-----------|--------------|-------|
| WELCOME200 | FLAT | ₹200 | ₹999 | - | First Order |
| SAVE50 | PERCENTAGE | 50% | ₹500 | ₹150 | 3 per user |
| FLAT100 | FLAT | ₹100 | ₹499 | - | 2 per user |
| CASHBACK20 | CASHBACK | 20% | ₹300 | ₹100 | 5 per user |
| MEGA30 | PERCENTAGE | 30% | ₹600 | ₹200 | 1 per user |

---

## 🚀 Deployment Checklist

- [ ] Database migration completed
- [ ] Redis is running
- [ ] Backend endpoints tested
- [ ] Frontend files copied
- [ ] Routes configured
- [ ] CSS merged
- [ ] Test all user flows
- [ ] Monitor Redis cache
- [ ] Check database indexes

---

## 🔧 Customization

### Add New Coupon Type
1. Add enum value in `Coupon.java`
2. Update `calculateDiscount()` in `CouponService.java`
3. Update frontend display logic

### Add Restaurant-Specific Coupons
1. Use `coupon_restaurants` table
2. Update validation logic in `validateCouponRules()`
3. Pass `restaurantId` from cart

### Add User-Specific Coupons
1. Use `user_coupons` table
2. Create targeted marketing campaigns
3. Assign coupons to specific users

---

## 📞 Support

If you encounter any issues:
1. Check database migration logs
2. Verify Redis connection
3. Check browser console for frontend errors
4. Review backend logs for validation errors

---

## ✅ Success Indicators

You'll know it's working when:
- ✅ Coupons page loads with 5+ coupons
- ✅ Cart shows coupon input field
- ✅ Entering valid code applies discount
- ✅ Invalid code shows error message
- ✅ Discount reflects in final total
- ✅ Order placement includes coupon info

---

**🎉 Congratulations! You now have a production-grade coupon system!**
