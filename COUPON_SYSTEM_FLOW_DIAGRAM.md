# 🎟️ Coupon System - Flow Diagrams

## 1. Apply Coupon from Cart Flow

```
┌─────────────┐
│    User     │
│  (Cart Page)│
└──────┬──────┘
       │
       │ 1. Enters coupon code "SAVE50"
       │    Order value: ₹1500
       ▼
┌──────────────────┐
│   Frontend       │
│   Cart.jsx       │
└──────┬───────────┘
       │
       │ 2. POST /api/coupons/validate
       │    { couponCode: "SAVE50", orderValue: 1500 }
       ▼
┌──────────────────────────┐
│   Backend                │
│   CouponController       │
└──────┬───────────────────┘
       │
       │ 3. validateCoupon()
       ▼
┌──────────────────────────┐
│   CouponService          │
│   - Check Redis cache    │
│   - Validate rules       │
│   - Calculate discount   │
└──────┬───────────────────┘
       │
       │ 4. Check Redis
       ▼
┌──────────────────┐     Cache Hit
│     Redis        │────────────┐
│  coupon:SAVE50   │            │
└──────┬───────────┘            │
       │ Cache Miss             │
       │                        │
       │ 5. Query DB            │
       ▼                        │
┌──────────────────┐            │
│   PostgreSQL     │            │
│   coupons table  │            │
└──────┬───────────┘            │
       │                        │
       │ 6. Coupon found        │
       ├────────────────────────┘
       │
       │ 7. Validate Rules:
       │    ✓ Is active?
       │    ✓ Not expired?
       │    ✓ Min order met? (₹500 < ₹1500) ✓
       │    ✓ Usage limit ok?
       │    ✓ User limit ok?
       │
       │ 8. Calculate Discount:
       │    Type: PERCENTAGE (50%)
       │    Calculation: ₹1500 × 50% = ₹750
       │    Max discount: ₹150
       │    Final: ₹150 (capped)
       ▼
┌──────────────────────────┐
│   Response               │
│   {                      │
│     isValid: true,       │
│     discount: 150,       │
│     message: "You saved  │
│              ₹150"       │
│   }                      │
└──────┬───────────────────┘
       │
       │ 9. Return to frontend
       ▼
┌──────────────────┐
│   Frontend       │
│   - Show success │
│   - Update UI    │
│   - Recalculate  │
│     total        │
└──────┬───────────┘
       │
       │ 10. Display Updated Bill:
       │     Subtotal:    ₹1500.00
       │     CGST (2.5%): ₹37.50
       │     SGST (2.5%): ₹37.50
       │     Discount:    -₹150.00
       │     ─────────────────────
       │     Total:       ₹1425.00
       ▼
┌──────────────────┐
│   User sees      │
│   discount       │
│   applied! 🎉    │
└──────────────────┘
```

---

## 2. Browse Coupons Flow

```
┌─────────────┐
│    User     │
│  (Cart Page)│
└──────┬──────┘
       │
       │ 1. Clicks "View all coupons"
       ▼
┌──────────────────┐
│   Navigate to    │
│   /coupons       │
│   with state:    │
│   { orderValue:  │
│     1500,        │
│     fromCart:    │
│     true }       │
└──────┬───────────┘
       │
       │ 2. GET /api/coupons
       ▼
┌──────────────────────────┐
│   Backend                │
│   Returns all active     │
│   coupons                │
└──────┬───────────────────┘
       │
       │ 3. Display coupons
       ▼
┌──────────────────────────┐
│   CouponsPage.jsx        │
│                          │
│   ┌────────────────┐     │
│   │ WELCOME200     │     │
│   │ ₹200 OFF       │     │
│   │ Min: ₹999      │     │
│   │ [Apply]        │     │
│   └────────────────┘     │
│                          │
│   ┌────────────────┐     │
│   │ SAVE50         │     │
│   │ 50% OFF        │     │
│   │ Min: ₹500      │     │
│   │ [Apply]        │     │
│   └────────────────┘     │
└──────┬───────────────────┘
       │
       │ 4. User clicks "Apply" on SAVE50
       ▼
┌──────────────────────────┐
│   Validate coupon        │
│   POST /api/coupons/     │
│   validate               │
└──────┬───────────────────┘
       │
       │ 5. If valid
       ▼
┌──────────────────────────┐
│   Navigate back to cart  │
│   with state:            │
│   {                      │
│     appliedCoupon: {     │
│       code: "SAVE50",    │
│       discount: 150      │
│     }                    │
│   }                      │
└──────┬───────────────────┘
       │
       │ 6. Cart receives coupon
       ▼
┌──────────────────────────┐
│   Cart automatically     │
│   applies discount       │
│   and updates total      │
└──────────────────────────┘
```

---

## 3. Order Placement with Coupon

```
┌─────────────┐
│    User     │
│  (Cart Page)│
└──────┬──────┘
       │
       │ 1. Clicks "Pay ₹1425"
       │    (with SAVE50 applied)
       ▼
┌──────────────────────────┐
│   POST /api/orders       │
│   {                      │
│     items: "...",        │
│     totalAmount: 1425,   │
│     couponCode: "SAVE50",│
│     discountAmount: 150  │
│   }                      │
└──────┬───────────────────┘
       │
       │ 2. Backend processes order
       ▼
┌──────────────────────────┐
│   OrderService           │
│   - Create order         │
│   - Apply coupon         │
└──────┬───────────────────┘
       │
       │ 3. applyCoupon()
       ▼
┌──────────────────────────┐
│   CouponService          │
│   - Acquire lock         │
│   - Re-validate          │
│   - Record usage         │
└──────┬───────────────────┘
       │
       │ 4. Distributed Lock
       ▼
┌──────────────────────────┐
│   Redis                  │
│   SET coupon_lock:       │
│   SAVE50:user123         │
│   "locked" EX 10         │
└──────┬───────────────────┘
       │
       │ 5. Lock acquired
       │
       │ 6. Re-validate coupon
       │    (prevent race conditions)
       ▼
┌──────────────────────────┐
│   Validation passed      │
└──────┬───────────────────┘
       │
       │ 7. Record usage
       ▼
┌──────────────────────────┐
│   PostgreSQL             │
│   INSERT INTO            │
│   coupon_usage           │
│   (coupon_id, user_id,   │
│    order_id, discount)   │
└──────┬───────────────────┘
       │
       │ 8. Release lock
       ▼
┌──────────────────────────┐
│   Redis                  │
│   DEL coupon_lock:       │
│   SAVE50:user123         │
└──────┬───────────────────┘
       │
       │ 9. Order created
       ▼
┌──────────────────────────┐
│   Navigate to payment    │
│   with invoice data      │
└──────────────────────────┘
```

---

## 4. Validation Rules Flow

```
┌──────────────────────────┐
│   Coupon Validation      │
└──────┬───────────────────┘
       │
       ├─► Rule 1: Is Active?
       │   ├─ Yes → Continue
       │   └─ No  → ❌ "Coupon is not active"
       │
       ├─► Rule 2: Date Valid?
       │   ├─ Not started → ❌ "Not yet valid"
       │   ├─ Expired     → ❌ "Coupon expired"
       │   └─ Valid       → Continue
       │
       ├─► Rule 3: Min Order Value?
       │   ├─ Order < Min → ❌ "Min order ₹X required"
       │   └─ Order ≥ Min → Continue
       │
       ├─► Rule 4: Total Usage Limit?
       │   ├─ Limit reached → ❌ "Usage limit reached"
       │   └─ Under limit   → Continue
       │
       ├─► Rule 5: Per-User Limit?
       │   ├─ User maxed out → ❌ "Already used"
       │   └─ Can use        → Continue
       │
       ├─► Rule 6: First Order Only?
       │   ├─ Not first → ❌ "First order only"
       │   └─ Is first  → Continue
       │
       └─► All Rules Passed ✅
           │
           ├─► Calculate Discount
           │   │
           │   ├─ PERCENTAGE:
           │   │  discount = order × (value/100)
           │   │  if discount > maxDiscount:
           │   │    discount = maxDiscount
           │   │
           │   ├─ FLAT:
           │   │  discount = value
           │   │  if discount > order:
           │   │    discount = order
           │   │
           │   └─ CASHBACK:
           │      discount = 0 (credited later)
           │
           └─► Return Success Response
```

---

## 5. Caching Strategy

```
┌──────────────────────────┐
│   Request for coupon     │
│   "SAVE50"               │
└──────┬───────────────────┘
       │
       ├─► Check Redis Cache
       │   Key: "coupon:SAVE50"
       │
       ├─ Cache Hit (90% of requests)
       │  └─► Return from cache (< 1ms)
       │
       └─ Cache Miss (10% of requests)
          │
          ├─► Query PostgreSQL
          │   SELECT * FROM coupons
          │   WHERE code = 'SAVE50'
          │
          ├─► Store in Redis
          │   SET coupon:SAVE50 {data}
          │   EXPIRE 300 (5 minutes)
          │
          └─► Return data

┌──────────────────────────┐
│   Cache Invalidation     │
└──────┬───────────────────┘
       │
       ├─► On coupon applied:
       │   DEL coupon:SAVE50
       │
       ├─► On coupon updated:
       │   DEL coupon:SAVE50
       │
       └─► Auto-expire:
           After 5 minutes
```

---

## 6. Race Condition Prevention

```
User A                    User B
  │                         │
  ├─► Apply SAVE50          │
  │   (Last usage)          │
  │                         │
  ├─► Acquire lock          ├─► Apply SAVE50
  │   ✓ Success             │   (Same coupon)
  │                         │
  ├─► Validate              ├─► Try acquire lock
  │   ✓ Usage: 999/1000     │   ✗ Locked! Wait...
  │                         │
  ├─► Record usage          │
  │   Usage: 1000/1000      │
  │                         │
  ├─► Release lock          │
  │                         │
  │                         ├─► Acquire lock
  │                         │   ✓ Success
  │                         │
  │                         ├─► Validate
  │                         │   ✗ Usage: 1000/1000
  │                         │   ❌ "Limit reached"
  │                         │
  │                         └─► Release lock
  │
  └─► ✅ Success            └─► ❌ Failed

Without lock: Both could succeed (race condition)
With lock: Only one succeeds (correct behavior)
```

---

## 7. Database Schema Relationships

```
┌─────────────────────────┐
│      coupons            │
│─────────────────────────│
│ id (PK)                 │
│ code (UNIQUE)           │
│ discount_type           │
│ discount_value          │
│ min_order_value         │
│ start_date              │
│ end_date                │
│ total_usage_limit       │
│ per_user_limit          │
│ is_active               │
└──────┬──────────────────┘
       │
       │ 1:N
       │
       ▼
┌─────────────────────────┐
│   coupon_usage          │
│─────────────────────────│
│ id (PK)                 │
│ coupon_id (FK)          │◄─────┐
│ user_id (FK)            │      │
│ order_id                │      │
│ discount_applied        │      │
│ used_at                 │      │
└─────────────────────────┘      │
                                 │
┌─────────────────────────┐      │
│   coupon_restaurants    │      │
│─────────────────────────│      │
│ coupon_id (FK)          │──────┘
│ restaurant_id (FK)      │
└─────────────────────────┘

┌─────────────────────────┐
│   user_coupons          │
│─────────────────────────│
│ id (PK)                 │
│ user_id (FK)            │
│ coupon_id (FK)          │──────┐
│ assigned_at             │      │
│ expires_at              │      │
│ is_used                 │      │
└─────────────────────────┘      │
                                 │
                                 │
                    ┌────────────┘
                    │
                    ▼
            (Targeted Marketing)
```

---

**🎉 These flows show how the production-grade coupon system works end-to-end!**
