# Omoikane Innovations - Current Application Status

**Last Updated**: March 3, 2026  
**Application Status**: ✅ Ready for Testing

---

## 🎯 COMPLETED TASKS

### 1. Database Setup & Flyway Migrations
- ✅ PostgreSQL database configured (`omoiservespare_db`)
- ✅ Flyway migrations automated on application startup
- ✅ V1: Schema creation (all tables)
- ✅ V2: Seed data insertion (categories, dishes, variants, canteens, menu items, users)
- ✅ V3: Unique constraints added to prevent duplicates

### 2. Authentication Flow
- ✅ OTP-based login system
- ✅ JWT token generation with role-based access
- ✅ Refresh token rotation with device tracking
- ✅ RefreshToken table correctly mapped to `refresh_tokens`

### 3. Menu System
- ✅ Home page displays base dishes with categories
- ✅ Search functionality returns dish variants with prices
- ✅ Modal displays available canteens with variant names and prices
- ✅ Multi-category support for dishes

### 4. Data Integrity
- ✅ Unique constraints on canteen names, category names, base dish names
- ✅ Duplicate data issue resolved
- ✅ Seed data properly structured with 4 canteens, 6 categories, 8 base dishes, 16 variants, 64 menu items

---

## 📊 DATABASE STRUCTURE

### Tables Created
- `users` - User accounts with email, phone, company name, account type
- `categories` - Food categories (Breakfast, Lunch, Dinner, etc.)
- `base_dishes` - Base dish definitions (Biryani, Butter Chicken, etc.)
- `dishes` - Dish variants (Chicken Biryani, Mutton Biryani, etc.)
- `canteens` - Canteen locations
- `menu_items` - Menu items linking dishes to canteens with prices
- `otps` - OTP records for authentication
- `refresh_tokens` - Refresh token tracking with device IDs
- `flyway_schema_history` - Flyway migration tracking

---

## 🔄 API ENDPOINTS

### Authentication
- `POST /api/auth/login` - Send OTP to user
- `POST /api/auth/verify-otp` - Verify OTP and issue tokens
- `POST /api/auth/refresh` - Refresh access token

### Menu
- `GET /api/menu/home` - Get base dishes for home page
- `GET /api/menu/search?name=...&tag=...&category=...` - Search menu items
- `GET /api/menu/canteen/{canteenId}` - Get menu for specific canteen

### Categories
- `GET /api/categories` - Get all categories

### Canteens
- `GET /api/canteens` - Get all canteens

---

## 🎨 FRONTEND INTEGRATION

### Home Page (Home.jsx)
- Displays base dishes from `/api/menu/home`
- Shows categories as tabs
- Supports food type filtering (Veg, Non-Veg, Egg)
- Search functionality
- Click on dish opens modal with available variants

### Modal Display
- Shows dish variants (e.g., "Chicken Biryani", "Mutton Biryani")
- Displays canteen name and price for each variant
- Click to navigate to canteen menu

### Field Mapping
- Frontend uses `itemName` (not `name`) for dish variant names
- Backend MenuSearchResponseDTO returns `itemName` correctly

---

## 🚀 RUNNING THE APPLICATION

### Prerequisites
- Java 17+
- PostgreSQL 12+
- Node.js 16+ (for frontend)
- Maven 3.8+

### Backend Startup
```bash
cd omoiservespare
mvn spring-boot:run
```

Application runs on `http://localhost:8080`

### Database Initialization
- Flyway automatically runs migrations on startup
- No manual SQL execution needed
- Seed data inserted automatically

### Frontend Startup
```bash
npm run dev
```

Frontend runs on `http://localhost:5173`

---

## 📝 SEED DATA

### Sample Users (Created by DataInitializer)
1. Email: `user1@example.com` - Employee
2. Email: `user2@example.com` - Employee
3. Email: `user3@example.com` - Employee

### Canteens
1. Main Cafeteria
2. North Wing Canteen
3. South Wing Canteen
4. Rooftop Cafe

### Categories
1. Breakfast
2. Lunch
3. Dinner
4. Snacks
5. Beverages
6. Daily Specials

### Base Dishes (8 total)
- Biryani
- Butter Chicken
- Paneer Tikka
- Samosa
- Dosa
- Idli
- Chole Bhature
- Tandoori Chicken

### Dish Variants (16 total)
Each base dish has 2 variants (e.g., Chicken Biryani, Mutton Biryani)

### Menu Items (64 total)
16 variants × 4 canteens = 64 menu items with varying prices

---

## 🔧 CONFIGURATION FILES

### application.properties
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/omoiservespare_db
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
```

### FlywayConfig.java
- Explicitly triggers Flyway migrations on startup
- Disables validation to allow re-running migrations if needed
- Ensures migrations complete before JPA initialization

---

## ✅ TESTING CHECKLIST

- [ ] Start backend: `mvn spring-boot:run`
- [ ] Verify Flyway migrations ran (check logs)
- [ ] Start frontend: `npm run dev`
- [ ] Test login flow with email
- [ ] Verify OTP received
- [ ] Enter OTP and verify token generation
- [ ] Navigate to home page
- [ ] Click on a dish (e.g., Biryani)
- [ ] Verify modal shows variants with prices
- [ ] Click on a variant to navigate to canteen
- [ ] Verify menu displays correctly

---

## 🐛 KNOWN ISSUES & SOLUTIONS

### Issue: Flyway not running
**Solution**: FlywayConfig bean explicitly triggers migrations on startup

### Issue: RefreshToken table not found
**Solution**: Added `@Table(name = "refresh_tokens")` annotation to RefreshToken entity

### Issue: Duplicate canteen data
**Solution**: Added UNIQUE constraint on canteen name in V3 migration

### Issue: Modal showing base dish name instead of variant
**Solution**: MenuItemRepository.searchItems() query returns `d.name` (variant) not `bd.name` (base dish)

### Issue: Frontend not displaying item name
**Solution**: Frontend uses `itemName` field from MenuSearchResponseDTO

---

## 📚 MIGRATION FILES

### V1__initial_schema.sql
Creates all tables with proper relationships and constraints

### V2__insert_seed_data.sql
Inserts comprehensive seed data for testing

### V3__add_unique_constraints.sql
Adds UNIQUE constraints to prevent duplicate data

---

## 🔐 SECURITY FEATURES

- OTP-based authentication (no passwords stored)
- JWT tokens with role-based access control
- Refresh token rotation with device tracking
- Token reuse detection
- Device mismatch detection
- CORS configured for frontend origin
- HttpOnly cookies for refresh tokens

---

## 📞 SUPPORT

For issues or questions:
1. Check application logs for error messages
2. Verify database connection in application.properties
3. Ensure Flyway migrations completed successfully
4. Check frontend console for API errors
5. Verify CORS configuration matches frontend origin

