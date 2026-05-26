# 🔍 Kafka Connection Status

## ✅ Current Status

### Application Status
- ✅ Spring Boot application started successfully
- ✅ Application running on port 8080
- ✅ All services initialized

### Kafka Infrastructure Status
- ✅ Zookeeper is RUNNING (port 2181)
- ✅ Kafka Broker is RUNNING (port 9092)

### Kafka Configuration Status
- ✅ KafkaTemplate bean created
- ✅ ProducerFactory configured
- ✅ ConsumerFactory configured
- ✅ Topics configured (4 topics)

## ⚠️ Important Note About Kafka Connection

**Kafka connections are LAZY** - they only connect when you first send or receive a message!

Your application logs show:
```
Started OmoiservespareApplication in 9.814 seconds
```

But NO Kafka connection logs yet because:
1. No events have been sent yet
2. No consumers have started listening yet
3. Kafka connects on-demand, not at startup

This is NORMAL and EXPECTED behavior!

---

## 🧪 How to Verify Kafka is Working

### Method 1: Use the Test API (Recommended)

I've created a test endpoint for you. Follow these steps:

#### Step 1: Restart your application
```powershell
# Stop current application (Ctrl+C)
# Then restart
mvn spring-boot:run
```

#### Step 2: Test Kafka connection
```powershell
# In a new PowerShell window
.\test-kafka-api.ps1
```

This will:
- Check Kafka configuration
- Send a test event to Kafka
- Verify the event was sent successfully

#### Step 3: Monitor Kafka topics
```powershell
# Open another PowerShell window
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-viewed-events --from-beginning
```

You should see the test event appear!

---

### Method 2: Manual API Test

```powershell
# Check Kafka status
Invoke-RestMethod -Uri "http://localhost:8080/api/kafka/status" -Method Get

# Send test event
Invoke-RestMethod -Uri "http://localhost:8080/api/kafka/test" -Method Get
```

---

### Method 3: Use Your Coupon APIs

When you use any coupon-related endpoint, events will be sent to Kafka automatically:

```powershell
# Example: Get coupons (requires authentication)
curl http://localhost:8080/api/coupons -H "Authorization: Bearer YOUR_TOKEN"
```

This will trigger a `coupon-viewed-events` event!

---

## 📊 What You'll See When Kafka Connects

Once you send your first event, you'll see logs like:

```
INFO  o.a.k.clients.producer.ProducerConfig : ProducerConfig values:
    bootstrap.servers = [localhost:9092]
    key.serializer = class org.apache.kafka.common.serialization.StringSerializer
    value.serializer = class org.springframework.kafka.support.serializer.JsonSerializer

INFO  o.a.k.clients.producer.KafkaProducer : [Producer clientId=producer-1] Instantiated an idempotent producer.

INFO  o.a.k.clients.Metadata : [Producer clientId=producer-1] Cluster ID: your-cluster-id

INFO  Event published successfully to topic: coupon-viewed-events | Partition: 0 | Offset: 0
```

And for consumers:

```
INFO  o.a.k.clients.consumer.ConsumerConfig : ConsumerConfig values:
    bootstrap.servers = [localhost:9092]
    group.id = coupon-tracking-group

INFO  o.s.k.listener.KafkaMessageListenerContainer : partitions assigned: [coupon-viewed-events-0, coupon-viewed-events-1, coupon-viewed-events-2]

INFO  Consumed COUPON_VIEWED event: userId=123, couponCode=SAVE20
```

---

## 🎯 Quick Verification Steps

### 1. Check Kafka is Running
```powershell
.\check-kafka-status.ps1
```

Expected output:
```
✓ Zookeeper is RUNNING
✓ Kafka Broker is RUNNING
```

### 2. Restart Application
```powershell
mvn spring-boot:run
```

Wait for:
```
Started OmoiservespareApplication in X.XXX seconds
```

### 3. Test Kafka Connection
```powershell
.\test-kafka-api.ps1
```

Expected output:
```
SUCCESS! Kafka is connected and working!
```

### 4. Monitor Events
```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-viewed-events --from-beginning
```

You should see events appearing!

---

## 📁 Files Created for Testing

1. **KafkaTestController.java** - Test endpoints
   - `GET /api/kafka/status` - Check configuration
   - `GET /api/kafka/test` - Send test event

2. **test-kafka-api.ps1** - Automated test script

3. **check-kafka-status.ps1** - Check if Kafka is running

---

## 🔧 Troubleshooting

### Issue: "Connection refused"
**Solution:**
```powershell
# Check if Kafka is running
.\check-kafka-status.ps1

# If not running, start it
.\start-kafka.ps1
```

### Issue: "No logs showing Kafka connection"
**Answer:** This is NORMAL! Kafka connects lazily. Send an event to trigger the connection.

### Issue: "Test API returns 401 Unauthorized"
**Solution:** Restart your application after the security config update:
```powershell
# Stop app (Ctrl+C)
mvn spring-boot:run
```

---

## ✅ Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Kafka Broker | ✅ Running | Port 9092 |
| Zookeeper | ✅ Running | Port 2181 |
| Spring Boot | ✅ Running | Port 8080 |
| Kafka Config | ✅ Complete | All beans created |
| Connection | ⏳ Lazy | Connects on first use |

**Next Step:** Restart your application and run `.\test-kafka-api.ps1` to verify Kafka connectivity!

---

## 🎉 Expected Result

After running the test, you should see:

```
[1/2] Checking Kafka configuration...
Kafka Configuration:
  Bootstrap Servers: localhost:9092
  Consumer Group: coupon-tracking-group
  Topics:
    - coupon-viewed-events
    - coupon-applied-events
    - coupon-validated-events
    - user-behavior-events

[2/2] Sending test event to Kafka...
SUCCESS! Kafka is connected and working!

Test Event Details:
  User ID: 999
  Coupon Code: TEST-KAFKA
  Order Amount: 100.00
  Status: SUCCESS

========================================
  KAFKA CONNECTION VERIFIED!
========================================
```

This confirms Kafka is fully operational!
