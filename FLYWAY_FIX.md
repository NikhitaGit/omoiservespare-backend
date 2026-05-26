# ✅ Flyway Migration Fix

## Problem

`mvn flyway:migrate` fails because Flyway plugin is not configured in `pom.xml`.

## Solution

**Don't run `mvn flyway:migrate` separately!**

Spring Boot automatically runs Flyway migrations when the application starts.

---

## Quick Fix

### Option 1: Just Start the Application (Recommended)

```bash
mvn spring-boot:run
```

Flyway will automatically:
1. Connect to PostgreSQL using `application.properties`
2. Run all pending migrations (including V13)
3. Start the application

### Option 2: Use the Script

```powershell
.\run-migration-and-start.ps1
```

This script:
- Checks if PostgreSQL is running
- Starts Spring Boot
- Flyway runs automatically

---

## How It Works

### Spring Boot Auto-Configuration

When you have `flyway-core` dependency in `pom.xml`:

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

Spring Boot automatically:
1. Reads database config from `application.properties`
2. Runs Flyway migrations on startup
3. Applies all SQL files in `src/main/resources/db/migration/`

### Your Migrations

```
src/main/resources/db/migration/
├── V1__initial_schema.sql
├── V2__...
├── V12__create_vendors_table.sql
└── V13__unified_auth_system.sql  ← New migration
```

---

## Verify Migration

### Check Logs

When Spring Boot starts, look for:

```
INFO  o.f.core.internal.command.DbMigrate  : Migrating schema "public" to version "13 - unified auth system"
INFO  o.f.core.internal.command.DbMigrate  : Successfully applied 1 migration to schema "public"
```

### Check Database

```sql
-- Connect to PostgreSQL
psql -U postgres -d omoiservespare

-- Check migration history
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;

-- Check if new tables exist
\dt vendor_profiles
\dt admin_profiles

-- Check if test accounts exist
SELECT email, role, vendor_status FROM users WHERE role IN ('VENDOR', 'ADMIN');
```

---

## Troubleshooting

### "Unable to connect to the database"

**Check PostgreSQL is running:**
```powershell
# Windows
Get-Service -Name postgresql*

# Or check port
Test-NetConnection -ComputerName localhost -Port 5432
```

**Check application.properties:**
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/omoiservespare
spring.datasource.username=postgres
spring.datasource.password=YOUR_PASSWORD
```

### "Migration checksum mismatch"

If you modified a migration file after it was applied:

```bash
# Option 1: Repair Flyway
mvn flyway:repair

# Option 2: Clean and re-run (⚠️ DELETES ALL DATA)
mvn flyway:clean
mvn spring-boot:run
```

### "Table already exists"

The migration uses `IF NOT EXISTS` clauses, so it's safe to run multiple times.

If you still get errors:
```sql
-- Manually check what exists
\dt vendor_profiles
\dt admin_profiles

-- If tables exist, migration will skip creation
```

---

## Manual Migration (If Needed)

If you really need to run migrations manually:

### Add Flyway Plugin to pom.xml

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-maven-plugin</artifactId>
            <version>9.22.3</version>
            <configuration>
                <url>jdbc:postgresql://localhost:5432/omoiservespare</url>
                <user>postgres</user>
                <password>YOUR_PASSWORD</password>
                <locations>
                    <location>filesystem:src/main/resources/db/migration</location>
                </locations>
            </configuration>
        </plugin>
    </plugins>
</build>
```

Then run:
```bash
mvn flyway:migrate
```

---

## Recommended Approach

**Just start the application:**

```bash
mvn spring-boot:run
```

Spring Boot handles everything automatically! 🚀

---

## Next Steps

1. ✅ Start application: `mvn spring-boot:run`
2. ✅ Check logs for migration success
3. ✅ Test authentication: `.\test-production-auth.ps1`
4. ✅ Verify test accounts exist

---

**Flyway migrations run automatically with Spring Boot!** 🎉
