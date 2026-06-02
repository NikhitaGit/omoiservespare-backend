# 🚀 Quick Start - Run Application Locally

## Prerequisites
1. PostgreSQL installed and running
2. Java 17 installed
3. Maven installed

## Step 1: Create Database

Open PostgreSQL and create the database:

```sql
CREATE DATABASE omoiservespare;
```

Or use psql command line:
```bash
psql -U postgres
CREATE DATABASE omoiservespare;
\q
```

## Step 2: Update Database Credentials (Optional)

If your PostgreSQL credentials are different from the defaults, you have two options:

### Option A: Set Environment Variables
```powershell
$env:DB_URL="jdbc:postgresql://localhost:5432/omoiservespare"
$env:DB_USERNAME="your_username"
$env:DB_PASSWORD="your_password"
```

### Option B: Edit application.properties
Update the default values in `src/main/resources/application.properties`:
```properties
spring.datasource.url=${DB_URL:jdbc:postgresql://localhost:5432/omoiservespare}
spring.datasource.username=${DB_USERNAME:your_username}
spring.datasource.password=${DB_PASSWORD:your_password}
```

## Step 3: Run the Application

### Using the provided script (Recommended):
```powershell
powershell -ExecutionPolicy Bypass -File start-with-java17.ps1
```

### Or using Maven directly:
```powershell
mvn spring-boot:run
```

### Or compile and run:
```powershell
mvn clean package -DskipTests
java -jar target/omoiservespare-0.0.1-SNAPSHOT.jar
```

## Step 4: Verify Application is Running

The application should start on port 8080. You should see:
```
Tomcat started on port(s): 8080 (http)
Started OmoiservespareApplication
```

Test the application:
```powershell
curl http://localhost:8080/actuator/health
```

## Default Configuration

The application uses these defaults when environment variables are not set:

| Property | Default Value |
|----------|--------------|
| Database URL | `jdbc:postgresql://localhost:5432/omoiservespare` |
| Database Username | `postgres` |
| Database Password | `postgres` |
| Server Port | `8080` |
| JWT Secret | (Built-in default) |

## Troubleshooting

### Error: "Driver org.postgresql.Driver claims to not accept jdbcUrl"
**Solution**: Database environment variables are not set. Either:
1. Set environment variables (see Step 2, Option A)
2. Update default values in application.properties (see Step 2, Option B)
3. Make sure PostgreSQL is running

### Error: "Connection refused"
**Solution**: PostgreSQL is not running. Start PostgreSQL service:
```powershell
# Windows
net start postgresql-x64-14

# Or check PostgreSQL service in Services app
```

### Error: "Database does not exist"
**Solution**: Create the database (see Step 1)

### Error: "Authentication failed"
**Solution**: Check your PostgreSQL username and password

## Production Deployment

For production, **always use environment variables** instead of hardcoded values:

```bash
export DB_URL="jdbc:postgresql://your-prod-db:5432/omoiservespare"
export DB_USERNAME="prod_user"
export DB_PASSWORD="secure_password"
export JWT_SECRET="your_very_long_and_secure_secret_key"

java -jar omoiservespare-0.0.1-SNAPSHOT.jar
```

## Next Steps

Once the application is running:
1. Access the API at `http://localhost:8080`
2. Check API documentation (if Swagger is enabled)
3. Test authentication endpoints
4. Set up your frontend to connect to the backend

🎉 **Your application is now running locally!**
