# Duplicate Data Issue - Fixed ✅

## The Problem
Canteens were appearing **twice** in the database and frontend:
- IDs 1-4: Main Canteen, North Wing Canteen, South Wing Canteen, Cafeteria
- IDs 5-8: Same canteens duplicated

## Root Cause
1. V2 migration ran and inserted canteens (IDs 1-4)
2. We deleted V2 from `flyway_schema_history` to fix checksum error
3. V2 ran again and inserted canteens again (IDs 5-8)
4. `ON CONFLICT DO NOTHING` didn't work because there was no UNIQUE constraint on canteen name

## The Solution

### Step 1: Delete Duplicates
```sql
DELETE FROM canteens WHERE id > 4;
```

### Step 2: Add UNIQUE Constraints
Created `V3__add_unique_constraints.sql`:
```sql
ALTER TABLE canteens ADD CONSTRAINT unique_canteen_name UNIQUE (name);
ALTER TABLE categories ADD CONSTRAINT unique_category_name UNIQUE (name);
ALTER TABLE base_dishes ADD CONSTRAINT unique_base_dish_name UNIQUE (name);
```

### Step 3: Restart Application
```bash
mvn spring-boot:run
```

Flyway automatically ran V3 and added the constraints.

## Result ✅

**Before:**
```
8 canteens (4 duplicates)
```

**After:**
```
4 canteens (no duplicates)
✅ Unique constraints added
✅ Frontend displays correctly
```

## How It Works Now

With UNIQUE constraints:
- If you try to insert duplicate canteen name → Database rejects it
- `ON CONFLICT DO NOTHING` now works properly
- Safe to re-run migrations without duplicates

## Migrations Applied

```
V1 - initial schema (12 tables)
V2 - insert seed data (categories, dishes, canteens, menu items)
V3 - add unique constraints (prevents duplicates)
```

## Key Lesson

**Always add UNIQUE constraints for data that should be unique!**

### Best Practices:
1. ✅ Add UNIQUE constraints in schema migration (V1)
2. ✅ Use `ON CONFLICT DO NOTHING` for safe inserts
3. ✅ Create new migrations for schema changes (V3, V4, etc.)
4. ✅ Never modify existing migrations after they're applied

---

**Status**: ✅ Fixed - No more duplicates
**Database**: Clean with 4 canteens
**Frontend**: Displays correctly
