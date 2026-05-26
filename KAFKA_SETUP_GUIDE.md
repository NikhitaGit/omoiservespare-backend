# 🚀 Kafka Setup Guide for Windows

This guide will help you install and configure Apache Kafka for your Coupon System backend.

## 📋 Prerequisites

1. **Java 11 or higher** - Required for Kafka
   - Check if installed: `java -version`
   - Download from: https://adoptium.net/

2. **Windows 10 or higher** - For tar extraction support

## 🎯 Quick Start (Automated Installation)

Run these commands in PowerShell (as Administrator):

```powershell
# Step 1: Install Kafka
.\install-kafka-windows.ps1

# Step 2: Start Kafka services
.\start-kafka.ps1

# Step 3: Create required topics
.\create-kafka-topics.ps1

# Step 4: Test the connection
.\test-kafka-connection.ps1
```

That's it! Your Kafka is ready.

---

## 📖 Detailed Step-by-Step Guide

### Step 1: Install Kafka

```powershell
.\install-kafka-windows.ps1
```

This script will:
- ✅ Check if Java is installed
- ✅ Download Kafka 3.6.1
- ✅ Extract to `C:\kafka\`
- ✅ Configure data directories
- ✅ Set up configuration files

**Installation Location:** `C:\kafka\kafka_2.13-3.6.1`

---

### Step 2: Start Kafka Services

```powershell
.\start-kafka.ps1
```

This will start:
1. **Zookeeper** (port 2181) - Coordination service
2. **Kafka Broker** (port 9092) - Message broker

Two PowerShell windows will open showing the logs. Keep them running!

---

### Step 3: Create Topics

```powershell
.\create-kafka-topics.ps1
```

This creates the following topics for your Coupon System:
- `coupon-viewed-events` - Track when users view coupons
- `coupon-applied-events` - Track when coupons are applied
- `coupon-validated-events` - Track coupon validation
- `user-behavior-events` - Track user behavior analytics

---

### Step 4: Verify Installation

```powershell
.\test-kafka-connection.ps1
```

This will:
- ✅ Check Zookeeper connection
- ✅ Check Kafka broker connection
- ✅ List all topics
- ✅ Test message production/consumption

---

## 🛠️ Management Commands

### Start Kafka
```powershell
.\start-kafka.ps1
```

### Stop Kafka
```powershell
.\stop-kafka.ps1
```

### List Topics
```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-topics.bat --list --bootstrap-server localhost:9092
```

### View Topic Details
```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-topics.bat --describe --bootstrap-server localhost:9092 --topic coupon-viewed-events
```

### Monitor Messages (Consumer)
```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-viewed-events --from-beginning
```

---

## 🔧 Configuration

Your Spring Boot application is already configured in `application.properties`:

```properties
# Kafka Configuration
spring.kafka.bootstrap-servers=localhost:9092
spring.kafka.consumer.group-id=coupon-tracking-group
spring.kafka.consumer.auto-offset-reset=earliest

# Topics
kafka.topic.coupon-viewed=coupon-viewed-events
kafka.topic.coupon-applied=coupon-applied-events
kafka.topic.coupon-validated=coupon-validated-events
kafka.topic.user-behavior=user-behavior-events
```

---

## 🐛 Troubleshooting

### Issue: "Java is NOT installed"
**Solution:** Install Java from https://adoptium.net/

### Issue: "Port 9092 already in use"
**Solution:** 
```powershell
# Stop existing Kafka
.\stop-kafka.ps1

# Wait 10 seconds, then start again
.\start-kafka.ps1
```

### Issue: "Cannot connect to Kafka"
**Solution:**
1. Check if Zookeeper is running: `Test-NetConnection localhost -Port 2181`
2. Check if Kafka is running: `Test-NetConnection localhost -Port 9092`
3. Restart services: `.\stop-kafka.ps1` then `.\start-kafka.ps1`

### Issue: "Topic already exists"
**Solution:** This is normal. The script uses `--if-not-exists` flag.

### Issue: Kafka windows close immediately
**Solution:** Check the logs in:
- Zookeeper logs: `C:\kafka\kafka_2.13-3.6.1\logs\zookeeper.out`
- Kafka logs: `C:\kafka\kafka_2.13-3.6.1\logs\server.log`

---

## 🎯 Integration with Your Application

### 1. Kafka Producer Example (Send Events)

```java
@Service
public class CouponEventProducer {
    
    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;
    
    @Value("${kafka.topic.coupon-viewed}")
    private String couponViewedTopic;
    
    public void sendCouponViewedEvent(CouponViewedEvent event) {
        kafkaTemplate.send(couponViewedTopic, event);
    }
}
```

### 2. Kafka Consumer Example (Receive Events)

```java
@Service
public class CouponEventConsumer {
    
    @KafkaListener(topics = "${kafka.topic.coupon-viewed}", groupId = "${spring.kafka.consumer.group-id}")
    public void consumeCouponViewedEvent(CouponViewedEvent event) {
        // Process the event
        System.out.println("Coupon viewed: " + event.getCouponId());
    }
}
```

---

## 📊 Monitoring

### View Real-time Messages
```powershell
# Terminal 1: Start consumer for coupon-viewed-events
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-viewed-events

# Terminal 2: Start consumer for coupon-applied-events
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-applied-events
```

---

## 🚀 Starting Your Application

Once Kafka is running:

```powershell
# Start your Spring Boot application
.\mvnw.cmd spring-boot:run
```

Or use your existing start script:
```powershell
.\start-backend.ps1
```

---

## 📝 What's Next?

1. ✅ Kafka is installed and running
2. ✅ Topics are created
3. ✅ Spring Boot is configured
4. 🎯 Implement Kafka producers in your coupon controllers
5. 🎯 Implement Kafka consumers for analytics
6. 🎯 Test the event flow

---

## 🔗 Useful Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Spring Kafka Documentation](https://spring.io/projects/spring-kafka)
- [Kafka Quick Start](https://kafka.apache.org/quickstart)

---

## 💡 Tips

1. **Always start Zookeeper before Kafka**
2. **Keep the PowerShell windows open** - Closing them stops the services
3. **Use separate terminals** for monitoring different topics
4. **Check logs** if something goes wrong
5. **Stop Kafka properly** using `.\stop-kafka.ps1` before shutting down

---

## ✅ Verification Checklist

- [ ] Java is installed (`java -version`)
- [ ] Kafka is installed at `C:\kafka\kafka_2.13-3.6.1`
- [ ] Zookeeper is running (port 2181)
- [ ] Kafka broker is running (port 9092)
- [ ] All 4 topics are created
- [ ] Test connection passes
- [ ] Spring Boot application starts without errors

---

**Need Help?** Run `.\test-kafka-connection.ps1` to diagnose issues.
