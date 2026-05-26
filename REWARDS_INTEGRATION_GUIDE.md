# 🔌 Rewards System Integration Guide

## ✅ What's Been Created

A complete, production-grade rewards system is ready. All files are created and compiled successfully.

---

## 📋 Integration Steps

### Step 1: Run Database Migration

```powershell
mvn flyway:migrate
```

This creates all reward tables and default rules.

### Step 2: Add Reward Event Publishing to OrderService

In `OrderService.java`, add the field:

```java
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepository repo;
    private final OrderEventPublisher publisher; // Existing WebSocket publisher
    private final RewardOrderEventPublisher rewardPublisher; // 🎯 ADD THIS
    private final CartService cartService;
    // ... other fields
```

Then, in your order completion method, add:

```java
@Transactional
public OrderResponseDTO createOrder(User customer, List<CartItem> cartItems) {
    // ... your existing order creation logic ...
    
    Order saved = repo.save(order);
    
    // Existing WebSocket notifications
    publisher.toCustomer(saved.getCustomer(), saved);
    publisher.toOrder(saved.getOrderCode(), saved);
    
    // 🎯 ADD THIS - Publish to rewards system
    rewardPublisher.publishOrderCompleted(saved);
    
    return mapToDTO(saved);
}
```

### Step 3: Restart Application

```powershell
mvn spring-boot:run
```

Watch for:
```
INFO  RewardEventConsumer : Kafka consumer started for order-completed-events
```

---

## 🧪 Testing

### 1. Check Rewards API

```powershell
curl http://localhost:8080/api/rewards -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. Place an Order

Complete an order with wallet payment → Reward unlocks instantly!

### 3. Monitor Kafka

```powershell
C:\kafka\kafka_2.13-3.6.1\bin\windows\kafka-console-consumer.bat --bootstrap-server localhost:9092 --topic order-completed-events
```

---

## 📱 Frontend Integration

Update your React component:

```javascript
const Rewards = () => {
  const [rewards, setRewards] = useState([]);

  useEffect(() => {
    fetchRewards();
  }, []);

  const fetchRewards = async () => {
    const token = localStorage.getItem('token');
    const response = await fetch('http://localhost:8080/api/rewards', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    setRewards(data.rewards);
  };

  return (
    <div className="rewards-page">
      {rewards.map(reward => (
        <div className="reward-card" key={reward.id}>
          <h2>{reward.title}</h2>
          <div className="reward-highlight">{reward.highlight}</div>
          <p>{reward.description}</p>
          
          {/* Progress */}
          {!reward.isUnlocked && (
            <div className="progress-bar">
              <div style={{width: `${reward.progressPercentage}%`}} />
              <span>{reward.progressText}</span>
            </div>
          )}
          
          {/* Unlocked */}
          {reward.isUnlocked && (
            <div className="unlocked">
              ✓ Unlocked! ₹{reward.rewardAmount}
            </div>
          )}
        </div>
      ))}
    </div>
  );
};
```

---

## 🎯 How It Works

1. User completes order
2. `RewardOrderEventPublisher` sends event to Kafka
3. `RewardEventConsumer` processes event in real-time
4. `RewardService` checks rules and unlocks rewards
5. User opens rewards page → Sees progress and unlocked rewards

---

## 📊 Default Rewards

1. **₹75 Monthly Cashback** - Maintain ₹1000 wallet balance
2. **5% Order Cashback** - Instant on wallet payments
3. **₹150 Combo** - 3 orders + ₹1000 balance

---

## 🔧 Customization

Edit rewards in database:

```sql
-- Change cashback amount
UPDATE reward_rules SET reward_amount = 100.00 WHERE id = 1;

-- Change requirements
UPDATE reward_rules SET min_wallet_balance = 500.00 WHERE id = 1;
```

---

## ✅ Summary

- ✅ All code created and ready
- ✅ Database schema ready
- ✅ Kafka integration ready
- ✅ REST APIs ready
- 🎯 Just add ONE line to OrderService
- 🎯 Update frontend to use API

**Your rewards system is production-ready!**
