# ✅ Deploy to Render - Quick Checklist

## What Was Fixed

✅ **Redis**: Made optional (disabled by default)  
✅ **Vault**: Disabled for production deployment  
✅ Cart works with in-memory storage when Redis unavailable  
✅ Email uses direct env vars instead of Vault  
✅ Application will start successfully on Render  

---

## Changes Summary

### 1. Redis Configuration (RedisConfig.java)
- Now uses environment variables
- Disabled by default (`spring.redis.enabled=false`)
- Cart falls back to in-memory storage

### 2. Vault Configuration
- **OmoiservespareApplication.java**: Excluded Vault autoconfiguration
- **application.properties**: Added `spring.cloud.vault.enabled=false`
- Email credentials now from direct env vars

---

## Deploy Steps

### 1. Commit and Push Changes
```bash
git add .
git commit -m "Fix: Make Redis optional for Render deployment"
git push origin main
```

### 2. Render Will Auto-Deploy
- Render detects the push and rebuilds
- Wait 5-10 minutes for build to complete
- Watch the logs for "Application started successfully"

### 3. Verify Deployment
Check your app URL: `https://your-app.onrender.com`

You should see:
```
✅ Application is running
✅ Health check passes
✅ API endpoints work
```

---

## Required Environment Variables on Render

Make sure these are set in your Render dashboard:

### Database (Required)
```
DB_URL=your_postgres_connection_url
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password
```

### JWT (Required)
```
JWT_SECRET=your_long_secret_key_at_least_256_bits
```

### Email (Required for OTP)
```
SENDER_USERNAME=your_gmail@gmail.com
SENDER_PASSWORD=your_gmail_app_password
FROM_MAIL=your_gmail@gmail.com
```

### Redis (Optional - for cart persistence)
```
REDIS_ENABLED=false
```
*Set to `true` only after you add a Redis service*

### Other Services
```
CLOUDINARY_CLOUD_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_key
CLOUDINARY_API_SECRET=your_cloudinary_secret

RAZORPAY_KEY_ID=your_razorpay_key
RAZORPAY_KEY_SECRET=your_razorpay_secret
RAZORPAY_WEBHOOK_SECRET=your_webhook_secret

GOOGLE_MAPS_API_KEY=your_google_maps_key
```

---

## How Cart Works Now

### Without Redis (Current Setup):
```
✅ Cart stored in server memory
✅ Fast and works immediately
⚠️  Cart cleared on server restart
⚠️  Each server instance has separate cart
```

**Perfect for**: Testing, development, low-traffic sites

### With Redis (Optional Upgrade):
```
✅ Cart persists across restarts
✅ Shared cart across all server instances
✅ Better for production
💰 Requires Redis service ($7/month)
```

**Perfect for**: Production, high-traffic, multi-instance deployments

---

## Testing Your Deployed App

### 1. Health Check
```bash
curl https://your-app.onrender.com/actuator/health
```

Expected response:
```json
{"status": "UP"}
```

### 2. Test Cart API
```bash
# Add item to cart
curl -X POST https://your-app.onrender.com/api/cart/add \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "menuItemId": "MENU_ITEM_ID",
    "quantity": 1
  }'
```

### 3. Get Cart
```bash
curl https://your-app.onrender.com/api/cart \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Common Issues & Fixes

### ❌ "No open ports detected"
**Problem**: Application didn't start  
**Solution**: Check logs for startup errors, verify all required env vars are set

### ❌ "Database connection failed"
**Problem**: Wrong DB credentials  
**Solution**: Verify `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` are correct

### ❌ "Application crashes after 30 seconds"
**Problem**: Health check failing  
**Solution**: Ensure app binds to port `0.0.0.0:8080` (already configured)

### ⚠️ "Cart is empty after restart"
**Problem**: Using in-memory cart  
**Solution**: This is expected behavior. Add Redis for persistence.

---

## Adding Redis Later (Optional)

When you're ready for production:

1. **Create Redis on Render**
   - Dashboard → New → Redis
   - Choose plan (Free or Starter $7/month)

2. **Get Connection Details**
   - Copy Internal Redis URL
   - Extract hostname and port

3. **Update Environment Variables**
   ```
   REDIS_ENABLED=true
   REDIS_HOST=your-redis-host.render.com
   REDIS_PORT=6379
   ```

4. **Redeploy**
   - Render auto-restarts
   - Cart now persists!

---

## Current Status

✅ Code is fixed  
✅ Redis is optional  
✅ Ready to deploy  
⏳ Waiting for you to push to GitHub  

**Next Action**: Commit and push your code!

---

## Support

If deployment fails:
1. Check Render logs for errors
2. Verify environment variables
3. Review `RENDER_DEPLOYMENT_GUIDE.md` for detailed troubleshooting
