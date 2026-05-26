# 🚀 Kafka Setup - Start Here!

## ✅ Error Fixed!

The syntax error in `setup-kafka-complete.ps1` has been fixed. You can now run it!

---

## 🎯 Quick Start (Choose One Option)

### Option 1: Automated Setup (Recommended)
```powershell
.\setup-kafka-complete.ps1
```
This runs all 4 steps automatically with prompts between each step.

### Option 2: Use the Simple Version
```powershell
.\setup-kafka-simple.ps1
```
Same as Option 1, just a different file name.

### Option 3: Manual Step-by-Step
```powershell
# Step 1: Install Kafka
.\install-kafka-windows.ps1

# Step 2: Start Kafka
.\start-kafka.ps1

# Step 3: Create Topics
.\create-kafka-topics.ps1

# Step 4: Test Connection
.\test-kafka-connection.ps1
```

---

## 📋 What Each Script Does

| Script | What It Does | When to Use |
|--------|--------------|-------------|
| `setup-kafka-complete.ps1` | Runs all 4 steps automatically | First time setup |
| `setup-kafka-simple.ps1` | Same as above, alternative version | First time setup |
| `install-kafka-windows.ps1` | Downloads and installs Kafka | First time only |
| `start-kafka.ps1` | Starts Zookeeper and Kafka | Every day |
| `stop-kafka.ps1` | Stops all Kafka services | End of day |
| `create-kafka-topics.ps1` | Creates required topics | First time only |
| `test-kafka-connection.ps1` | Verifies everything works | Anytime |

---

## ⚡ Daily Workflow

### Morning (Start Work)
```powershell
.\start-kafka.ps1
```

### During Development
```powershell
# Start your Spring Boot app
.\mvnw.cmd spring-boot:run

# Or use your existing script
.\start-backend.ps1
```

### Evening (End Work)
```powershell
.\stop-kafka.ps1
```

---

## 🐛 If You Get Errors

### Error: "Java is NOT installed"
**Solution:**
1. Download Java from: https://adoptium.net/
2. Install Java 11 or higher
3. Verify: `java -version`
4. Run the setup again

### Error: "Cannot connect to Kafka"
**Solution:**
```powershell
# Check if Kafka is running
Test-NetConnection localhost -Port 9092

# If not running, start it
.\start-kafka.ps1
```

### Error: "Port 9092 already in use"
**Solution:**
```powershell
# Stop and restart
.\stop-kafka.ps1
Start-Sleep -Seconds 10
.\start-kafka.ps1
```

---

## 📖 Documentation

- **This File** - Quick start guide
- **README_KAFKA_SETUP.md** - Complete setup guide
- **KAFKA_QUICK_REFERENCE.md** - Daily commands
- **KAFKA_SETUP_GUIDE.md** - Detailed documentation
- **KAFKA_ARCHITECTURE_DIAGRAM.md** - System architecture

---

## ✅ Verification

After running the setup, verify:

```powershell
# Test Kafka connection
.\test-kafka-connection.ps1
```

You should see:
```
✓ Zookeeper is running on port 2181
✓ Kafka broker is running on port 9092
✓ Topics: Available
✓ Message Flow: Working
```

---

## 🎯 Next Steps

1. ✅ Run: `.\setup-kafka-complete.ps1`
2. ✅ Verify: `.\test-kafka-connection.ps1`
3. ✅ Start your app: `.\mvnw.cmd spring-boot:run`
4. 🎉 Done! Your coupon events will flow through Kafka!

---

## 💡 Pro Tips

1. **Keep Kafka windows open** - They show important logs
2. **Always start Kafka before your app** - Your app needs Kafka running
3. **Use `.\test-kafka-connection.ps1`** - To diagnose issues
4. **Stop properly** - Use `.\stop-kafka.ps1` before shutdown

---

**Ready? Run this command:**

```powershell
.\setup-kafka-complete.ps1
```

That's it! 🚀
