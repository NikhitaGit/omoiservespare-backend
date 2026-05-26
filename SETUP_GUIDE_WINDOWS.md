# 🚀 Complete Setup Guide for Windows

## Prerequisites Checklist
- ✅ Java 17 (Already installed - verified)
- ❌ PostgreSQL (Need to install)
- ❌ Redis (Need to install)
- ✅ Maven (Maven wrapper included)

---

## Step 1: Install PostgreSQL

### Option A: Using Official Installer (Recommended)
1. Download PostgreSQL from: https://www.postgresql.org/download/windows/
2. Run the installer
3. During installation:
   - Set password for postgres user: `NikhitaMumbai123*` (or update application.properties)
   - Port: `5432` (default)
   - Install pgAdmin 4 (GUI tool)
4. Add PostgreSQL to PATH:
   - Default location: `C:\Program Files\PostgreSQL\16\bin`
   - Add to System Environment Variables

### Option B: Using Chocolatey
```powershell
choco install postgresql
```

### Verify Installation
```powershell
psql --version
```

---

## Step 2: Create Database

### Using Command Line
```powershell
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE omoiservespare_db;

# Exit
\q
```

### Using pgAdmin 4 (GUI)
1. Open pgAdmin 4
2. Right-click on "Databases"
3. Create > Database
4. Name: `omoiservespare_db`
5. Click Save

---

## Step 3: Install Redis

### Option A: Using Memurai (Redis for Windows)
1. Download from: https://www.memurai.com/get-memurai
2. Install Memurai (Redis-compatible for Windows)
3. Start Memurai service

### Option B: Using Docker (Recommended)
```powershell
# Install Docker Desktop first
# Then run Redis container
docker run -d -p 6379:6379 --name redis redis:latest
```

### Option C: Using WSL2
```powershell
# Install WSL2 if not already installed
wsl --install

# Inside WSL2
sudo apt update
sudo apt install redis-server
sudo service redis-server start
```

### Verify Redis
```powershell
# If using Memurai or Docker
redis-cli ping
# Should return: PONG
```

---

## Step 4: Configure Application

### Update application.properties (if needed)

Current configuration:
```properties
# Database
spring.datasource.url=jdbc:postgresql://localhost:5432/omoiservespare_db
spring.datasource.username=postgres
spring.datasource.password=NikhitaMumbai123*

# Redis
spring.redis.host=localhost
spring.redis.port=6379
```

**If you set a different PostgreSQL password**, update line 3 in:
`omoiservespare/src/main/resources/application.properties`

---

## Step 5: Build and Run Application

### Clean and Build
```powershell
cd omoiservespare
.\mvnw.cmd clean package
```

### Run Application
```powershell
.\mvnw.cmd spring-boot:run
```

### Expected Output
```
Flyway successfully validated 5 migrations
Flyway successfully applied 5 migrations
Started OmoiservespareApplication in X seconds
```

---

## Step 6: Verify Setup

### Check Database Tables
```powershell
psql -U postgres -d omoiservespare_db

# List tables
\dt

# Should show:
# - canteens
# - categories
# - dishes
# - dish_variants
# - menu_items
# - users
# - otp_verifications
# - flyway_schema_history
```

### Test API Endpoints
```powershell
# Test health
curl http://localhost:8080/api/canteens

# Test login
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"companyName\":\"Omoikane\",\"email\":\"user1@example.com\",\"phoneNumber\":\"9876543210\",\"accountType\":\"EMPLOYEE\"}'
```

---

## Common Issues & Solutions

### Issue 1: PostgreSQL Connection Failed
**Error**: `Connection refused` or `password authentication failed`

**Solution**:
1. Check PostgreSQL service is running:
   ```powershell
   Get-Service -Name postgresql*
   ```
2. Verify password in application.properties matches PostgreSQL password
3. Check pg_hba.conf allows local connections

### Issue 2: Redis Connection Failed
**Error**: `Unable to connect to Redis`

**Solution**:
1. Check Redis/Memurai service is running
2. Test connection: `redis-cli ping`
3. If using Docker: `docker ps` to verify container is running

### Issue 3: Port 8080 Already in Use
**Error**: `Port 8080 is already in use`

**Solution**:
```powershell
# Find process using port 8080
netstat -ano | findstr :8080

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Issue 4: Flyway Validation Failed
**Error**: `Validate failed: Migrations have failed validation`

**Solution**:
```sql
-- Connect to database
psql -U postgres -d omoiservespare_db

-- Drop and recreate database
DROP DATABASE omoiservespare_db;
CREATE DATABASE omoiservespare_db;
```

Then restart the application.

---

## Quick Start Commands

```powershell
# 1. Start PostgreSQL (if not running as service)
# Check in Services app or pgAdmin

# 2. Start Redis (if using Docker)
docker start redis

# 3. Navigate to project
cd omoiservespare

# 4. Run application
.\mvnw.cmd spring-boot:run

# 5. In another terminal, test API
curl http://localhost:8080/api/canteens
```

---

## Environment Variables (Optional)

For production or to avoid hardcoding credentials:

```powershell
# Set environment variables
$env:DB_PASSWORD="your_password"
$env:SENDGRID_API_KEY="your_key"
$env:TWILIO_AUTH_TOKEN="your_token"
```

Update application.properties:
```properties
spring.datasource.password=${DB_PASSWORD}
sendgrid.api.key=${SENDGRID_API_KEY}
twilio.auth.token=${TWILIO_AUTH_TOKEN}
```

---

## Next Steps

1. ✅ Install PostgreSQL
2. ✅ Create database
3. ✅ Install Redis
4. ✅ Run application
5. ✅ Test endpoints
6. 📱 Set up frontend (if available)

---

## Support Resources

- PostgreSQL Docs: https://www.postgresql.org/docs/
- Redis Docs: https://redis.io/docs/
- Spring Boot Docs: https://spring.io/projects/spring-boot
- Project README: See `README_FINAL.md`

---

**Last Updated**: March 8, 2026
