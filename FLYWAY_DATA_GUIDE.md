# Flyway Data Management Guide

## Overview
You're now using Flyway for database migrations. Here's how to manage data:

## Two Approaches for Data Management

### 1. **SQL Migration Scripts** (Recommended for seed/static data)
Use Flyway SQL files for data that should be inserted during database setup.

**Location:** `src/main/resources/db/migration/`

**Naming Convention:** `V{number}__{description}.sql`
- `V1__initial_schema.sql` - Schema creation (already exists)
- `V2__insert_seed_data.sql` - Seed data (already created)
- `V3__add_more_data.sql` - Additional data
- `V4__update_existing_data.sql` - Updates

**Example:**
```sql
INSERT INTO categories (name, is_active) VALUES
('Breakfast', true),
('Lunch', true)
ON CONFLICT DO NOTHING;
```

**Key Points:**
- Flyway runs migrations in order (V1, V2, V3, etc.)
- Each migration runs only once
- Use `ON CONFLICT DO NOTHING` to avoid duplicate key errors
- Migrations are tracked in `flyway_schema_history` table

### 2. **DataInitializer Component** (For dynamic/runtime data)
Use Java code for data that needs logic or should be created on every startup.

**Location:** `src/main/java/com/omoikaneinnovations/omoiservespare/config/DataInitializer.java`

**When to use:**
- Sample users for testing
- Default configurations
- Data that depends on application logic
- Data that should be refreshed on startup

**Example:**
```java
@EventListener(ApplicationReadyEvent.class)
public void init() {
    // Your data initialization logic
    userRepository.save(user);
}
```

## Workflow for Adding Data

### Step 1: Add Static/Seed Data
Create a new migration file:
```
V3__add_more_canteens.sql
```

```sql
INSERT INTO canteens (name, place, prep_time, rating, image_url, is_active) VALUES
('New Canteen', 'Building D', '30 mins', 4.5, 'url', true);
```

### Step 2: Add Dynamic Data
Update `DataInitializer.java`:
```java
private void initializeSampleUsers() {
    // Add your logic here
}
```

### Step 3: Restart Application
```bash
mvn spring-boot:run
```

Flyway will:
1. Check `flyway_schema_history` table
2. Run any new migrations (V2, V3, etc.)
3. Execute DataInitializer on startup

## Important Notes

### ✅ DO:
- Use version numbers in order (V1, V2, V3...)
- Use `ON CONFLICT DO NOTHING` for idempotent inserts
- Keep migrations small and focused
- Test migrations locally before deploying
- Use DataInitializer for test/sample data

### ❌ DON'T:
- Modify existing migration files (V1, V2, etc.)
- Skip version numbers (V1, V3, V5 - missing V2, V4)
- Use `DELETE` or `DROP` in migrations without careful consideration
- Manually edit `flyway_schema_history` table

## Checking Migration Status

View applied migrations:
```sql
SELECT * FROM flyway_schema_history;
```

## Troubleshooting

### Migration Failed
If a migration fails:
1. Check the error in application logs
2. Fix the SQL file
3. Create a new migration file (V3, V4, etc.) with the fix
4. Restart the application

### Need to Reset Database
```bash
# Drop and recreate database
psql -U postgres -c "DROP DATABASE omoiservespare_db;"
psql -U postgres -c "CREATE DATABASE omoiservespare_db;"

# Restart application - Flyway will run all migrations from scratch
mvn spring-boot:run
```

## Current Data Structure

### Seed Data (V2__insert_seed_data.sql)
- 6 Categories (Breakfast, Lunch, Dinner, Snacks, Beverages, Desserts)
- 8 Base Dishes (Biryani, Butter Chicken, Paneer Tikka, etc.)
- 16 Dish Variants
- 4 Canteens
- 64 Menu Items (16 per canteen)

### Sample Users (DataInitializer.java)
- latabenakop1@gmail.com (Professional)
- test@example.com (Professional)
- customer@example.com (Customer)

## Next Steps

1. **Add more canteens/dishes:** Create `V3__add_more_data.sql`
2. **Add orders:** Create `V4__add_sample_orders.sql`
3. **Update prices:** Create `V5__update_menu_prices.sql`
4. **Add more users:** Update `DataInitializer.java`

## Example: Adding More Data

Create `src/main/resources/db/migration/V3__add_premium_canteen.sql`:

```sql
INSERT INTO canteens (name, place, prep_time, rating, image_url, is_active) VALUES
('Premium Canteen', 'VIP Floor', '15 mins', 5.0, 'https://example.com/premium.jpg', true);

-- Add menu items for premium canteen
INSERT INTO menu_items (canteen_id, dish_id, price, is_available, prep_min) VALUES
(5, 1, 350.00, true, 15),
(5, 2, 380.00, true, 15);
```

Then restart the application - Flyway will automatically run this migration!
