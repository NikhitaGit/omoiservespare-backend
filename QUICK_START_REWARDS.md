# 🚀 Rewards System - Quick Start

## System Status: ✅ RUNNING

### Services Running
- Spring Boot: `http://localhost:8080`
- Kafka: `localhost:9092`
- Zookeeper: `localhost:2181`

---

## API Endpoints

### Get All Rewards
```bash
GET /api/rewards
Authorization: Bearer YOUR_JWT_TOKEN
```

### Get My Unlocked Rewards
```bash
GET /api/rewards/my-rewards
Authorization: Bearer YOUR_JWT_TOKEN
```

### Get My Progress
```bash
GET /api/rewards/progress
Authorization: Bearer YOUR_JWT_TOKEN
```

---

## Default Rewards

1. **Monthly Cashback** - ₹75
   - Maintain ₹1000 wallet balance

2. **Order Cashback** - 5%
   - Earn on wallet payments
   - Max ₹50 per order

3. **Combo Reward** - ₹150
   - ₹1000 balance + 3 orders/month

---

## How It Works

```
Order Delivered → Kafka Event → Reward Check → Unlock → User Sees It
```

---

## Test Flow

1. Place order
2. Mark as DELIVERED
3. Check logs for "Reward unlocked"
4. Call `/api/rewards/my-rewards`

---

## Kafka Commands

### Check Status
```powershell
.\check-kafka-status.ps1
```

### Start Kafka
```powershell
.\start-kafka.ps1
```

### Stop Kafka
```powershell
.\stop-kafka.ps1
```

---

## Application Commands

### Start Application
```powershell
mvn spring-boot:run
```

### Build
```powershell
mvn clean install -DskipTests
```

---

## Database Tables

- `reward_rules` - Reward definitions
- `user_reward_progress` - User progress
- `user_rewards` - Unlocked rewards
- `reward_transactions` - Audit trail

---

## Frontend Integration

```javascript
// Fetch rewards
axios.get('/api/rewards', {
  headers: { Authorization: `Bearer ${token}` }
})
.then(res => setRewards(res.data));

// Fetch my rewards
axios.get('/api/rewards/my-rewards', {
  headers: { Authorization: `Bearer ${token}` }
})
.then(res => setMyRewards(res.data));
```

---

## Troubleshooting

### Application won't start
```powershell
# Check if port 8080 is in use
netstat -ano | findstr :8080

# Kill process if needed
taskkill /PID <PID> /F
```

### Kafka not running
```powershell
.\check-kafka-status.ps1
.\start-kafka.ps1
```

### Check logs
Look for:
- "Published ORDER_COMPLETED event"
- "Processing order completed event"
- "Reward unlocked for user"

---

## Documentation

- `IMPLEMENTATION_SUMMARY.md` - Complete overview
- `REWARDS_SYSTEM_IMPLEMENTATION.md` - Detailed architecture
- `REWARDS_INTEGRATION_GUIDE.md` - Integration steps
- `REWARDS_QUICK_START.md` - Quick reference

---

## 🎉 You're All Set!

The rewards system is production-ready and running!
