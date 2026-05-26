# Kafka Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Download Kafka (One-time setup)

Download Kafka 3.6.1 from: https://kafka.apache.org/downloads

Extract to your project directory.

### Step 2: Start Kafka (2 terminals needed)

#### Terminal 1: Zookeeper
```powershell
cd kafka_2.13-3.6.1
.\bin\windows\zookeeper-server-start.bat .\config\zookeeper.properties
```

#### Terminal 2: Kafka Broker
```powershell
cd kafka_2.13-3.6.1
.\bin\windows\kafka-server-start.bat .\config\server.properties
```

### Step 3: Start Your Application
```powershell
cd omoiservespare
./start-backend.ps1
```

### Step 4: Test It!

1. Open your frontend at http://localhost:5173
2. Login and browse coupons
3. Apply a coupon
4. Check the backend logs - you'll see events being published and consumed!

## 📊 View Events in Real-time

Open a new terminal:
```powershell
cd kafka_2.13-3.6.1
.\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-applied-events --from-beginning
```

You'll see all coupon events in real-time!

## ✅ What's Happening?

1. **User browses coupons** → `COUPON_VIEWED` event published
2. **User applies coupon** → `COUPON_VALIDATED` event published
3. **Coupon applied successfully** → `COUPON_APPLIED` event published
4. **Analytics updated** → Redis cache updated with metrics

## 🎯 Check Analytics

```http
GET http://localhost:8080/api/coupons/analytics/WELCOME200
```

You'll see:
- How many times the coupon was viewed
- How many times it was applied
- Total discount given
- Success/failure rates

## 🔥 That's It!

Your coupon system now has production-grade event tracking like Zomato/Swiggy!

---

## 💡 Pro Tips

1. **Keep Kafka running** - Start it once and leave it running
2. **Check logs** - Backend logs show all events being processed
3. **Monitor Redis** - Use Redis CLI to see cached analytics
4. **Scale easily** - Add more Kafka partitions for higher throughput

## 🆘 Need Help?

- Kafka not starting? Check if port 9092 is free
- Events not showing? Verify Kafka is running
- Application errors? Check application.properties Kafka config

Read the full guide: `KAFKA_EVENT_DRIVEN_ARCHITECTURE.md`
