# ⚡ START YOUR APPLICATION - QUICK FIX

## The Real Problem

Your system uses **PASSWORD-BASED LOGIN** (not OTP). The 500 error happens because:

1. **PostgreSQL password is wrong** in `application.properties`
2. **Kafka listeners are trying to connect** even though Kafka isn't running

## QUICK FIX (2 minutes)

### Step 1: Fix PostgreSQL Password

Open `src/main/resources/application.properties` and change line 13:

**Current:**
```properties
spring.datasource.password=NikhitaMumbai123*
```

**Change to YOUR actual PostgreSQL password:**
```properties
spring.datasource.password=root
```
(Or whatever password you set when installing PostgreSQL)

### Step 2: Disable Kafka Listeners

Add this line at the TOP of `application.properties` (after line 1):

```properties
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.kafka.KafkaAutoConfiguration
```

### Step 3: Start Application

```powershell
mvn spring-boot:run
```

## Why You're Not Getting "OTP"

**YOUR SYSTEM DOESN'T USE OTP!** It uses:
- Email + Password login
- JWT tokens for authentication
- No OTP/SMS verification

The "network error" you saw means:
- Backend wasn't running (due to these errors)
- Frontend couldn't connect to http://localhost:8080
- Login API returned 500 Internal Server Error

## After You Fix This

1. Backend will start on http://localhost:8080
2. Go to http://localhost:5173/login
3. Enter **email + password** (not OTP)
4. You'll get a JWT token and be logged in

## Common PostgreSQL Passwords

Try these if you don't remember:
- `root`
- `postgres`
- `admin`
- `password`
- `123456`

## Still Not Working?

If you still get password errors, reset your PostgreSQL password:

1. Open pgAdmin
2. Right-click on "PostgreSQL 16" server
3. Properties → Connection
4. Change password
5. Update `application.properties` with new password

---

**Fix the password, disable Kafka, restart. That's it.** 🚀
