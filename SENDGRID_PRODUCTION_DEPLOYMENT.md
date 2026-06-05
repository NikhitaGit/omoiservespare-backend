# 🚀 SendGrid Production Deployment Guide

## Deploying with Environment Variables

### 1. Render.com

```bash
# In Render Dashboard:
# 1. Go to your service
# 2. Click "Environment" tab
# 3. Add these environment variables:

SENDGRID_API_KEY=SG.your-production-api-key
SENDGRID_FROM_EMAIL=noreply@yourcompany.com
```

### 2. Heroku

```bash
heroku config:set SENDGRID_API_KEY=SG.your-api-key
heroku config:set SENDGRID_FROM_EMAIL=noreply@yourcompany.com
```

### 3. AWS Elastic Beanstalk

Add to `.ebextensions/environment.config`:
```yaml
option_settings:
  - option_name: SENDGRID_API_KEY
    value: SG.your-api-key
  - option_name: SENDGRID_FROM_EMAIL
    value: noreply@yourcompany.com
```

### 4. Docker

```dockerfile
ENV SENDGRID_API_KEY=SG.your-api-key
ENV SENDGRID_FROM_EMAIL=noreply@yourcompany.com
```

## Production Checklist

- [ ] Domain authenticated in SendGrid
- [ ] Production API key created
- [ ] Environment variables set in hosting platform
- [ ] Test email sent successfully
- [ ] Monitoring enabled in SendGrid dashboard
- [ ] Alert configured for delivery failures
- [ ] SPF/DKIM/DMARC records configured

## Monitoring

**SendGrid Dashboard:**
- Activity: https://app.sendgrid.com/activity
- Statistics: https://app.sendgrid.com/statistics
- Alerts: https://app.sendgrid.com/alerts

**Set Up Alerts:**
1. Go to Settings → Alerts
2. Create alert for:
   - Bounce rate > 5%
   - Spam rate > 0.1%
   - Daily usage approaching limit
