# 🚀 Render Deployment Guide with Redis

## Problem Fixed
Your app was failing on Render because:
1. Redis configuration was hardcoded to `localhost:6379`
2. Redis was required but not available on Render
3. The app has been updated to work WITHOUT Redis (uses in-memory cart)

## Option 1: Deploy WITHOUT Redis (Quick Fix)

### What You Get:
✅ Application runs successfully  
✅ Cart works with in-memory storage (per server instance)  
⚠️ Cart data is lost on server restart  
⚠️ In multi-instance deployments, each instance has its own cart

### Environment Variables on Render:
```bash
# Required
DB_URL=your_postgres_url
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password
JWT_SECRET=your_jwt_secret

# Email
SENDER_USERNAME=your_email@gmail.com
SENDER_PASSWORD=your_app_password
FROM_MAIL=your_email@gmail.com

# Optional (keep Redis disabled)
REDIS_ENABLED=false

# Other services
CLOUDINARY_CLOUD_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_key
CLOUDINARY_API_SECRET=your_cloudinary_secret
RAZORPAY_KEY_ID=your_razorpay_key
RAZORPAY_KEY_SECRET=your_razorpay_secret
GOOGLE_MAPS_API_KEY=your_google_maps_key
```

### Deploy Now:
1. Push your updated code to GitHub
2. Render will automatically detect and redeploy
3. Your app should start successfully!

---

## Option 2: Deploy WITH Redis (Production Ready)

### Benefits:
✅ Persistent cart across server restarts  
✅ Shared cart across multiple instances  
✅ Better performance with Redis caching  
✅ Coupon analytics tracking

### Step 1: Add Redis on Render

1. Go to your Render dashboard
2. Click "New" → "Redis"
3. Choose a plan:
   - **Free Plan**: 25 MB storage, shared resources (good for testing)
   - **Starter Plan**: $7/month, 256 MB storage (recommended for production)
4. Name it: `omoi-redis`
5. Click "Create Redis"

### Step 2: Get Redis Connection Details

After creation, Render will provide:
- **Internal Redis URL**: `redis://red-xxxxx:6379`
- **External Redis URL**: `rediss://red-xxxxx.oregon-postgres.render.com:6379`

Use the **Internal URL** (faster and free traffic between services)

### Step 3: Parse the Redis URL

If your Redis URL is: `redis://red-xxxxx:6379`

Then:
- Host: `red-xxxxx` (or full hostname)
- Port: `6379`

### Step 4: Update Environment Variables

Add these to your Web Service on Render:

```bash
# Enable Redis
REDIS_ENABLED=true
REDIS_HOST=red-xxxxx.oregon-postgres.render.com
REDIS_PORT=6379

# If using password (paid plans):
# REDIS_PASSWORD=your_redis_password
```

### Step 5: Deploy

Your application will automatically restart and connect to Redis.

---

## How Cart Works in Each Mode

### Without Redis:
```
User adds item → Stored in server memory → Lost on restart
```

### With Redis:
```
User adds item → Stored in Redis → Persists across restarts
```

---

## Testing Your Deployment

### 1. Check Application Logs
```
==> Deploying...
==> Build successful
==> Starting server on port 8080
==> Application started successfully
```

### 2. Test Health Endpoint
```bash
curl https://your-app.onrender.com/actuator/health
```

### 3. Test Cart (Without Login)
Your `CartService` automatically falls back to in-memory storage when Redis is unavailable.

### 4. Check Redis Connection (If Enabled)
Look for these logs:
```
INFO - Redis connection established
INFO - Cart saved to Redis for user: test@example.com
```

---

## Troubleshooting

### Error: "No open ports detected"
- **Cause**: Application failed to start
- **Fix**: Check that `PORT` environment variable is set to `8080` on Render
- Render automatically sets `PORT`, your app uses: `server.port=${PORT:8080}`

### Error: "Connection refused to Redis"
- **Cause**: Wrong Redis host/port or Redis not running
- **Fix**: 
  1. Verify `REDIS_ENABLED=true`
  2. Check `REDIS_HOST` and `REDIS_PORT` are correct
  3. Use **Internal Redis URL** not external

### Cart Not Persisting
- **Without Redis**: This is expected - cart uses in-memory storage
- **With Redis**: Check Redis logs and verify `REDIS_ENABLED=true`

### Application Crashes on Startup
- **Check logs** for specific error
- **Common fixes**:
  - Verify all required env vars are set
  - Check database connection string
  - Ensure Postgres database exists

---

## Cost Comparison

### Free Tier (No Redis):
- Web Service: Free (750 hours/month)
- PostgreSQL: Free (256 MB)
- **Total**: $0/month
- ⚠️ Cart data not persistent

### With Redis:
- Web Service: Free
- PostgreSQL: Free
- Redis: $7/month (Starter plan)
- **Total**: $7/month
- ✅ Production-ready with persistent carts

---

## Recommended Approach

1. **Start without Redis** - Test your deployment works
2. **Add Redis later** - When you need persistent carts
3. **Monitor usage** - Check if free tier is sufficient

---

## Next Steps

✅ Code is fixed and ready to deploy  
✅ Push to GitHub  
✅ Render will auto-deploy  
✅ Add Redis when needed  

Your application will work perfectly without Redis for now!
