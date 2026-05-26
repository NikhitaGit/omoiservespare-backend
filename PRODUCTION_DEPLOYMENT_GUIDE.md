# 🚀 Production Deployment Guide - HR Integration

## 🎯 Question: What to do with Mock Files in Production?

You have **2 options** when deploying to production:

---

## ✅ Option 1: Keep Mock Files (RECOMMENDED)

### Why Keep Them?

1. **Fallback Mechanism**: If HR API goes down, you can quickly switch back to mock mode
2. **Testing in Production**: Test new features without affecting real HR data
3. **Disaster Recovery**: Quick recovery if HR API has issues
4. **Staging Environment**: Use same codebase for staging with mock data
5. **No Code Changes**: Just configuration change
6. **Zero Risk**: Mock code won't run when `hr.api.enabled=true`

### What to Do:

**Step 1: Update Configuration**
```properties
# application.properties (Production)
hr.api.enabled=true
hr.api.base-url=https://your-actual-hr-api.com/v1
hr.api.token=your-actual-production-api-token
hr.api.timeout=30000
```

**Step 2: Deploy**
- Deploy your application as-is
- Mock files will be included but NOT used
- HRApiService will call real HR API

**Step 3: Verify**
- Check logs: Should see "Fetching employee data from HR API"
- Should NOT see "using mock HR data service"

### Files to Keep:
- ✅ `MockHRDataService.java` - Keep (won't be used)
- ✅ `HRMockDataController.java` - Keep (can disable endpoint if needed)
- ✅ All documentation files

### Benefits:
```
Production (hr.api.enabled=true)
    ↓
HRApiService → Real HR API ✅
    ↓
Mock files exist but NOT called
    ↓
Zero performance impact
```

### Quick Rollback:
If HR API fails:
```properties
# Emergency rollback
hr.api.enabled=false
```
Restart → Instantly back to mock mode!

---

## ⚠️ Option 2: Delete Mock Files (NOT Recommended)

### Why Delete?

1. **Cleaner Codebase**: Remove unused code
2. **Smaller Deployment**: Slightly smaller JAR file
3. **No Confusion**: Clear that only production API is used

### What to Do:

**Step 1: Delete Files**
```bash
# Delete mock files
rm src/main/java/com/omoikaneinnovations/omoiservespare/service/MockHRDataService.java
rm src/main/java/com/omoikaneinnovations/omoiservespare/controller/HRMockDataController.java
```

**Step 2: Update HRApiService**

Remove mock dependency from constructor:
```java
// BEFORE
public HRApiService(RestTemplate restTemplate, MockHRDataService mockHRDataService) {
    this.restTemplate = restTemplate;
    this.mockHRDataService = mockHRDataService;
}

// AFTER
public HRApiService(RestTemplate restTemplate) {
    this.restTemplate = restTemplate;
}
```

Remove mock field:
```java
// REMOVE THIS
private final MockHRDataService mockHRDataService;
```

Update methods to remove mock calls:
```java
// BEFORE
if (!hrApiEnabled) {
    return mockHRDataService.findByEmail(email);
}

// AFTER
if (!hrApiEnabled) {
    logger.warn("HR API is disabled and no mock service available");
    return Optional.empty();
}
```

**Step 3: Update Configuration**
```properties
hr.api.enabled=true
hr.api.base-url=https://your-actual-hr-api.com/v1
hr.api.token=your-actual-production-api-token
```

**Step 4: Test & Deploy**
```bash
mvn clean compile
mvn test
mvn package
# Deploy
```

### Drawbacks:
- ❌ No fallback if HR API fails
- ❌ Cannot test in production environment
- ❌ Need code changes for staging
- ❌ More complex rollback process

---

## 🏆 Recommended Approach: Option 1

### Production Configuration:

**application.properties (Production)**
```properties
# ===============================
# HR API INTEGRATION CONFIG
# ===============================
hr.api.enabled=true
hr.api.base-url=https://your-company-hr-api.com/v1
hr.api.token=${HR_API_TOKEN}  # Use environment variable
hr.api.timeout=30000
```

**application.properties (Staging)**
```properties
# ===============================
# HR API INTEGRATION CONFIG
# ===============================
hr.api.enabled=false  # Use mock data in staging
hr.api.base-url=https://api.hrcompany.com/v1
hr.api.token=demo-token
hr.api.timeout=30000
```

**application.properties (Development)**
```properties
# ===============================
# HR API INTEGRATION CONFIG
# ===============================
hr.api.enabled=false  # Use mock data in development
hr.api.base-url=https://api.hrcompany.com/v1
hr.api.token=demo-token
hr.api.timeout=30000
```

### Security Best Practices:

**1. Use Environment Variables:**
```properties
hr.api.token=${HR_API_TOKEN:demo-token}
```

**2. Secure API Token:**
```bash
# Set in production environment
export HR_API_TOKEN=your-actual-token
```

**3. Disable Mock Endpoints (Optional):**

Add to `HRMockDataController.java`:
```java
@RestController
@RequestMapping("/api/hr-mock")
@CrossOrigin(origins = "http://localhost:5173", allowCredentials = "true")
@Profile("!production")  // Only available in non-production
public class HRMockDataController {
    // ... existing code
}
```

Or use configuration:
```properties
# Disable mock endpoints in production
management.endpoints.web.exposure.exclude=hr-mock
```

---

## 📋 Production Deployment Checklist

### Before Deployment:

- [ ] Update `hr.api.enabled=true`
- [ ] Configure real HR API URL
- [ ] Set production API token (use environment variable)
- [ ] Test HR API connectivity
- [ ] Verify employee data format matches
- [ ] Test all authentication scenarios
- [ ] Check error handling
- [ ] Review logs for any mock references
- [ ] Test failover scenarios
- [ ] Document rollback procedure

### After Deployment:

- [ ] Verify HR API is being called (check logs)
- [ ] Confirm mock services are NOT being used
- [ ] Test login with real employees
- [ ] Monitor API response times
- [ ] Check error rates
- [ ] Verify OTP delivery
- [ ] Test edge cases
- [ ] Monitor system performance

---

## 🔄 Deployment Scenarios

### Scenario 1: Gradual Rollout
```properties
# Week 1: Test with mock in production
hr.api.enabled=false

# Week 2: Enable for 10% of users
hr.api.enabled=true
# Use feature flag for gradual rollout

# Week 3: Enable for all users
hr.api.enabled=true
```

### Scenario 2: Blue-Green Deployment
```
Blue Environment (Current):
  hr.api.enabled=false (mock)

Green Environment (New):
  hr.api.enabled=true (real API)

Test Green → Switch traffic → Keep Blue as backup
```

### Scenario 3: Canary Deployment
```
Canary Instance:
  hr.api.enabled=true (5% traffic)

Main Instances:
  hr.api.enabled=false (95% traffic)

Monitor → Increase canary → Full rollout
```

---

## 🆘 Troubleshooting Production

### Issue: HR API Not Responding

**Quick Fix:**
```properties
# Rollback to mock
hr.api.enabled=false
```
Restart application → Service restored

### Issue: Invalid Employee Data

**Check:**
1. HR API response format
2. Field mappings in HREmployeeDTO
3. Data validation logic

### Issue: Performance Problems

**Solutions:**
1. Increase timeout: `hr.api.timeout=60000`
2. Add caching layer
3. Implement circuit breaker
4. Use async calls

---

## 📊 Monitoring Production

### Key Metrics to Monitor:

1. **HR API Response Time**
   - Target: < 500ms
   - Alert: > 2000ms

2. **HR API Success Rate**
   - Target: > 99%
   - Alert: < 95%

3. **Authentication Success Rate**
   - Target: > 95%
   - Alert: < 90%

4. **OTP Delivery Rate**
   - Target: > 98%
   - Alert: < 95%

### Log Monitoring:

**Look for:**
```
✅ "Fetching employee data from HR API"
✅ "Successfully fetched employee data"
❌ "Error fetching employee data from HR API"
❌ "using mock HR data service" (should NOT appear)
```

---

## 🎯 Final Recommendation

### For Production: Keep Mock Files ✅

**Configuration:**
```properties
hr.api.enabled=true
hr.api.base-url=https://your-hr-api.com/v1
hr.api.token=${HR_API_TOKEN}
```

**Files to Keep:**
- ✅ MockHRDataService.java
- ✅ HRMockDataController.java
- ✅ All documentation

**Why:**
- Zero risk (mock won't run)
- Instant fallback capability
- Same codebase for all environments
- Easy testing and debugging
- Professional disaster recovery

**That's it!** Just change the configuration and deploy. The mock files will remain dormant until needed.

---

## 📞 Quick Reference

### Enable Production Mode:
```properties
hr.api.enabled=true
```

### Rollback to Mock:
```properties
hr.api.enabled=false
```

### Check Current Mode:
```bash
curl http://localhost:8080/api/hr-mock/statistics
# If returns data → Mock mode
# If returns 404 → Production mode (if endpoint disabled)
```

**Simple, safe, and production-ready!** 🚀
