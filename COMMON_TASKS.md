# Common Tasks & Quick Reference

---

## 🚀 Starting the Application

### Backend
```bash
cd omoiservespare
mvn spring-boot:run
```
- Runs on `http://localhost:8080`
- Flyway migrations run automatically
- Check logs for "Flyway successfully validated" message

### Frontend
```bash
npm run dev
```
- Runs on `http://localhost:5173`
- Hot reload enabled

---

## 🗄️ Database Operations

### Connect to PostgreSQL
```bash
psql -U postgres -d omoiservespare_db
```

### View All Tables
```sql
\dt
```

### Check Flyway Migration History
```sql
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC;
```

### View Seed Data

**Canteens:**
```sql
SELECT * FROM canteens;
```

**Categories:**
```sql
SELECT * FROM categories;
```

**Base Dishes:**
```sql
SELECT * FROM base_dishes;
```

**Dish Variants:**
```sql
SELECT * FROM dishes;
```

**Menu Items (with prices):**
```sql
SELECT m.id, d.name, c.name as canteen, m.price 
FROM menu_items m
JOIN dishes d ON m.dish_id = d.id
JOIN canteens c ON m.canteen_id = c.id
ORDER BY c.name, d.name;
```

**Users:**
```sql
SELECT * FROM users;
```

**OTPs:**
```sql
SELECT * FROM otps;
```

**Refresh Tokens:**
```sql
SELECT * FROM refresh_tokens;
```

---

## 🔄 Making Data Changes

### ⚠️ IMPORTANT: Use Migrations, Not Direct SQL

**DO NOT** modify data directly in the database for production changes.

### Creating a New Migration

1. Create a new file: `src/main/resources/db/migration/V4__description.sql`
2. Write your SQL changes
3. Restart the application
4. Flyway will automatically run the new migration

### Example: Add a New Canteen

**File**: `src/main/resources/db/migration/V4__add_new_canteen.sql`
```sql
INSERT INTO canteens (name, location, phone_number, email) 
VALUES ('West Wing Canteen', 'Building C', '9876543210', 'west@example.com');
```

### Example: Add a New Dish Variant

**File**: `src/main/resources/db/migration/V5__add_paneer_variants.sql`
```sql
-- Add new variants for Paneer Tikka
INSERT INTO dishes (name, base_dish_id, food_type, is_active) 
VALUES 
  ('Paneer Tikka Masala', 3, 'VEG', true),
  ('Paneer Tikka Dry', 3, 'VEG', true);

-- Add menu items for all canteens
INSERT INTO menu_items (dish_id, canteen_id, price, is_available, prep_min)
SELECT d.id, c.id, 250.00, true, 15
FROM dishes d, canteens c
WHERE d.name IN ('Paneer Tikka Masala', 'Paneer Tikka Dry');
```

---

## 🧪 Testing the API

### Using cURL

**Login (Send OTP):**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoikane",
    "email": "user1@example.com",
    "phoneNumber": "9876543210",
    "accountType": "EMPLOYEE"
  }'
```

**Verify OTP:**
```bash
curl -X POST http://localhost:8080/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: device-123" \
  -d '{
    "email": "user1@example.com",
    "otp": "1234"
  }'
```

**Get Home Menu:**
```bash
curl http://localhost:8080/api/menu/home
```

**Search Menu:**
```bash
curl "http://localhost:8080/api/menu/search?name=Biryani"
```

**Get Categories:**
```bash
curl http://localhost:8080/api/categories
```

**Get Canteen Menu:**
```bash
curl http://localhost:8080/api/menu/canteen/1
```

---

## 🐛 Troubleshooting

### Issue: "Flyway validation failed"
**Solution**: Check if migration files were modified after being applied
- Never modify V1, V2, V3 files
- Create new migration files (V4, V5, etc.) for changes

### Issue: "Table not found" error
**Solution**: Ensure Flyway migrations completed
- Check application logs for "Flyway successfully validated"
- Verify database connection in application.properties

### Issue: "Invalid or expired OTP"
**Solution**: OTP expires after 5 minutes
- Request a new OTP by calling login endpoint again

### Issue: "Device mismatch" error
**Solution**: Refresh token is tied to device ID
- Ensure X-Device-Id header is consistent across requests

### Issue: Frontend not connecting to backend
**Solution**: Check CORS configuration
- Verify frontend origin matches `@CrossOrigin` in AuthController
- Default: `http://localhost:5173`

---

## 📊 Useful Queries

### Count Menu Items per Canteen
```sql
SELECT c.name, COUNT(m.id) as item_count
FROM canteens c
LEFT JOIN menu_items m ON c.id = m.canteen_id
GROUP BY c.id, c.name;
```

### Find Dishes by Category
```sql
SELECT DISTINCT d.name, bd.name as base_dish
FROM dishes d
JOIN base_dishes bd ON d.base_dish_id = bd.id
JOIN base_dish_categories bdc ON bd.id = bdc.base_dish_id
JOIN categories cat ON bdc.category_id = cat.id
WHERE cat.name = 'Breakfast'
ORDER BY bd.name;
```

### Find Vegetarian Items
```sql
SELECT d.name, c.name as canteen, m.price
FROM menu_items m
JOIN dishes d ON m.dish_id = d.id
JOIN base_dishes bd ON d.base_dish_id = bd.id
JOIN canteens c ON m.canteen_id = c.id
WHERE bd.food_type = 'VEG'
ORDER BY c.name, d.name;
```

### Find Items Under 200 Rupees
```sql
SELECT d.name, c.name as canteen, m.price
FROM menu_items m
JOIN dishes d ON m.dish_id = d.id
JOIN canteens c ON m.canteen_id = c.id
WHERE m.price < 200
ORDER BY m.price DESC;
```

---

## 🔑 Key Files to Know

| File | Purpose |
|------|---------|
| `application.properties` | Database and Flyway configuration |
| `FlywayConfig.java` | Triggers Flyway migrations on startup |
| `AuthController.java` | Login and OTP verification endpoints |
| `MenuService.java` | Menu search and retrieval logic |
| `MenuItemRepository.java` | Database queries for menu items |
| `V1__initial_schema.sql` | Database schema creation |
| `V2__insert_seed_data.sql` | Seed data insertion |
| `V3__add_unique_constraints.sql` | Unique constraints |

---

## 📝 Notes

- Always create new migration files for changes, never modify existing ones
- OTP is valid for 5 minutes
- Refresh tokens are valid for 7 days
- Device ID is required for token refresh
- All prices are in Indian Rupees (₹)
- Food types: VEG, NON_VEG, EGG

