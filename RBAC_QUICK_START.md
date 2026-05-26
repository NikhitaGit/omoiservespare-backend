# 🚀 RBAC Quick Start Guide

## 5-Minute Setup

### Step 1: Add AspectJ Dependency (30 seconds)

Add to `pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

### Step 2: Run Application (1 minute)

```bash
mvn spring-boot:run
```

Flyway will automatically run the V10 migration and add RBAC columns.

### Step 3: Create Admin User (30 seconds)

Run in PostgreSQL:

```sql
INSERT INTO users (company_name, email, role, account_active, created_at, updated_at)
VALUES ('System Admin', 'admin@omoiservespare.com', 'ADMIN', TRUE, NOW(), NOW());
```

### Step 4: Protect Your First Endpoint (2 minutes)

```java
import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.security.RequireRole;

@RestController
@RequestMapping("/api/admin")
public class AdminDashboardController {
    
    @GetMapping("/dashboard")
    @RequireRole(Role.ADMIN)  // ← Add this line
    public ResponseEntity<?> getDashboard() {
        return ResponseEntity.ok("Dashboard data");
    }
}
```

### Step 5: Test It (1 minute)

```bash
# Try without token - should fail
curl http://localhost:8080/api/admin/dashboard

# Login as admin
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@omoiservespare.com","password":"your-password"}'

# Use token - should work
curl http://localhost:8080/api/admin/dashboard \
  -H "Authorization: Bearer <your-token>"
```

---

## Common Patterns

### Pattern 1: Admin-Only

```java
@RequireRole(Role.ADMIN)
public ResponseEntity<?> adminAction() { ... }
```

### Pattern 2: Vendor with Approval

```java
@RequireRole(Role.VENDOR)
@RequireVendorApproval
public ResponseEntity<?> vendorAction() { ... }
```

### Pattern 3: User-Only

```java
@RequireRole(Role.USER)
public ResponseEntity<?> userAction() { ... }
```

### Pattern 4: Multiple Roles

```java
@RequireRole({Role.VENDOR, Role.ADMIN})
public ResponseEntity<?> multiRoleAction() { ... }
```

### Pattern 5: Get Current User

```java
@RequireRole(Role.USER)
public ResponseEntity<?> getProfile() {
    User currentUser = SecurityUtils.getCurrentUser();
    return ResponseEntity.ok(currentUser);
}
```

---

## Update Existing Endpoints

### Before:
```java
@GetMapping("/orders")
public ResponseEntity<?> getOrders() {
    return orderService.getAllOrders();
}
```

### After:
```java
@GetMapping("/orders")
@RequireRole(Role.ADMIN)  // Only admins can see all orders
public ResponseEntity<?> getOrders() {
    return orderService.getAllOrders();
}
```

---

## Set User Roles

```sql
-- Make user a vendor
UPDATE users SET role = 'VENDOR', vendor_status = 'PENDING' 
WHERE email = 'vendor@example.com';

-- Approve vendor
UPDATE users SET vendor_status = 'APPROVED' 
WHERE email = 'vendor@example.com';

-- Make user an admin
UPDATE users SET role = 'ADMIN' 
WHERE email = 'admin@example.com';

-- Suspend account
UPDATE users SET account_active = FALSE 
WHERE email = 'bad-user@example.com';
```

---

## Done! 🎉

Your RBAC system is now active. Check `RBAC_IMPLEMENTATION_COMPLETE.md` for detailed documentation.
