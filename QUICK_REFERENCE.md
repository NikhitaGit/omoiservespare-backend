# Quick Reference Guide

## Current Status ✅

- **Database**: omoiservespare_db (PostgreSQL)
- **Tables**: 12 (all created)
- **Seed Data**: Inserted (6 categories, 8 dishes, 4 canteens, 64 menu items)
- **Sample Users**: 3 users created
- **Application**: Running on port 8080

## Common Tasks

### 1. Start Application
```bash
mvn spring-boot:run
```

### 2. Add New Seed Data
Create `src/main/resources/db/migration/V3__add_more_data.sql`:
```sql
INSERT INTO categories (name, is_active) VALUES ('New Category', true);
```
Then restart the application.

### 3. Add Sample Data via Code
Edit `src/main/java/.../config/DataInitializer.java`:
```java
private void initializeSampleUsers() {
    // Add your logic here
}
```

### 4. Check Database Data
```bash
# Connect to database
psql -U postgres -d omoiservespare_db

# View tables
\dt

# Count records
SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM canteens;
SELECT COUNT(*) FROM menu_items;
SELECT COUNT(*) FROM users;
```

### 5. Reset Database
```bash
# Drop database
psql -U postgres -c "DROP DATABASE omoiservespare_db;"

# Create new database
psql -U postgres -c "CREATE DATABASE omoiservespare_db;"

# Restart application (will recreate schema and seed data)
mvn spring-boot:run
```

## File Locations

| File | Purpose |
|------|---------|
| `src/main/resources/db/migration/V1__initial_schema.sql` | Database schema |
| `src/main/resources/db/migration/V2__insert_seed_data.sql` | Seed data |
| `src/main/java/.../config/DataInitializer.java` | Sample users |
| `src/main/resources/application.properties` | Configuration |

## Database Connection

```
Host: localhost
Port: 5432
Database: omoiservespare_db
Username: postgres
Password: Haveri123*
```

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/auth/login` | POST | Send OTP |
| `/api/auth/verify-otp` | POST | Verify OTP & get tokens |
| `/api/auth/refresh` | POST | Refresh access token |

## Sample Users for Testing

| Email | Password | Type |
|-------|----------|------|
| latabenakop1@gmail.com | (OTP via email) | Professional |
| test@example.com | (OTP via email) | Professional |
| customer@example.com | (OTP via email) | Customer |

## Troubleshooting

### Port 8080 Already in Use
```bash
# Find process using port 8080
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /F /PID <PID>
```

### Compilation Error
```bash
# Clean and rebuild
mvn clean compile
```

### Database Connection Error
```bash
# Check PostgreSQL is running
# Verify credentials in application.properties
# Check database exists: psql -U postgres -l
```

### Data Not Inserted
```bash
# Manually run migration
psql -U postgres -d omoiservespare_db < src/main/resources/db/migration/V2__insert_seed_data.sql
```

## Next Steps

1. ✅ Database schema created
2. ✅ Seed data inserted
3. ✅ Sample users created
4. ⏭️ Test OTP flow
5. ⏭️ Test menu endpoints
6. ⏭️ Test order creation
7. ⏭️ Add more canteens/dishes as needed

## Documentation

- `FLYWAY_DATA_GUIDE.md` - Complete Flyway workflow
- `DATA_INSERTION_SUMMARY.md` - Data statistics
- `QUICK_REFERENCE.md` - This file

---

**Last Updated**: 2026-03-03
**Status**: Ready for testing ✅
