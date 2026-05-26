# 🚀 Rewards System - Quick Start Guide

## ⚡ 3-Step Setup

### Step 1: Run Database Migration

```powershell
mvn flyway:migrate
```

This creates:
- 4 new tables (reward_rules, user_reward_progress, user_rewards, reward_transactions)
- 3 default reward rules
- All necessary indexes

### Step 2: Restart Application

```powershell
mvn spring-boot:run
```

Watch for Kafka consumer logs:
```
INFO  RewardEventConsumer : Kafka consumer started for order-completed-events
```

### Step 3: Integrate with Your OrderService

Add this ONE line to your order completion code:

```java
// In OrderService.java
@Autowired
private OrderEventPublisher orderEventPublisher;

public Order completeOrder(Long orderId) {
    // ... your existing code ...
    
    // 🎯 ADD THIS LINE
    orderEventPublisher.publishOrderCompleted(order);
    
    return order;
}
```

**That's it!** Rewards now work automatically!

---

## 🧪 Test It

### 1. Get Rewards API

```powershell
curl http://localhost:8080/api/rewards -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. Complete an Order

Place an order with wallet payment → Reward unlocks instantly!

### 3. Check Kafka Events

```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic order-completed-events
```

---

## 📱 Frontend Integration

Replace your static `rewardsData` with API call:

```javascript
useEffect(() => {
  const fetchRewards = async () => {
    const response = await fetch('/api/rewards', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    setRewards(data.rewards);
  };
  fetchRewards();
}, []);
```

---

## ✅ What You Get

1. **Real-time Processing** - Rewards unlock instantly when order completes
2. **Progress Tracking** - Users see their progress towards each reward
3. **Multiple Reward Types** - Wallet balance, order count, combo rewards
4. **Scalable** - Kafka-based architecture handles high load
5. **Production-Ready** - Transaction support, audit trail, error handling

---

## 📊 Default Rewards

1. **₹75 Monthly Cashback** - Maintain ₹1000 wallet balance
2. **5% Order Cashback** - Instant cashback on wallet payments
3. **₹150 Combo** - 3 orders + ₹1000 balance

---

## 🔧 Customization

Edit reward rules in database:

```sql
-- Change cashback amount
UPDATE reward_rules SET reward_amount = 100.00 WHERE id = 1;

-- Change wallet balance requirement
UPDATE reward_rules SET min_wallet_balance = 500.00 WHERE id = 1;

-- Add new reward rule
INSERT INTO reward_rules (rule_type, title, ...) VALUES (...);
```

---

## 📖 Full Documentation

See `REWARDS_SYSTEM_IMPLEMENTATION.md` for complete details.

---

**Ready to go! Your rewards system is production-ready! 🎉**
