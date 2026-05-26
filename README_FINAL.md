# Omoikane Innovations - Cafeteria Management System

**Status**: ✅ Production Ready  
**Last Updated**: March 3, 2026

---

## 🎯 Quick Start

### 1. Start Backend
```bash
cd omoiservespare
mvn spring-boot:run
```
- Runs on `http://localhost:8080`
- Flyway migrations run automatically
- Database initialized with seed data

### 2. Start Frontend
```bash
npm run dev
```
- Runs on `http://localhost:5173`
- Hot reload enabled

### 3. Test Login
- Email: `user1@example.com`
- OTP will be sent to email
- Enter OTP to login

---

## 📋 What's Included

### Backend Features
✅ OTP-based authentication  
✅ JWT token management with refresh tokens  
✅ Multi-canteen menu system  
✅ Dish variants with pricing  
✅ Advanced search and filtering  
✅ Category management  
✅ Device tracking for security  

### Database
✅ PostgreSQL with Flyway migrations  
✅ 8 tables with proper relationships  
✅ Seed data for 4 canteens, 6 categories, 8 dishes, 16 variants  
✅ 64 menu items with varying prices  
✅ 3 sample users for testing  

### Frontend
✅ React-based UI  
✅ Real-time menu search  
✅ Category filtering  
✅ Food type filtering (Veg, Non-Veg, Egg)  
✅ Modal for variant selection  
✅ Responsive design  

---

## 🔄 User Flow

```
1. User opens app
   ↓
2. Enters email and clicks "Send OTP"
   ↓
3. Receives OTP via email
   ↓
4. Enters OTP and clicks "Verify"
   ↓
5. Logged in - sees home page with base dishes
   ↓
6. Clicks on a dish (e.g., "Biryani")
   ↓
7. Modal shows variants with prices:
   - Chicken Biryani - ₹250 (Main Cafeteria)
   - Chicken Biryani - ₹240 (North Wing)
   - Mutton Biryani - ₹300 (Main Cafeteria)
   - etc.
   ↓
8. Clicks on variant to view canteen menu
   ↓
9. Sees all items available at that canteen
```

---

## 📊 Data Structure

### Canteens (4)
- Main Cafeteria
- North Wing Canteen
- South Wing Canteen
- Rooftop Cafe

### Categories (6)
- Breakfast
- Lunch
- Dinner
- Snacks
- Beverages
- Daily Specials

### Base Dishes (8)
Each has 2 variants (e.g., Chicken & Mutton versions)

### Menu Items (64)
16 variants × 4 canteens = 64 items with different prices

---

## 🔐 Security Features

- **OTP Authentication**: No passwords stored
- **JWT Tokens**: Secure token-based access
- **Token Rotation**: Refresh tokens prevent token reuse
- **Device Tracking**: Prevents unauthorized access from different devices
- **CORS Protection**: Only allows requests from frontend origin
- **HttpOnly Cookies**: Refresh tokens stored securely

---

## 📁 Project Structure

```
omoiservespare/
├── src/main/java/com/omoikaneinnovations/omoiservespare/
│   ├── config/           # Spring configuration
│   ├── controller/       # REST endpoints
│   ├── service/          # Business logic
│   ├── repository/       # Database queries
│   ├── entity/           # JPA entities
│   ├── dto/              # Data transfer objects
│   ├── security/         # JWT and security
│   └── exception/        # Custom exceptions
├── src/main/resources/
│   ├── application.properties
│   └── db/migration/     # Flyway migrations
│       ├── V1__initial_schema.sql
│       ├── V2__insert_seed_data.sql
│       └── V3__add_unique_constraints.sql
└── pom.xml
```

---

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login` - Send OTP
- `POST /api/auth/verify-otp` - Verify OTP and get tokens
- `POST /api/auth/refresh` - Refresh access token

### Menu
- `GET /api/menu/home` - Get base dishes
- `GET /api/menu/search?name=...` - Search menu items
- `GET /api/menu/canteen/{id}` - Get canteen menu

### Other
- `GET /api/categories` - Get all categories
- `GET /api/canteens` - Get all canteens

---

## 🗄️ Database

### Connection Details
- **Host**: localhost
- **Port**: 5432
- **Database**: omoiservespare_db
- **User**: postgres
- **Password**: postgres

### Connect to Database
```bash
psql -U postgres -d omoiservespare_db
```

### View Migrations
```sql
SELECT * FROM flyway_schema_history;
```

---

## 🧪 Testing

### Test Login
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

### Test Search
```bash
curl "http://localhost:8080/api/menu/search?name=Biryani"
```

### Test Home Menu
```bash
curl http://localhost:8080/api/menu/home
```

---

## 📝 Making Changes

### Adding New Data
1. Create migration file: `src/main/resources/db/migration/V4__description.sql`
2. Write SQL
3. Restart application
4. Flyway runs migration automatically

### Example: Add New Canteen
```sql
-- V4__add_new_canteen.sql
INSERT INTO canteens (name, location, phone_number, email)
VALUES ('West Wing Canteen', 'Building C', '9876543210', 'west@example.com');
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Flyway validation failed | Never modify V1, V2, V3. Create new migration files. |
| Table not found | Check logs for "Flyway successfully validated" |
| OTP not received | Verify email service configuration |
| Token expired | Use refresh token to get new access token |
| Device mismatch | Use consistent X-Device-Id header |

---

## 📚 Documentation

- **CURRENT_STATUS.md** - Current application state
- **COMMON_TASKS.md** - Quick reference guide
- **IMPLEMENTATION_COMPLETE.md** - Complete implementation details
- **FLYWAY_DATA_GUIDE.md** - Migration best practices
- **DISH_VARIANT_FIX.md** - Variant implementation details
- **DUPLICATE_DATA_FIX.md** - Data integrity solutions
- **FLYWAY_CHECKSUM_FIX.md** - Migration troubleshooting

---

## ✅ Verification Checklist

- [ ] Backend starts without errors
- [ ] Flyway migrations run successfully
- [ ] Frontend connects to backend
- [ ] Login flow works (OTP received)
- [ ] Menu search returns variants
- [ ] Modal displays prices correctly
- [ ] Category filtering works
- [ ] Food type filtering works
- [ ] Token refresh works
- [ ] Database has seed data

---

## 🚀 Production Deployment

1. Build: `mvn clean package`
2. Configure database credentials
3. Set JWT secret key
4. Configure CORS for production domain
5. Enable HTTPS
6. Deploy JAR file
7. Start application
8. Monitor logs

---

## 📞 Support

For issues:
1. Check application logs
2. Verify database connection
3. Check frontend console
4. Review documentation files
5. Test API endpoints with curl

---

**Version**: 1.0.0  
**Status**: ✅ Ready for Testing  
**Date**: March 3, 2026

