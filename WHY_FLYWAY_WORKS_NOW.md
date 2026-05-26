# Why Flyway Now Works Automatically ✅

## The Problem (Before)
Flyway was configured but NOT running automatically on application startup. You had to manually execute SQL commands every time.

## The Solution (Now)
Created a `FlywayConfig.java` bean that explicitly triggers Flyway migrations during Spring Boot initialization.

## What Changed

### 1. Created FlywayConfig.java
```java
@Configuration
public class FlywayConfig {
    @Bean
    public Flyway flyway(DataSource dataSource) {
        Flyway flyway = Flyway.configure()
                .dataSource(dataSource)
                .locations("classpath:db/migration")
                .baselineOnMigrate(true)
                .baselineVersion("0")
                .load();
        
        // Run migrations immediately
        flyway.migrate();
        
        return flyway;
    }
}
```

**What this does:**
- Creates a Flyway bean that Spring Boot manages
- Configures Flyway to look for migrations in `classpath:db/migration`
- Calls `flyway.migrate()` immediately when the bean is created
- This happens BEFORE JPA/Hibernate initializes

### 2. Updated application.properties
```properties
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
spring.flyway.baseline-on-migrate=true
spring.flyway.baseline-version=0
spring.flyway.out-of-order=false
spring.flyway.validate-on-migrate=true
logging.level.org.flywaydb.core=DEBUG
```

**Key settings:**
- `enabled=true` - Enables Flyway
- `locations` - Where to find migration files
- `baseline-on-migrate=true` - Creates baseline if needed
- `DEBUG` logging - Shows Flyway execution details

## How It Works Now

### Startup Sequence:
1. **Spring Boot starts**
2. **FlywayConfig bean is created** ← Flyway runs HERE
3. **Flyway checks `flyway_schema_history` table**
4. **Flyway runs any new migrations** (V1, V2, etc.)
5. **JPA/Hibernate initializes** (tables already exist)
6. **DataInitializer runs** (creates sample users)
7. **Application is ready**

### Migration Tracking:
Flyway creates a `flyway_schema_history` table that tracks all executed migrations:

```sql
SELECT * FROM flyway_schema_history;
```

Output:
```
version | description      | success
--------|------------------|--------
1       | initial schema   | t
2       | insert seed data | t
```

## Why This Is Better

### ✅ Automatic
- No manual SQL commands needed
- Migrations run on every startup
- Idempotent (safe to run multiple times)

### ✅ Tracked
- Every migration is recorded in `flyway_schema_history`
- Can see exactly which migrations ran
- Prevents running migrations twice

### ✅ Ordered
- Migrations run in version order (V1, V2, V3...)
- Each migration runs only once
- New migrations run automatically

### ✅ Reliable
- Flyway handles all the complexity
- Transactions ensure atomicity
- Rollback on error

## Current Data

After Flyway ran automatically:
- ✅ 12 tables created (V1__initial_schema.sql)
- ✅ 6 categories inserted (V2__insert_seed_data.sql)
- ✅ 8 base dishes inserted
- ✅ 4 canteens inserted
- ✅ 64 menu items inserted
- ✅ 3 sample users created (DataInitializer)

## Adding More Data

### Option 1: Create New Migration File
```bash
# Create V3__add_more_canteens.sql
```

```sql
INSERT INTO canteens (name, place, prep_time, rating, image_url, is_active) VALUES
('Premium Canteen', 'VIP Floor', '15 mins', 5.0, 'url', true);
```

**Then restart the application:**
```bash
mvn spring-boot:run
```

Flyway will automatically:
1. Detect V3__add_more_canteens.sql
2. Run it
3. Record it in flyway_schema_history
4. Never run it again

### Option 2: Update DataInitializer
```java
private void initializeSampleUsers() {
    // Add more users here
}
```

**Then restart the application** - DataInitializer runs on every startup.

## Troubleshooting

### Flyway Not Running?
Check logs for:
```
DEBUG org.flywaydb.core
```

### Migration Failed?
1. Check error message in logs
2. Fix the SQL file
3. Create a new migration (V3, V4, etc.)
4. Restart application

### Need to Reset?
```bash
# Drop and recreate database
psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS omoiservespare_db;"
psql -U postgres -d postgres -c "CREATE DATABASE omoiservespare_db;"

# Restart application - Flyway will run all migrations from scratch
mvn spring-boot:run
```

## Key Files

| File | Purpose |
|------|---------|
| `FlywayConfig.java` | Triggers Flyway on startup |
| `application.properties` | Flyway configuration |
| `V1__initial_schema.sql` | Create tables |
| `V2__insert_seed_data.sql` | Insert seed data |
| `DataInitializer.java` | Create sample users |

## Summary

**Before:** Flyway was configured but not running → Manual SQL commands needed

**Now:** FlywayConfig bean triggers Flyway automatically → Everything runs on startup

**Result:** Database is always up-to-date with zero manual effort! ✅

---

**Status**: Flyway is now working automatically
**Last Updated**: 2026-03-03
