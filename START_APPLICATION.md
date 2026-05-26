# 🚀 Start Application - Final Steps

## ✅ Current Status

### What's Ready:
- ✅ **Java 17** - Installed and working
- ✅ **PostgreSQL 16** - Installed and running
- ✅ **Database Created** - `omoiservespare_db` is ready
- ✅ **Code** - Compiles without errors
- ✅ **Docker** - Installed (version 29.2.1)

### What's Needed:
- ❌ **Redis** - Need to start (using Docker)

---

## Option 1: Start Redis with Docker (Recommended - 1 minute)

### Step 1: Start Docker Desktop
1. Open Docker Desktop application
2. Wait for it to start (you'll see the whale icon in system tray)

### Step 2: Start Redis Container
```powershell
# Start Redis in Docker
docker run -d -p 6379:6379 --name redis --restart unless-stopped redis:latest

# Verify it's running
docker ps
```

### Step 3: Run Application
```powershell
cd omoiservespare
.\mvnw.cmd spring-boot:run
```

---

## Option 2: Install Memurai (Redis for Windows)

### Step 1: Download and Install
1. Go to: https://www.memurai.com/get-memurai
2. Download Memurai (free version)
3. Install and start the service

### Step 2: Run Application
```powershell
cd omoiservespare
.\mvnw.cmd spring-boot:run
```

---

## Option 3: Temporarily Disable Redis (Quick Test)

If you just want to test if everything else works:

### Step 1: Comment out Redis in application.properties
```properties
# Temporarily disable Redis
# spring.redis.host=localhost
# spring.redis.port=6379
```

### Step 2: Comment out Redis dependency in pom.xml
Find and comment out:
```xml
<!--
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
-->
```

### Step 3: Run Application
```powershell
.\mvnw.cmd clean spring-boot:run
```

**Note**: This is only for testing. Redis is needed for session management in production.

---

## 🎯 Recommended: Use Docker (Easiest)

Since you already have Docker installed:

```powershell
# 1. Start Docker Desktop (from Start menu)

# 2. Wait 30 seconds for Docker to start

# 3. Start Redis
docker run -d -p 6379:6379 --name redis --restart unless-stopped redis:latest

# 4. Verify Redis is running
docker ps

# 5. Test Redis connection
docker exec -it redis redis-cli ping
# Should return: PONG

# 6. Run your application
cd omoiservespare
.\mvnw.cmd spring-boot:run
```

---

## 🧪 Verify Everything Works

### 1. Check Application Started
Look for this in the console:
```
Flyway successfully validated 5 migrations
Flyway successfully applied 5 migrations
Started OmoiservespareApplication in X.XXX seconds
```

### 2. Test API Endpoints
```powershell
# Test canteens endpoint
curl http://localhost:8080/api/canteens

# Test categories endpoint
curl http://localhost:8080/api/categories

# Test menu home
curl http://localhost:8080/api/menu/home
```

### 3. Test Login Flow
```powershell
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"companyName\":\"Omoikane\",\"email\":\"user1@example.com\",\"phoneNumber\":\"9876543210\",\"accountType\":\"EMPLOYEE\"}'
```

---

## 🐛 Troubleshooting

### Docker Desktop Won't Start
**Error**: "Docker daemon not running"

**Solution**:
1. Open Docker Desktop from Start menu
2. Wait for the whale icon to appear in system tray
3. Check if it says "Docker Desktop is running"

### Redis Container Already Exists
**Error**: "Conflict. The container name '/redis' is already in use"

**Solution**:
```powershell
# Remove old container
docker rm -f redis

# Start new one
docker run -d -p 6379:6379 --name redis redis:latest
```

### Port 6379 Already in Use
**Error**: "Bind for 0.0.0.0:6379 failed: port is already allocated"

**Solution**:
```powershell
# Check what's using port 6379
netstat -ano | findstr :6379

# Kill the process or use different port
docker run -d -p 6380:6379 --name redis redis:latest

# Update application.properties
spring.redis.port=6380
```

### Application Won't Start
**Error**: "Unable to connect to Redis"

**Solution**:
```powershell
# Check if Redis is running
docker ps | findstr redis

# Check Redis logs
docker logs redis

# Test Redis connection
docker exec -it redis redis-cli ping
```

---

## 📊 Complete Startup Checklist

Before running `.\mvnw.cmd spring-boot:run`:

- [ ] PostgreSQL service is running (check pgAdmin)
- [ ] Database `omoiservespare_db` exists
- [ ] Docker Desktop is running
- [ ] Redis container is running (`docker ps`)
- [ ] Port 8080 is available
- [ ] Port 6379 is available (for Redis)

---

## 🎉 Success Indicators

When everything is working, you'll see:

```
2026-03-08 20:00:00.000  INFO --- [main] o.f.c.i.s.JdbcTableSchemaHistory : Creating Schema History table "public"."flyway_schema_history" ...
2026-03-08 20:00:00.000  INFO --- [main] o.f.core.internal.command.DbValidate : Successfully validated 5 migrations
2026-03-08 20:00:00.000  INFO --- [main] o.f.core.internal.command.DbMigrate  : Current version of schema "public": 5
2026-03-08 20:00:00.000  INFO --- [main] o.f.core.internal.command.DbMigrate  : Schema "public" is up to date. No migration necessary.
2026-03-08 20:00:00.000  INFO --- [main] c.o.o.OmoiservespareApplication      : Started OmoiservespareApplication in 15.234 seconds
```

And API calls will return data:
```json
[
  {
    "id": 1,
    "name": "Main Cafeteria",
    "location": "Ground Floor, Building A"
  },
  ...
]
```

---

## 🚀 Quick Commands Reference

```powershell
# Start Docker Desktop (GUI)
# Then run:

# Start Redis
docker run -d -p 6379:6379 --name redis redis:latest

# Check Redis
docker ps
docker exec -it redis redis-cli ping

# Run Application
cd omoiservespare
.\mvnw.cmd spring-boot:run

# Test API
curl http://localhost:8080/api/canteens

# Stop Application
# Press Ctrl+C in the terminal

# Stop Redis (when done)
docker stop redis

# Start Redis again (next time)
docker start redis
```

---

## 📝 Next Time You Start

After first setup, starting is simple:

```powershell
# 1. Make sure Docker Desktop is running

# 2. Start Redis (if not already running)
docker start redis

# 3. Run application
cd omoiservespare
.\mvnw.cmd spring-boot:run
```

That's it! 🎉

---

**Estimated Time**: 2-3 minutes (after Docker Desktop starts)
