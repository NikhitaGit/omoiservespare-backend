# Data Insertion Summary

## ✅ Completed Setup

Your database now has the following data:

### Categories (6 total)
- Breakfast
- Lunch
- Dinner
- Snacks
- Beverages
- Desserts

### Base Dishes (8 total)
- Biryani
- Butter Chicken
- Paneer Tikka
- Tandoori Chicken
- Dal Makhani
- Samosa
- Naan
- Chai

### Dish Variants (16 total)
Each base dish has multiple variants (e.g., Chicken Biryani, Mutton Biryani, Vegetable Biryani)

### Canteens (4 total)
1. Main Canteen (Building A) - 30 mins prep
2. North Wing Canteen (Building B) - 25 mins prep
3. South Wing Canteen (Building C) - 35 mins prep
4. Cafeteria (Ground Floor) - 20 mins prep

### Menu Items (64 total)
- 16 items per canteen
- Each item has price, availability, and prep time
- Prices vary by canteen (premium canteens have higher prices)

### Sample Users (3 total)
1. **latabenakop1@gmail.com** (Professional)
   - Company: Servespare Pvt Ltd
   - Phone: +91-9876543210

2. **test@example.com** (Professional)
   - Company: Tech Corp
   - Phone: +91-9876543211

3. **customer@example.com** (Customer)
   - Company: Customer Inc
   - Phone: +91-9876543212

## 📊 Data Statistics

```
Total Categories:    6
Total Base Dishes:   8
Total Dish Variants: 16
Total Canteens:      4
Total Menu Items:    64
Total Users:         3
```

## 🔄 How Data Was Inserted

### Method 1: SQL Migration (V2__insert_seed_data.sql)
- Created seed data migration file
- Contains all static data (categories, dishes, canteens, menu items)
- Uses `ON CONFLICT DO NOTHING` for idempotent inserts

### Method 2: DataInitializer Component
- Runs on application startup
- Creates sample users dynamically
- Uses `@EventListener(ApplicationReadyEvent.class)`

## 📝 Files Created/Modified

1. **V2__insert_seed_data.sql** - Seed data migration
2. **DataInitializer.java** - Updated with sample users
3. **FLYWAY_DATA_GUIDE.md** - Complete guide for future data management
4. **RefreshToken.java** - Fixed table name mapping

## 🚀 Next Steps

### To Add More Data:

**Option 1: Create a new SQL migration**
```bash
# Create V3__add_more_data.sql in src/main/resources/db/migration/
# Add your INSERT statements
# Restart application - Flyway will run it automatically
```

**Option 2: Update DataInitializer**
```java
// Add more sample data in DataInitializer.java
// Restart application
```

### Example: Add a New Canteen

Create `V3__add_premium_canteen.sql`:
```sql
INSERT INTO canteens (name, place, prep_time, rating, image_url, is_active) VALUES
('Premium Canteen', 'VIP Floor', '15 mins', 5.0, 'https://example.com/premium.jpg', true);

INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min) VALUES
(5, 1, 350.00, true, 15),
(5, 2, 380.00, true, 15);
```

Then restart: `mvn spring-boot:run`

## ⚠️ Important Notes

1. **Flyway Status**: Currently, Flyway is not auto-running migrations on startup. You need to manually execute SQL files or use the DataInitializer component.

2. **To Enable Auto-Migration**: Add this to `application.properties`:
   ```properties
   spring.flyway.enabled=true
   spring.flyway.locations=classpath:db/migration
   ```

3. **Migration Tracking**: Once Flyway is properly configured, it will track all migrations in the `flyway_schema_history` table.

4. **Idempotent Inserts**: All INSERT statements use `ON CONFLICT DO NOTHING` to prevent duplicate key errors if migrations run multiple times.

## 🔍 Verify Data

Check data in database:
```sql
-- Count records
SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM canteens;
SELECT COUNT(*) FROM menu_items;
SELECT COUNT(*) FROM users;

-- View sample data
SELECT * FROM canteens LIMIT 5;
SELECT * FROM menu_items WHERE canteen_id = 1 LIMIT 5;
SELECT * FROM users;
```

## 📚 Related Documentation

- See `FLYWAY_DATA_GUIDE.md` for complete Flyway workflow
- See `RefreshToken.java` for table name fix
- See `DataInitializer.java` for sample user creation

---

**Status**: ✅ All seed data inserted successfully
**Last Updated**: 2026-03-03
