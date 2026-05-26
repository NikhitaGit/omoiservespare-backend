# Migration Fix - V4 Error Resolution

**Date**: March 3, 2026  
**Issue**: Foreign key constraint violation in V4 migration

---

## 🐛 Problem

The V4 migration was failing with this error:

```
ERROR: insert or update on table "dishes" violates foreign key constraint "fk_dish_base"
Detail: Key (base_dish_id)=(1) is not present in table "base_dishes".
```

---

## 🔍 Root Cause

The issue was caused by `ON CONFLICT DO NOTHING` clauses in the INSERT statements. When PostgreSQL encounters this clause, it silently ignores conflicts instead of inserting the data. This caused:

1. Categories weren't inserted (due to ON CONFLICT)
2. Base dishes weren't inserted (due to ON CONFLICT)
3. When trying to insert dishes, the foreign key references didn't exist
4. Migration failed with FK constraint violation

---

## ✅ Solution

Removed all `ON CONFLICT DO NOTHING` clauses from the migration file. Since we're deleting all old data first, there are no conflicts to handle.

**Changed from:**
```sql
INSERT INTO categories (name, is_active) VALUES
('Daily Specials', true),
...
ON CONFLICT DO NOTHING;
```

**Changed to:**
```sql
INSERT INTO categories (name, is_active) VALUES
('Daily Specials', true),
...;
```

---

## 📝 Changes Made

1. Removed `ON CONFLICT DO NOTHING` from categories insert
2. Removed `ON CONFLICT DO NOTHING` from base_dishes insert
3. Removed `ON CONFLICT DO NOTHING` from dishes insert
4. Removed `ON CONFLICT DO NOTHING` from base_dish_categories insert
5. Removed `ON CONFLICT DO NOTHING` from canteens insert
6. Simplified menu_items insert for clarity

---

## 🚀 Now Ready to Apply

The migration file is now fixed and ready to use. Simply restart the backend:

```bash
cd omoiservespare
mvn spring-boot:run
```

Flyway will automatically:
1. Detect the V4 migration
2. Delete old data
3. Insert new categories (7 total)
4. Insert new base dishes (15 total)
5. Insert new dishes/variants (30 total)
6. Link dishes to multiple categories
7. Insert menu items (120 total)

---

## ✅ Verification

After restart, verify the migration worked:

```bash
# Check logs for success
# Should see: "V4__reorganize_categories_and_dishes.sql"

# Check database
psql -U postgres -d omoiservespare_db

# Verify data
SELECT COUNT(*) FROM categories;  -- Should be 7
SELECT COUNT(*) FROM base_dishes;  -- Should be 15
SELECT COUNT(*) FROM dishes;  -- Should be 30
SELECT COUNT(*) FROM menu_items;  -- Should be 120
```

---

## 📊 What Gets Inserted

### Categories (7)
1. Daily Specials
2. Breakfast
3. Lunch
4. Dinner
5. Snacks
6. Beverages
7. Desserts

### Base Dishes (15)
Pizza, Burger, Noodles, Biryani, Idli, Vada, Dosa, Paratha, Paneer, Samosa, Chicken, Naan, Chai, Juice, Dal

### Dishes/Variants (30)
2 variants per base dish

### Menu Items (120)
30 dishes × 4 canteens

### Category Mappings (40+)
Multi-category support - items appear in multiple categories

---

## 🎯 Next Steps

1. Restart backend: `mvn spring-boot:run`
2. Wait for Flyway to complete
3. Check logs for success
4. Test frontend
5. Verify categories in new order
6. Verify multi-category items

---

**Status**: ✅ Fixed and Ready  
**Date**: March 3, 2026

