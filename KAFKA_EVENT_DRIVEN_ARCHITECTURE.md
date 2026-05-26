# Kafka Event-Driven Coupon Tracking System

## 🎯 Overview

This implementation adds production-grade event-driven architecture to your coupon system using Apache Kafka, similar to how Zomato/Swiggy track user behavior and coupon usage in real-time.

## 🏗️ Architecture

```
┌─────────────┐
│   Frontend  │
└──────┬──────┘
       │ REST API
       ▼
┌─────────────────────────────────────────┐
│         Spring Boot Application         │
│                                          │
│  ┌────────────────┐   ┌──────────────┐ │
│  │ CouponService  │──▶│ EventProducer│ │
│  └────────────────┘   └──────┬───────┘ │
│                              │          │
└──────────────────────────────┼──────────┘
                               │
                               ▼
                    ┌──────────────────┐
                    │   Apache Kafka   │
                    │   (localhost:9092)│
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │coupon-viewed│  │coupon-applied│  │user-behavior│
    │   events    │  │   events     │  │   events    │
    └──────┬──────┘  └──────┬───────┘  └──────┬──────┘
           │                │                  │
           └────────────────┼──────────────────┘
                            ▼
                  ┌──────────────────┐
                  │  EventConsumer   │
                  └────────┬─────────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │ AnalyticsService │
                  │   (Redis Cache)  │
                  └──────────────────┘
```

## 📊 Event Types

### 1. Coupon Viewed Event
Triggered when user browses available coupons
```json
{
  "eventId": "uuid",
  "eventType": "VIEWED",
  "userId": 123,
  "couponCode": "WELCOME200",
  "timestamp": "2026-04-16T18:00:00",
  "sessionId": "session-123"
}
```

### 2. Coupon Validated Event
Triggered when user tries to apply a coupon
```json
{
  "eventId": "uuid",
  "eventType": "VALIDATED",
  "userId": 123,
  "couponCode": "WELCOME200",
  "orderAmount": 600.00,
  "status": "SUCCESS",
  "discountAmount": 200.00,
  "timestamp": "2026-04-16T18:05:00"
}
```

### 3. Coupon Applied Event
Triggered when coupon is successfully applied to order
```json
{
  "eventId": "uuid",
  "eventType": "APPLIED",
  "userId": 123,
  "couponCode": "WELCOME200",
  "orderAmount": 600.00,
  "discountAmount": 200.00,
  "status": "SUCCESS",
  "timestamp": "2026-04-16T18:10:00"
}
```

### 4. User Behavior Event
Triggered for various user actions
```json
{
  "eventId": "uuid",
  "userId": 123,
  "action": "BROWSE_COUPONS",
  "timestamp": "2026-04-16T18:00:00",
  "sessionId": "session-123",
  "metadata": {}
}
```

## 🔧 Components

### 1. Event Producer (`CouponEventProducer`)
- Publishes events to Kafka topics
- Asynchronous, non-blocking
- Handles failures gracefully

### 2. Event Consumer (`CouponEventConsumer`)
- Listens to Kafka topics
- Processes events asynchronously
- Updates analytics in real-time

### 3. Analytics Service (`CouponAnalyticsService`)
- Tracks coupon performance metrics
- Stores data in Redis for fast access
- Provides insights for personalization

## 📈 Analytics Tracked

### Coupon Metrics
- **Views**: How many times coupon was viewed
- **Validations**: Success/failure rates
- **Applications**: Actual usage count
- **Total Discount**: Money saved by users
- **Failure Reasons**: Why coupons failed

### User Profile
- **Total Coupons Used**: Lifetime count
- **Total Savings**: Money saved
- **Last Coupon Used**: Recent activity
- **Preferred Discount Type**: User preferences

## 🚀 Setup Instructions

### Step 1: Install Kafka

#### Option A: Download Manually
1. Visit https://kafka.apache.org/downloads
2. Download Kafka 3.6.1 (kafka_2.13-3.6.1.tgz)
3. Extract to your project directory

#### Option B: Use Chocolatey (Windows)
```powershell
choco install apache-kafka
```

### Step 2: Start Kafka Services

#### Terminal 1: Start Zookeeper
```powershell
cd kafka_2.13-3.6.1
.\bin\windows\zookeeper-server-start.bat .\config\zookeeper.properties
```

#### Terminal 2: Start Kafka Broker
```powershell
cd kafka_2.13-3.6.1
.\bin\windows\kafka-server-start.bat .\config\server.properties
```

### Step 3: Start Your Application
```powershell
cd omoiservespare
./start-backend.ps1
```

Topics will be created automatically!

## 📊 Monitoring Events

### View Kafka Topics
```powershell
.\bin\windows\kafka-topics.bat --list --bootstrap-server localhost:9092
```

### Consume Events (for testing)
```powershell
# View coupon-viewed events
.\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-viewed-events --from-beginning

# View coupon-applied events
.\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic coupon-applied-events --from-beginning
```

## 🔍 Analytics API

### Get Coupon Performance Metrics
```http
GET /api/coupons/analytics/{couponCode}?date=2026-04-16
```

Response:
```json
{
  "couponCode": "WELCOME200",
  "date": "2026-04-16",
  "views": 150,
  "successfulValidations": 45,
  "failedValidations": 15,
  "applications": 40,
  "totalDiscount": 8000.00
}
```

## 💡 Benefits

### 1. Real-time Tracking
- Track every user interaction with coupons
- Monitor coupon performance in real-time
- Detect fraud patterns instantly

### 2. Scalability
- Kafka handles millions of events per second
- Horizontal scaling with partitions
- Decoupled architecture

### 3. Analytics & Insights
- Understand user behavior
- Optimize coupon strategies
- Personalize offers

### 4. Reliability
- Events are persisted in Kafka
- Replay events if needed
- No data loss

## 🎯 Use Cases

### 1. Personalized Coupons
- Analyze user behavior
- Generate targeted coupons
- Increase conversion rates

### 2. Fraud Detection
- Track unusual patterns
- Detect coupon abuse
- Prevent revenue loss

### 3. A/B Testing
- Test different coupon strategies
- Measure effectiveness
- Optimize ROI

### 4. Real-time Dashboards
- Monitor coupon usage live
- Track revenue impact
- Make data-driven decisions

## 🔐 Production Considerations

### 1. Kafka Configuration
- Increase replication factor for production
- Configure retention policies
- Set up monitoring (Kafka Manager, Confluent Control Center)

### 2. Error Handling
- Implement dead letter queues
- Add retry mechanisms
- Log all failures

### 3. Security
- Enable SSL/TLS
- Configure SASL authentication
- Implement access control

### 4. Monitoring
- Set up Prometheus metrics
- Configure alerts
- Monitor consumer lag

## 📝 Configuration

All Kafka settings are in `application.properties`:

```properties
# Kafka Bootstrap Server
spring.kafka.bootstrap-servers=localhost:9092

# Consumer Configuration
spring.kafka.consumer.group-id=coupon-tracking-group
spring.kafka.consumer.auto-offset-reset=earliest

# Topics
kafka.topic.coupon-viewed=coupon-viewed-events
kafka.topic.coupon-applied=coupon-applied-events
kafka.topic.coupon-validated=coupon-validated-events
kafka.topic.user-behavior=user-behavior-events
```

## 🎉 What's Next?

1. **Machine Learning**: Use event data to train ML models for coupon recommendations
2. **Real-time Notifications**: Send push notifications based on events
3. **Advanced Analytics**: Build dashboards with Grafana/Kibana
4. **Stream Processing**: Use Kafka Streams for complex event processing

---

## 🆘 Troubleshooting

### Kafka Not Starting?
- Check if port 9092 is available
- Ensure Zookeeper is running first
- Check logs in kafka/logs directory

### Events Not Being Consumed?
- Verify Kafka is running
- Check consumer group status
- Review application logs

### Performance Issues?
- Increase Kafka partitions
- Tune consumer threads
- Optimize Redis cache

---

Your coupon system is now production-ready with event-driven architecture! 🚀
