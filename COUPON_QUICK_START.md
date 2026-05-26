# 🚀 Coupon System - Quick Start Guide

## 5-Minute Setup

### Step 1: Start Backend (1 min)
```bash
# Make sure PostgreSQL and Redis are running
# Then start Spring Boot
./mvnw spring-boot:run
```

The database migration will automatically create coupon tables and insert 5 sample coupons.

### Step 2: Verify Backend (1 min)
```bash
# Test the API
curl http://localhost:8080/api/coupons
```

Or run the test script:
```powershell
.\test-coupon-system.ps1
```

### Step 3: Setup Frontend (2 min)

#### Copy Files:
```bash
# Copy API service
cp COUPON_SYSTEM_FRONTEND/api/couponApi.js src/api/

# Copy pages
cp COUPON_SYSTEM_FRONTEND/pages/CouponsPage.jsx src/pages/
cp COUPON_SYSTEM_FRONTEND/pages/Cart.jsx src/pages/

# Copy styles
cp COUPON_SYSTEM_FRONTEND/styles/coupons.css src/styles/
```

#### Merge CSS:
Append `cart-coupon-additions.css` to your existing `src/styles/cart.css`

#### Add Route:
```jsx
// In your App.js
import CouponsPage from './pages/CouponsPage';

<Route path="/coupons" element={<CouponsPage />} />
```

### Step 4: Test (1 min)
1. Navigate to `http://localhost:3000/cart`
2. Add items to cart
3. Enter coupon code: `SAVE50`
4. Click "Apply"
5. See discount applied! 🎉

---

## 🎟️ Sample Coupons to Test

| Code | Description | Min Order |
|------|-------------|-----------|
| `WELCOME200` | Flat ₹200 OFF | ₹999 |
| `SAVE50` | 50% OFF up to ₹150 | ₹500 |
| `FLAT100` | Flat ₹100 OFF | ₹499 |
| `MEGA30` | 30% OFF up to ₹200 | ₹600 |

---

## ✅ Success Checklist

- [ ] Backend starts without errors
- [ ] `/api/coupons` returns 5 coupons
- [ ] Coupons page loads at `/coupons`
- [ ] Cart shows coupon input field
- [ ] Applying `SAVE50` on ₹1000 order gives ₹150 discount
- [ ] Discount reflects in total

---

## 🐛 Troubleshooting

**Backend not starting?**
- Check PostgreSQL is running
- Check Redis is running
- Check port 8080 is free

**Frontend errors?**
- Verify all files are copied
- Check import paths
- Ensure axios is configured

**Coupon not applying?**
- Check order value meets minimum
- Verify coupon code is correct (case-sensitive)
- Check browser console for errors

---

## 📚 Full Documentation

See `COUPON_SYSTEM_IMPLEMENTATION_GUIDE.md` for complete details.

---

**That's it! You're ready to use coupons! 🎉**
