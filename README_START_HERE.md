# 🎯 START HERE - Quick Guide

## ✅ Current Status

| Component | Status | Action Needed |
|-----------|--------|---------------|
| Java 17 | ✅ Installed | None |
| PostgreSQL 16 | ✅ Installed | None |
| Database | ✅ Created | None |
| Docker | ✅ Installed | Start Docker Desktop |
| Redis | ⚠️ Not Started | Will auto-start |
| Code | ✅ Ready | None |

---

## 🚀 Start in 3 Steps

### 1️⃣ Start Docker Desktop
Click Docker Desktop icon from Start menu

### 2️⃣ Run This Command
```cmd
start-all.cmd
```

### 3️⃣ Test It Works
```powershell
curl http://localhost:8080/api/canteens
```

**That's it!** ✨

---

## 📚 Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **READY_TO_RUN.md** | Complete guide | Read this first |
| **START_APPLICATION.md** | Detailed startup | If you have issues |
| **start-all.cmd** | Auto-start script | Every time you start |
| **check-setup.ps1** | Diagnostic tool | To check status |
| **SETUP_SUMMARY.md** | What was fixed | Reference |
| **README_FINAL.md** | Project docs | API reference |

---

## 🎯 What Happens When You Run start-all.cmd

```
1. ✓ Checks Java is installed
2. ✓ Checks PostgreSQL is installed  
3. ✓ Starts Redis in Docker
4. ✓ Starts your application
5. ✓ Flyway creates/updates database tables
6. ✓ Application ready on http://localhost:8080
```

---

## 🧪 Quick Test Commands

```powershell
# Test 1: Get canteens
curl http://localhost:8080/api/canteens

# Test 2: Get menu
curl http://localhost:8080/api/menu/home

# Test 3: Search
curl "http://localhost:8080/api/menu/search?name=Biryani"
```

---

## ⚡ Next Time You Start

```cmd
start-all.cmd
```

That's all you need! The script handles everything.

---

## 🆘 If Something Goes Wrong

### Run the diagnostic:
```powershell
.\check-setup.ps1
```

### Common fixes:
- Docker not running? → Start Docker Desktop
- Port 8080 in use? → Close other apps or restart
- Redis error? → Run `docker start redis`

---

## 📊 Your Database

- **Name**: omoiservespare_db
- **Tables**: 8 tables with sample data
- **View in**: pgAdmin 4 (already installed)

Sample data includes:
- 4 canteens
- 6 categories  
- 8 dishes
- 16 variants
- 64 menu items
- 3 test users

---

## 🎉 Success Looks Like This

**Console output:**
```
✓ Flyway successfully validated 5 migrations
✓ Started OmoiservespareApplication in 15.234 seconds
```

**API response:**
```json
[
  {
    "id": 1,
    "name": "Main Cafeteria",
    "location": "Ground Floor, Building A"
  }
]
```

---

## 💡 Pro Tips

1. Keep Docker Desktop running in background
2. Use `start-all.cmd` every time
3. Press Ctrl+C to stop the application
4. Check console for any errors
5. Use pgAdmin to view database

---

## 🔗 Quick Links

- Application: http://localhost:8080
- pgAdmin: Already installed (check Start menu)
- Docker Desktop: Check system tray

---

**Ready?** Run `start-all.cmd` and you're good to go! 🚀
