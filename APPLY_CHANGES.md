# How to Apply Changes - Quick Start

**Date**: March 3, 2026

---

## ⚡ QUICK START (2 Steps)

### Step 1: Restart Backend
```bash
cd omoiservespare
mvn spring-boot:run
```

### Step 2: Done! ✅
Flyway automatically applies the V4 migration.

---

## 📋 WHAT HAPPENS AUTOMATICALLY

When you restart the backend:

1. ✅ Flyway detects V4 migration
2. ✅ Deletes old categories, dishes, menu items
3. ✅ Inserts 7 new categories (Daily Specials first)
4. ✅ Inserts 15 new base dishes
5. ✅ Inserts 30 dish variants
6. ✅ Links dishes to multiple categories
7. ✅ Inserts 120 menu items (30 × 4 canteens)

---

## 🔍 VERIFY IT WORKED

### Check Logs
Look for these messages in terminal:
```
Flyway successfully validated
V4__reorganize_categories_and_dishes.sql
```

### Check Database
```bash
psql -U postgres -d omoiservespare_db

# View categories
SELECT id, name FROM categories ORDER BY id;

# Should show:
# 1 | Daily Specials
# 2 | Breakfast
# 3 | Lunch
# 4 | Dinner
# 5 | Snacks
# 6 | Beverages
# 7 | Desserts
```

### Check Frontend
1. Start frontend: `npm run dev`
2. Login with: `user1@example.com`
3. Verify categories in new order
4. Click "Daily Specials" - should show Pizza, Burger, Biryani, etc.
5. Click "Breakfast" - should show Idli, Vada, Dosa, etc.

---

## 📊 WHAT CHANGED

### Categories
- **Old**: Breakfast, Lunch, Dinner, Snacks, Beverages, Daily Specials
- **New**: Daily Specials, Breakfast, Lunch, Dinner, Snacks, Beverages, Desserts

### Base Dishes
- **Old**: 8 dishes (Biryani, Butter Chicken, Paneer Tikka, etc.)
- **New**: 15 dishes (Pizza, Burger, Noodles, Biryani, Idli, Vada, Dosa, Paratha, Paneer, Samosa, Chicken, Naan, Chai, Juice, Dal)

### Multi-Category
- **Old**: Each item in 1 category
- **New**: Items in multiple categories (e.g., Pizza in Daily Specials, Lunch, Dinner)

### Total Items
- **Old**: 64 menu items (16 variants × 4 canteens)
- **New**: 120 menu items (30 variants × 4 canteens)

---

## 📁 FILES CREATED

1. **V4__reorganize_categories_and_dishes.sql** (Migration file)
   - Location: `src/main/resources/db/migration/`
   - Automatically applied by Flyway

2. **CATEGORY_REORGANIZATION_GUIDE.md** (Detailed guide)
   - Complete documentation
   - Troubleshooting tips
   - Verification checklist

3. **CATEGORY_STRUCTURE.md** (Visual guide)
   - Shows all items by category
   - Price ranges
   - Usage examples

4. **CHANGES_SUMMARY.md** (Quick overview)
   - Before/after comparison
   - Quick reference

5. **APPLY_CHANGES.md** (This file)
   - How to apply changes
   - Quick verification

---

## ✅ VERIFICATION CHECKLIST

After restarting backend:

- [ ] Backend starts without errors
- [ ] Flyway shows V4 migration applied
- [ ] Frontend loads correctly
- [ ] Login works
- [ ] Categories appear in new order
- [ ] Daily Specials is first
- [ ] Breakfast is second
- [ ] Clicking categories shows correct items
- [ ] Multi-category items appear correctly
- [ ] Prices display correctly
- [ ] All 4 canteens show for each item

---

## 🐛 TROUBLESHOOTING

### Issue: Backend won't start
**Solution**: 
1. Check Java version: `java -version` (should be 17+)
2. Check Maven: `mvn -version`
3. Check PostgreSQL is running
4. Check database connection in `application.properties`

### Issue: Flyway migration fails
**Solution**:
1. Check database connection
2. Check if V4 file exists: `src/main/resources/db/migration/V4__reorganize_categories_and_dishes.sql`
3. Check logs for error message
4. Restart backend

### Issue: Categories not in new order
**Solution**:
1. Clear browser cache
2. Restart frontend
3. Check database: `SELECT id, name FROM categories ORDER BY id;`
4. Verify IDs match expected order

### Issue: Items not showing in multiple categories
**Solution**:
1. Check database: `SELECT COUNT(*) FROM base_dish_categories;` (should be 40+)
2. Verify Pizza has 3 category mappings
3. Restart frontend

### Issue: Old data still showing
**Solution**:
1. Verify V4 migration ran: Check `flyway_schema_history` table
2. Clear browser cache
3. Restart frontend
4. Check database directly

---

## 📞 SUPPORT

For detailed information:
- **CATEGORY_REORGANIZATION_GUIDE.md** - Complete guide
- **CATEGORY_STRUCTURE.md** - Visual structure
- **CHANGES_SUMMARY.md** - Before/after comparison

---

## 🎯 NEXT STEPS

1. **Restart Backend** ← You are here
   ```bash
   mvn spring-boot:run
   ```

2. **Verify Changes**
   - Check logs
   - Check database
   - Test frontend

3. **Test Features**
   - Login
   - Browse categories
   - Search items
   - View prices

4. **Deploy** (if ready)
   - Build: `mvn clean package`
   - Deploy JAR file
   - Restart application

---

## 📝 NOTES

- **Automatic**: No manual SQL needed
- **Reversible**: Can create V5 to revert if needed
- **Data Loss**: Old data is deleted (backup if needed)
- **Multi-Category**: Items appear in multiple categories
- **Pricing**: Each canteen has different prices

---

**Status**: ✅ Ready to Apply  
**Date**: March 3, 2026  
**Version**: 1.0.0

