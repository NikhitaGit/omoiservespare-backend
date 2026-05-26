# ⚡ Kafka Quick Reference - Coupon System

## 🚀 Quick Start (3 Commands)

```powershell
# Run this ONE command to do everything:
.\setup-kafka-complete.ps1

# OR run individually:
.\install-kafka-windows.ps1    # Install Kafka
.\start-kafka.ps1              # Start services
.\create-kafka-topics.ps1      # Create topics
```

---

## ✅ Your Application is Already Configured!

Your Spring Boot application already has:
- ✅ Kafka dependencies in `pom.xml`
- ✅ Kafka configuration in `application.properties`
- ✅ Event classes (`CouponEvent`, `UserBehaviorEvent`)
- ✅ Producer service (`CouponEventProducer`)
- ✅ Consumer service (`CouponEventConsumer`)
- ✅ Analytics service integration

**You just need to install and start Kafka!**

---

## 📋 Daily Commands

### Start Kafka (Every Day)
```powershell
.\start-kafka.ps1
```
This opens 2 windows (Zookeeper + Kafka). Keep them running!

### Stop Kafka (End of Day)
```powershell
.\stop-kafka.ps1
```

### Test Connection
```powershell
.\test-kafka-connection.ps1
```

---

## 🎯 How Your Coupon System Uses Kafka

### 1. When User Views Coupons
```java
// In your CouponController
CouponEvent event = new CouponEvent();
event.setUserId(userId);
event.setCouponCode(couponCode);
event.setTimestamp(LocalDateTime.now());

couponEventProducer.publishCouponViewed(event);
```

### 2. When User Validates Coupon
```java
// In your CouponService
CouponEvent event = new CouponEvent();
event.setUserId(userId);
event.setCouponCode(couponCode);
event.setStatus("SUCCESS");
event.setOrderAmount(orderAmount);

couponEventProducer.publishCouponValidated(event);
```

### 3. When Coupon is Applied
```java
// After successful order
CouponEvent event = new CouponEvent();
event.setUserId(userId);
event.setCouponCode(couponCode);
event.setDiscountAmount(discountAmount);
event.setOrderAmount(orderAmount);

couponEventProducer.publishCouponApplied(event);
```

### 4. Analytics Automatically Tracks Everything
The `CouponEventConsumer` listens to all events and:
- Tracks coupon views
- Records validation attempts
- Analyzes successful applications
- Updates user behavior profiles

---

## 📊 Monitor Events in Real-Time

### Watch Coupon Views
```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-viewed-events --from-beginning
```

### Watch Coupon Applications
```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-applied-events --from-beginning
```

### Watch All User Behavior
```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic user-behavior-events --from-beginning
```

---

## 🔧 Troubleshooting

### Problem: "Cannot connect to Kafka"
```powershell
# Check if running
Test-NetConnection localhost -Port 9092

# If not running, start it
.\start-kafka.ps1
```

### Problem: "Port 9092 already in use"
```powershell
# Stop and restart
.\stop-kafka.ps1
Start-Sleep -Seconds 5
.\start-kafka.ps1
```

### Problem: "Topics not found"
```powershell
# Create topics
.\create-kafka-topics.ps1
```

### Problem: "Java not found"
Install Java from: https://adoptium.net/

---

## 📁 File Structure

```
Your Project/
├── install-kafka-windows.ps1    # Install Kafka
├── start-kafka.ps1              # Start services
├── stop-kafka.ps1               # Stop services
├── create-kafka-topics.ps1      # Create topics
├── test-kafka-connection.ps1    # Test setup
├── setup-kafka-complete.ps1     # All-in-one setup
└── KAFKA_SETUP_GUIDE.md         # Detailed guide
```

---

## 🎯 Integration Points in Your Code

### Producer (Send Events)
**Location:** `CouponEventProducer.java`

Methods:
- `publishCouponViewed(event)` - Track views
- `publishCouponValidated(event)` - Track validation
- `publishCouponApplied(event)` - Track application
- `publishUserBehavior(event)` - Track behavior

### Consumer (Receive Events)
**Location:** `CouponEventConsumer.java`

Listeners:
- `consumeCouponViewed()` - Process view events
- `consumeCouponValidated()` - Process validation
- `consumeCouponApplied()` - Process applications
- `consumeUserBehavior()` - Process behavior

### Configuration
**Location:** `application.properties`

```properties
spring.kafka.bootstrap-servers=localhost:9092
kafka.topic.coupon-viewed=coupon-viewed-events
kafka.topic.coupon-applied=coupon-applied-events
kafka.topic.coupon-validated=coupon-validated-events
kafka.topic.user-behavior=user-behavior-events
```

---

## 🚦 Startup Checklist

1. [ ] Java installed (`java -version`)
2. [ ] Kafka installed (`C:\kafka\kafka_2.13-3.6.1` exists)
3. [ ] Start Kafka (`.\start-kafka.ps1`)
4. [ ] Topics created (`.\create-kafka-topics.ps1`)
5. [ ] Test connection (`.\test-kafka-connection.ps1`)
6. [ ] Start Spring Boot (`.\mvnw.cmd spring-boot:run`)

---

## 💡 Tips

1. **Always start Kafka before your Spring Boot app**
2. **Keep Kafka windows open** - Closing them stops the services
3. **Check logs** if events aren't flowing
4. **Use separate terminals** to monitor different topics
5. **Stop Kafka properly** with `.\stop-kafka.ps1`

---

## 📞 Need Help?

1. Run: `.\test-kafka-connection.ps1`
2. Check logs in Kafka windows
3. Verify topics: 
   ```powershell
   C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-topics.bat --list --bootstrap-server localhost:9092
   ```

---

## 🎉 You're Ready!

Your Kafka setup is complete and your application is already configured. Just:

1. Run: `.\setup-kafka-complete.ps1` (first time only)
2. Run: `.\start-kafka.ps1` (daily)
3. Start your Spring Boot application
4. Test your coupon features!

Events will automatically flow through Kafka and be tracked in analytics.
