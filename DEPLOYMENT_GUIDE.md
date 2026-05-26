# 🚀 Production Signup System - Deployment Guide

## Pre-Deployment Checklist

### 1. Security Configuration ⚠️ CRITICAL

#### Change Admin Secret Key
```bash
# Generate a strong random key
openssl rand -base64 32

# Output example: 7xK9mP2nQ5wR8tY3vB6cD1eF4gH0jL5mN8pQ2sT7uV9wX
```

**Set as environment variable:**
```bash
# Linux/Mac
export ADMIN_SECRET_KEY="7xK9mP2nQ5wR8tY3vB6cD1eF4gH0jL5mN8pQ2sT7uV9wX"

# Windows PowerShell
$env:ADMIN_SECRET_KEY="7xK9mP2nQ5wR8tY3vB6cD1eF4gH0jL5mN8pQ2sT7uV9wX"

# Docker
-e ADMIN_SECRET_KEY="7xK9mP2nQ5wR8tY3vB6cD1eF4gH0jL5mN8pQ2sT7uV9wX"
```

**Or update application.properties:**
```properties
app.admin.secret-key=${ADMIN_SECRET_KEY}
```

⚠️ **NEVER commit the secret key to version control!**

---

### 2. Database Configuration

#### Verify Flyway Settings
```properties
# application.properties
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.locations=classpath:db/migration
```

#### Database Connection
```properties
spring.datasource.url=jdbc:mysql://your-db-host:3306/your-database
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
```

---

### 3. CORS Configuration

Update for your production domain:
```java
// SecurityConfig.java
config.setAllowedOrigins(List.of(
    "https://your-production-domain.com",
    "https://admin.your-production-domain.com"
));
```

---

### 4. JWT Configuration

```properties
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000  # 24 hours
```

Generate JWT secret:
```bash
openssl rand -base64 64
```

---

## Deployment Steps

### Step 1: Build Application

```bash
# Clean and build
mvn clean package -DskipTests

# Verify JAR created
ls -lh target/*.jar
```

---

### Step 2: Database Migration

**Option A: Automatic (Recommended)**
- Migrations run automatically on application startup
- Flyway will create the `vendors` table

**Option B: Manual**
```bash
# Run Flyway manually
mvn flyway:migrate

# Verify migration
mvn flyway:info
```

**Verify vendors table:**
```sql
SHOW TABLES LIKE 'vendors';
DESC vendors;

-- Should show:
-- id, user_id, restaurant_name, owner_name, address, 
-- business_license, description, created_at, updated_at
```

---

### Step 3: Deploy Application

#### Option A: Traditional Server

```bash
# Copy JAR to server
scp target/omoiservespare-*.jar user@server:/opt/app/

# SSH to server
ssh user@server

# Create systemd service
sudo nano /etc/systemd/system/omoiservespare.service
```

**Service file:**
```ini
[Unit]
Description=Omoi Serve Spare Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
ExecStart=/usr/bin/java -jar /opt/app/omoiservespare-*.jar
Environment="ADMIN_SECRET_KEY=your-secret-key"
Environment="DB_USERNAME=youruser"
Environment="DB_PASSWORD=yourpassword"
Environment="JWT_SECRET=your-jwt-secret"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Start service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable omoiservespare
sudo systemctl start omoiservespare
sudo systemctl status omoiservespare
```

---

#### Option B: Docker

**Dockerfile:**
```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/omoiservespare-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Build and run:**
```bash
# Build image
docker build -t omoiservespare:latest .

# Run container
docker run -d \
  --name omoiservespare \
  -p 8080:8080 \
  -e ADMIN_SECRET_KEY="your-secret-key" \
  -e DB_USERNAME="youruser" \
  -e DB_PASSWORD="yourpassword" \
  -e JWT_SECRET="your-jwt-secret" \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://db-host:3306/yourdb" \
  omoiservespare:latest
```

**Docker Compose:**
```yaml
version: '3.8'
services:
  app:
    image: omoiservespare:latest
    ports:
      - "8080:8080"
    environment:
      - ADMIN_SECRET_KEY=${ADMIN_SECRET_KEY}
      - DB_USERNAME=${DB_USERNAME}
      - DB_PASSWORD=${DB_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      - SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/omoiservespare
    depends_on:
      - db
  
  db:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MYSQL_DATABASE=omoiservespare
      - MYSQL_USER=${DB_USERNAME}
      - MYSQL_PASSWORD=${DB_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql

volumes:
  db-data:
```

---

#### Option C: Cloud Platforms

**AWS Elastic Beanstalk:**
```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init -p java-17 omoiservespare

# Set environment variables
eb setenv ADMIN_SECRET_KEY="your-secret-key" \
          DB_USERNAME="youruser" \
          DB_PASSWORD="yourpassword" \
          JWT_SECRET="your-jwt-secret"

# Deploy
eb create production-env
eb deploy
```

**Heroku:**
```bash
# Create app
heroku create omoiservespare

# Set environment variables
heroku config:set ADMIN_SECRET_KEY="your-secret-key"
heroku config:set DB_USERNAME="youruser"
heroku config:set DB_PASSWORD="yourpassword"
heroku config:set JWT_SECRET="your-jwt-secret"

# Deploy
git push heroku main
```

---

### Step 4: Verify Deployment

#### Check Application Health
```bash
curl http://your-server:8080/actuator/health
```

#### Check Database Connection
```bash
curl http://your-server:8080/api/canteens
```

#### Verify Migrations
```sql
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;
```

---

### Step 5: Create First Admin

**PowerShell:**
```powershell
$body = @{
    email = "admin@yourcompany.com"
    phoneNumber = "+1234567890"
    fullName = "System Administrator"
    secretKey = "your-secret-key"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://your-domain.com/api/admin/create-first" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

**cURL:**
```bash
curl -X POST https://your-domain.com/api/admin/create-first \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@yourcompany.com",
    "phoneNumber": "+1234567890",
    "fullName": "System Administrator",
    "secretKey": "your-secret-key"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "First admin created successfully",
  "email": "admin@yourcompany.com",
  "role": "ADMIN"
}
```

---

### Step 6: Test Vendor Registration

```bash
curl -X POST https://your-domain.com/api/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testvendor@example.com",
    "phoneNumber": "+1234567890",
    "restaurantName": "Test Restaurant",
    "ownerName": "John Doe",
    "address": "123 Main St",
    "businessLicense": "BL123456",
    "description": "Test restaurant"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Vendor application submitted successfully",
  "status": "PENDING",
  "email": "testvendor@example.com",
  "info": "Your application is under review..."
}
```

---

### Step 7: Test Admin Login & Approval

#### 1. Admin Login
```bash
curl -X POST https://your-domain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@yourcompany.com",
    "phoneNumber": "+1234567890"
  }'
```

#### 2. Verify OTP (check logs)
```bash
curl -X POST https://your-domain.com/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@yourcompany.com",
    "otp": "123456"
  }'
```

#### 3. Get Pending Vendors
```bash
curl -X GET https://your-domain.com/api/admin/vendors/pending \
  -H "Authorization: Bearer <jwt-token>"
```

#### 4. Approve Vendor
```bash
curl -X POST https://your-domain.com/api/admin/vendors/1/process \
  -H "Authorization: Bearer <jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "APPROVE",
    "reason": "All documents verified"
  }'
```

---

## Post-Deployment

### 1. Monitoring Setup

#### Application Logs
```bash
# Systemd
sudo journalctl -u omoiservespare -f

# Docker
docker logs -f omoiservespare

# File-based
tail -f /var/log/omoiservespare/application.log
```

#### Key Metrics to Monitor
- Vendor registration rate
- Admin approval time
- Failed authentication attempts
- Database connection pool
- API response times

---

### 2. Database Monitoring

**Pending vendors:**
```sql
SELECT COUNT(*) as pending_count 
FROM users 
WHERE role = 'VENDOR' AND vendor_status = 'PENDING';
```

**Daily registrations:**
```sql
SELECT DATE(created_at) as date, COUNT(*) as count
FROM users
WHERE role = 'VENDOR'
GROUP BY DATE(created_at)
ORDER BY date DESC
LIMIT 7;
```

---

### 3. Security Hardening

#### Enable HTTPS
```bash
# Let's Encrypt with Certbot
sudo certbot --nginx -d your-domain.com
```

#### Rate Limiting (Nginx)
```nginx
limit_req_zone $binary_remote_addr zone=vendor_reg:10m rate=5r/h;

location /api/vendor/register {
    limit_req zone=vendor_reg burst=2;
    proxy_pass http://localhost:8080;
}
```

#### Firewall Rules
```bash
# Allow only necessary ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

---

### 4. Backup Strategy

#### Database Backups
```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u $DB_USER -p$DB_PASS omoiservespare > backup_$DATE.sql
gzip backup_$DATE.sql

# Keep last 7 days
find /backups -name "backup_*.sql.gz" -mtime +7 -delete
```

#### Application Backups
```bash
# Backup configuration
tar -czf config_backup_$(date +%Y%m%d).tar.gz \
  /opt/app/application.properties \
  /etc/systemd/system/omoiservespare.service
```

---

### 5. Email Notifications (Optional)

Configure email service in `application.properties`:
```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=${EMAIL_USERNAME}
spring.mail.password=${EMAIL_PASSWORD}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```

---

## Rollback Plan

### If Deployment Fails

#### 1. Stop Application
```bash
# Systemd
sudo systemctl stop omoiservespare

# Docker
docker stop omoiservespare
```

#### 2. Restore Previous Version
```bash
# Copy previous JAR
cp /opt/app/backup/omoiservespare-previous.jar /opt/app/omoiservespare.jar

# Restart
sudo systemctl start omoiservespare
```

#### 3. Rollback Database (if needed)
```bash
# Restore from backup
mysql -u $DB_USER -p$DB_PASS omoiservespare < backup_previous.sql
```

---

## Troubleshooting

### Application Won't Start

**Check logs:**
```bash
sudo journalctl -u omoiservespare -n 100
```

**Common issues:**
- Database connection failed → Check credentials
- Port already in use → Change port or stop conflicting service
- Migration failed → Check Flyway logs

---

### Vendor Registration Fails

**Check:**
1. Database connection
2. Vendors table exists
3. Foreign key constraints
4. Application logs

**Verify:**
```sql
SHOW TABLES LIKE 'vendors';
DESC vendors;
SELECT * FROM users WHERE role = 'VENDOR' ORDER BY created_at DESC LIMIT 5;
```

---

### Admin Creation Fails

**Check:**
1. Secret key matches environment variable
2. No admin already exists (for first admin)
3. JWT token valid (for additional admins)

**Verify:**
```sql
SELECT * FROM users WHERE role = 'ADMIN';
```

---

## Production Checklist

### Security ✅
- [ ] Admin secret key changed
- [ ] JWT secret configured
- [ ] HTTPS enabled
- [ ] CORS configured for production domain
- [ ] Firewall rules configured
- [ ] Rate limiting enabled

### Database ✅
- [ ] Migrations ran successfully
- [ ] Vendors table created
- [ ] Foreign keys verified
- [ ] Backup strategy implemented

### Application ✅
- [ ] First admin created
- [ ] Vendor registration tested
- [ ] Admin approval workflow tested
- [ ] Logs configured
- [ ] Monitoring set up

### Documentation ✅
- [ ] Admin procedures documented
- [ ] Runbook created
- [ ] Contact information updated
- [ ] Rollback plan tested

---

## Support Contacts

### Technical Issues
- Check logs first
- Review troubleshooting section
- Verify database state

### Emergency Rollback
1. Stop application
2. Restore previous version
3. Verify functionality
4. Investigate issue

---

## Success Criteria

✅ Application starts without errors
✅ Database migrations completed
✅ First admin created successfully
✅ Vendor registration works
✅ Admin approval workflow functional
✅ Logs are accessible
✅ Monitoring is active
✅ Backups are running

---

**Deployment Complete! 🎉**

Your production signup system is now live and ready to handle admin and vendor registrations securely.
