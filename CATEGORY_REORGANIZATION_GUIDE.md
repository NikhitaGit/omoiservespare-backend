# Category Reorganization & Dish Update Guide

**Date**: March 3, 2026  
**Migration**: V4__reorganize_categories_and_dishes.sql

---

## 📋 WHAT CHANGED

### 1. Category Order (New Order)
The categories are now reordered with Daily Specials first:

1. **Daily Specials** (was last, now first)
2. **Breakfast** (was first, now second)
3. **Lunch** (was second, now third)
4. **Dinner** (was third, now fourth)
5. **Snacks** (was fourth, now fifth)
6. **Beverages** (was fifth, now sixth)
7. **Desserts** (new category added)

### 2. Base Dishes (15 Items)
Replaced the old 8 dishes with your 15 new base dishes:

1. Pizza
2. Burger
3. Noodles
4. Biryani
5. Idli
6. Vada
7. Dosa
8. Paratha
9. Paneer
10. Samosa
11. Chicken
12. Naan
13. Chai
14. Juice
15. Dal

### 3. Dish Variants (30 Total)
Each base dish has 2 variants:

- **Pizza**: Margherita, Pepperoni
- **Burger**: Chicken, Veggie
- **Noodles**: Chow Mein, Hakka Noodles
- **Biryani**: Chicken, Mutton
- **Idli**: Plain, Masala
- **Vada**: Medu Vada, Crispy Vada
- **Dosa**: Plain, Masala
- **Paratha**: Aloo, Paneer
- **Paneer**: Tikka, Butter Masala
- **Samosa**: Potato, Paneer
- **Chicken**: Tandoori, Butter Chicken
- **Naan**: Butter, Garlic
- **Chai**: Small, Large
- **Juice**: Orange, Mango
- **Dal**: Makhani, Tadka

### 4. Multi-Category Support
Items now appear in multiple categories:

| Dish | Categories |
|------|------------|
| Pizza | Daily Specials, Lunch, Dinner |
| Burger | Daily Specials, Lunch, Dinner |
| Noodles | Lunch, Dinner, Snacks |
| Biryani | Daily Specials, Lunch, Dinner |
| Idli | Breakfast, Lunch, Snacks |
| Vada | Breakfast, Snacks |
| Dosa | Breakfast, Lunch, Snacks |
| Paratha | Breakfast, Lunch |
| Paneer | Daily Specials, Lunch, Dinner |
| Samosa | Breakfast, Snacks |
| Chicken | Daily Specials, Lunch, Dinner |
| Naan | Lunch, Dinner |
| Chai | Breakfast, Snacks, Beverages |
| Juice | Daily Specials, Breakfast, Beverages |
| Dal | Lunch, Dinner |

---

## 🚀 HOW TO APPLY

### Step 1: Restart Application
```bash
cd omoiservespare
mvn spring-boot:run
```

Flyway will automatically:
1. Detect the new V4 migration
2. Delete old data (categories, dishes, menu items)
3. Insert new categories in correct order
4. Insert 15 new base dishes
5. Insert 30 dish variants
6. Link dishes to multiple categories
7. Insert menu items for all 4 canteens

### Step 2: Verify Changes
Check the database:

```sql
-- View categories in order
SELECT id, name FROM categories ORDER BY id;

-- View base dishes
SELECT id, name FROM base_dishes ORDER BY id;

-- View dishes (variants)
SELECT id, name FROM dishes ORDER BY id;

-- View category assignments
SELECT bd.name, c.name as category
FROM base_dish_categories bdc
JOIN base_dishes bd ON bdc.base_dish_id = bd.id
JOIN categories c ON bdc.category_id = c.id
ORDER BY bd.name, c.name;
```

### Step 3: Test Frontend
1. Start frontend: `npm run dev`
2. Login with: `user1@example.com`
3. Verify categories appear in new order
4. Click on "Daily Specials" - should show Pizza, Burger, Biryani, Paneer, Chicken, Juice
5. Click on "Breakfast" - should show Idli, Vada, Dosa, Paratha, Samosa, Chai, Juice
6. Click on a dish - should show variants with prices

---

## 📊 DATA STRUCTURE

### Categories Table
```
id | name
---|------------------
1  | Daily Specials
2  | Breakfast
3  | Lunch
4  | Dinner
5  | Snacks
6  | Beverages
7  | Desserts
```

### Base Dishes Table (15 items)
```
id | name      | food_type
---|-----------|----------
1  | Pizza     | VEG
2  | Burger    | NON_VEG
3  | Noodles   | VEG
4  | Biryani   | NON_VEG
5  | Idli      | VEG
6  | Vada      | VEG
7  | Dosa      | VEG
8  | Paratha   | VEG
9  | Paneer    | VEG
10 | Samosa    | VEG
11 | Chicken   | NON_VEG
12 | Naan      | VEG
13 | Chai      | VEG
14 | Juice     | VEG
15 | Dal       | VEG
```

### Dishes Table (30 variants)
```
id | base_dish_id | name
---|--------------|------------------
1  | 1            | Margherita Pizza
2  | 1            | Pepperoni Pizza
3  | 2            | Chicken Burger
4  | 2            | Veggie Burger
... (26 more variants)
```

### Base Dish Categories (Multi-category mapping)
```
base_dish_id | category_id
-------------|------------
1            | 1  (Pizza -> Daily Specials)
1            | 3  (Pizza -> Lunch)
1            | 4  (Pizza -> Dinner)
2            | 1  (Burger -> Daily Specials)
2            | 3  (Burger -> Lunch)
2            | 4  (Burger -> Dinner)
... (many more mappings)
```

---

## 💰 PRICING

### Canteen 1 (Main Canteen) - Sample Prices
- Margherita Pizza: ₹250
- Chicken Burger: ₹200
- Chow Mein: ₹150
- Chicken Biryani: ₹280
- Plain Idli: ₹80
- Medu Vada: ₹60
- Plain Dosa: ₹100
- Aloo Paratha: ₹120
- Paneer Tikka: ₹180
- Potato Samosa: ₹50
- Tandoori Chicken: ₹250
- Butter Naan: ₹60
- Chai (Small): ₹40
- Orange Juice: ₹80
- Dal Makhani: ₹120

Prices vary by canteen (±10-20 rupees)

---

## 🔄 MIGRATION DETAILS

### What V4 Does

1. **Deletes Old Data** (in correct order to avoid FK violations)
   - base_dish_categories
   - menu_items
   - dishes
   - base_dishes
   - categories

2. **Inserts New Categories** (7 total, in new order)

3. **Inserts New Base Dishes** (15 total)

4. **Inserts New Dishes** (30 variants, 2 per base dish)

5. **Links Dishes to Categories** (multi-category support)
   - Some dishes appear in 2-3 categories
   - Example: Pizza appears in Daily Specials, Lunch, Dinner

6. **Inserts Menu Items** (30 dishes × 4 canteens = 120 items)
   - Different prices per canteen
   - Different prep times per canteen

---

## ✅ VERIFICATION CHECKLIST

After applying the migration:

- [ ] Application starts without errors
- [ ] Flyway shows V4 migration applied
- [ ] 7 categories in database
- [ ] 15 base dishes in database
- [ ] 30 dish variants in database
- [ ] 120 menu items in database
- [ ] Categories appear in correct order on frontend
- [ ] Daily Specials shows correct items
- [ ] Breakfast shows correct items
- [ ] Items appear in multiple categories
- [ ] Prices display correctly
- [ ] Variants display correctly

---

## 🐛 TROUBLESHOOTING

### Issue: Migration fails with FK error
**Solution**: The migration deletes data in correct order. If error persists:
1. Check if there are other tables referencing these tables
2. Manually delete data in correct order
3. Re-run migration

### Issue: Categories not in new order
**Solution**: 
1. Check database: `SELECT id, name FROM categories ORDER BY id;`
2. Verify IDs match expected order
3. Frontend should display in order of category ID

### Issue: Items not appearing in multiple categories
**Solution**:
1. Check base_dish_categories table
2. Verify multiple rows exist for same base_dish_id
3. Example: Pizza should have 3 rows (Daily Specials, Lunch, Dinner)

### Issue: Old data still showing
**Solution**:
1. Clear browser cache
2. Restart frontend
3. Verify database was updated: `SELECT COUNT(*) FROM base_dishes;` (should be 15)

---

## 📝 NOTES

- **Flyway Automatic**: No manual SQL execution needed
- **Data Loss**: Old data is deleted. If you need it, backup first
- **Reversible**: You can create V5 migration to revert if needed
- **Multi-Category**: Items can appear in multiple categories
- **Pricing**: Each canteen has different prices for same item
- **Variants**: Each base dish has 2 variants

---

## 🔄 NEXT STEPS

### If You Want to Add More Items
Create a new migration (V5):

```sql
-- V5__add_more_dishes.sql
INSERT INTO base_dishes (name, food_type, default_image_url, is_active)
VALUES ('New Dish', 'VEG', 'https://example.com/new-dish.jpg', true);

-- Get the ID of the new dish
-- Then insert variants, menu items, and category links
```

### If You Want to Change Prices
Create a new migration (V5):

```sql
-- V5__update_prices.sql
UPDATE menu_items SET price = 300.00 WHERE dish_id = 1 AND canteen_id = 1;
```

### If You Want to Add New Categories
Create a new migration (V5):

```sql
-- V5__add_new_category.sql
INSERT INTO categories (name, is_active) VALUES ('New Category', true);

-- Then link dishes to this category
INSERT INTO base_dish_categories (base_dish_id, category_id)
VALUES (1, 8); -- Link Pizza to new category
```

---

## 📞 SUPPORT

For questions:
1. Check this guide
2. Review the migration file: `V4__reorganize_categories_and_dishes.sql`
3. Check database directly
4. Review application logs

---

**Status**: ✅ Ready to Apply  
**Date**: March 3, 2026  
**Version**: 1.0.0

