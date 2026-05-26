# 🏗️ Kafka Architecture for Coupon System

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTIONS                            │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      SPRING BOOT APPLICATION                         │
│                                                                       │
│  ┌──────────────────┐      ┌──────────────────┐                    │
│  │ CouponController │      │  CouponService   │                    │
│  └────────┬─────────┘      └────────┬─────────┘                    │
│           │                         │                                │
│           └─────────────┬───────────┘                                │
│                         ▼                                            │
│           ┌──────────────────────────┐                              │
│           │  CouponEventProducer     │                              │
│           │  (Sends Events)          │                              │
│           └──────────┬───────────────┘                              │
└────────────────────────┼────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         KAFKA CLUSTER                                │
│                      (localhost:9092)                                │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    KAFKA TOPICS                              │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────┐    │   │
│  │  │  coupon-viewed-events (3 partitions)              │    │   │
│  │  │  - User views coupon page                          │    │   │
│  │  │  - User clicks on coupon                           │    │   │
│  │  └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────┐    │   │
│  │  │  coupon-validated-events (3 partitions)           │    │   │
│  │  │  - Coupon code validation attempts                 │    │   │
│  │  │  - Success/failure status                          │    │   │
│  │  └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────┐    │   │
│  │  │  coupon-applied-events (3 partitions)             │    │   │
│  │  │  - Successful coupon applications                  │    │   │
│  │  │  - Discount amounts                                │    │   │
│  │  │  - Order details                                   │    │   │
│  │  └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────┐    │   │
│  │  │  user-behavior-events (3 partitions)              │    │   │
│  │  │  - General user actions                            │    │   │
│  │  │  - Navigation patterns                             │    │   │
│  │  └────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      SPRING BOOT APPLICATION                         │
│                                                                       │
│           ┌──────────────────────────┐                              │
│           │  CouponEventConsumer     │                              │
│           │  (Receives Events)       │                              │
│           └──────────┬───────────────┘                              │
│                      │                                               │
│                      ▼                                               │
│           ┌──────────────────────────┐                              │
│           │ CouponAnalyticsService   │                              │
│           │ - Track views            │                              │
│           │ - Track validations      │                              │
│           │ - Track applications     │                              │
│           │ - Update user profiles   │                              │
│           └──────────┬───────────────┘                              │
│                      │                                               │
│                      ▼                                               │
│           ┌──────────────────────────┐                              │
│           │   PostgreSQL Database    │                              │
│           │   (Analytics Data)       │                              │
│           └──────────────────────────┘                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Event Flow Examples

### Example 1: User Views Coupon Page

```
1. User opens coupon page
   │
   ▼
2. CouponController.getCoupons()
   │
   ▼
3. CouponEventProducer.publishCouponViewed()
   │
   ▼
4. Event sent to "coupon-viewed-events" topic
   │
   ▼
5. CouponEventConsumer.consumeCouponViewed()
   │
   ▼
6. CouponAnalyticsService.trackCouponView()
   │
   ▼
7. Analytics data saved to database
```

### Example 2: User Applies Coupon

```
1. User enters coupon code at checkout
   │
   ▼
2. CouponService.validateCoupon()
   │
   ├─► CouponEventProducer.publishCouponValidated()
   │   └─► "coupon-validated-events" topic
   │
   ▼
3. If valid: Apply discount
   │
   ▼
4. CouponEventProducer.publishCouponApplied()
   │
   ▼
5. Event sent to "coupon-applied-events" topic
   │
   ▼
6. CouponEventConsumer.consumeCouponApplied()
   │
   ├─► CouponAnalyticsService.trackCouponApplication()
   │   └─► Save application data
   │
   └─► CouponAnalyticsService.updateUserProfile()
       └─► Update user preferences
```

---

## 🎯 Component Responsibilities

### Producer Side (Sending Events)

```
┌─────────────────────────────────────────┐
│      CouponEventProducer                │
├─────────────────────────────────────────┤
│ Methods:                                │
│ • publishCouponViewed()                 │
│ • publishCouponValidated()              │
│ • publishCouponApplied()                │
│ • publishUserBehavior()                 │
├─────────────────────────────────────────┤
│ Responsibilities:                       │
│ • Generate unique event IDs             │
│ • Set event timestamps                  │
│ • Send events to correct topics         │
│ • Handle send failures                  │
│ • Log event publishing                  │
└─────────────────────────────────────────┘
```

### Consumer Side (Receiving Events)

```
┌─────────────────────────────────────────┐
│      CouponEventConsumer                │
├─────────────────────────────────────────┤
│ Listeners:                              │
│ • consumeCouponViewed()                 │
│ • consumeCouponValidated()              │
│ • consumeCouponApplied()                │
│ • consumeUserBehavior()                 │
├─────────────────────────────────────────┤
│ Responsibilities:                       │
│ • Listen to Kafka topics                │
│ • Deserialize events                    │
│ • Process events                        │
│ • Call analytics service                │
│ • Handle processing errors              │
└─────────────────────────────────────────┘
```

---

## 📦 Event Structure

### CouponEvent

```java
{
    "eventId": "uuid-generated",
    "eventType": "VIEWED | VALIDATED | APPLIED",
    "userId": 123,
    "couponCode": "SAVE20",
    "orderAmount": 100.00,
    "discountAmount": 20.00,
    "status": "SUCCESS | FAILED",
    "failureReason": "Expired | Invalid | ...",
    "timestamp": "2024-01-15T10:30:00",
    "sessionId": "session-uuid",
    "deviceType": "mobile | desktop",
    "ipAddress": "192.168.1.1",
    "restaurantId": "rest-123",
    "categoryId": "cat-456",
    "itemCount": 3
}
```

---

## 🔧 Kafka Infrastructure

### Zookeeper (Port 2181)
```
┌─────────────────────────────────────┐
│         Zookeeper                   │
├─────────────────────────────────────┤
│ • Manages Kafka cluster             │
│ • Stores metadata                   │
│ • Coordinates brokers               │
│ • Handles leader election           │
└─────────────────────────────────────┘
```

### Kafka Broker (Port 9092)
```
┌─────────────────────────────────────┐
│         Kafka Broker                │
├─────────────────────────────────────┤
│ • Stores messages                   │
│ • Manages topics                    │
│ • Handles producers                 │
│ • Handles consumers                 │
│ • Replicates data                   │
└─────────────────────────────────────┘
```

---

## 📊 Topic Configuration

Each topic has:
- **3 Partitions** - For parallel processing
- **1 Replica** - Single broker setup (development)
- **Retention** - Default 7 days

```
Topic: coupon-viewed-events
├─ Partition 0 ─► Consumer Group: coupon-tracking-group
├─ Partition 1 ─► Consumer Group: coupon-tracking-group
└─ Partition 2 ─► Consumer Group: coupon-tracking-group
```

---

## 🎯 Benefits of This Architecture

### 1. Asynchronous Processing
```
User Request → Quick Response
              ↓
         (Background)
         Analytics Processing
```
Users don't wait for analytics to complete!

### 2. Scalability
```
More Events? → Add More Partitions
More Load?   → Add More Consumers
```

### 3. Reliability
```
Event Published → Stored in Kafka
                ↓
         (Even if consumer is down)
         Events are safe!
```

### 4. Decoupling
```
Producer ←─ Kafka ─→ Consumer
(Doesn't know)   (Doesn't know)
about consumer   about producer
```

---

## 🚀 Performance Characteristics

### Throughput
- **Producers:** Can send thousands of events/second
- **Consumers:** Can process thousands of events/second
- **Partitions:** Enable parallel processing

### Latency
- **Event Publishing:** < 10ms
- **Event Delivery:** < 100ms
- **End-to-End:** < 1 second

### Reliability
- **Message Persistence:** Events stored on disk
- **Fault Tolerance:** Automatic retry on failure
- **Guaranteed Delivery:** At-least-once semantics

---

## 🔍 Monitoring Points

### Producer Metrics
- Events published per second
- Failed publish attempts
- Average publish latency

### Consumer Metrics
- Events consumed per second
- Consumer lag (unprocessed events)
- Processing errors

### Topic Metrics
- Messages per topic
- Partition distribution
- Storage usage

---

## 💡 Best Practices

1. **Event Design**
   - Keep events small and focused
   - Include all necessary context
   - Use consistent naming

2. **Error Handling**
   - Log all errors
   - Implement retry logic
   - Use dead letter queues for failed events

3. **Performance**
   - Batch events when possible
   - Use appropriate partition keys
   - Monitor consumer lag

4. **Security**
   - Validate event data
   - Sanitize user inputs
   - Monitor for anomalies

---

This architecture provides a robust, scalable foundation for your coupon tracking system!
