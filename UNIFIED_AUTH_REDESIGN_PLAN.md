# 🔐 Unified Authentication System - Redesign Plan

## Current System Issues

❌ OTP-based login only (no password authentication)
❌ Separate login flows for different roles
❌ Port 5173 for users, port 5174 for vendors (confusing)
❌ No password storage in database

## New System Design

✅ **One unified auth table** (users table with password_hash)
✅ **One login endpoint** (`POST /api/auth/login`)
✅ **Password-based authentication** (BCrypt hashed)
✅ **Role-based access control** (USER, VENDOR, ADMIN)
✅ **Separate frontend pages** (user login on 5173, vendor/admin login on 5174)

---

## Database Design

### Unified Auth Table (users)

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,  -- BCrypt hash
    role VARCHAR(20) NOT NULL,            -- USER | VENDOR | ADMIN
    account_active BOOLEAN DEFAULT true,
    vendor_status VARCHAR(20),            -- PENDING | APPROVED | REJECTED | SUSPENDED
    company_name VARCHAR(255),
    account_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Separate Profile Tables (Optional - for additional data)

```sql
-- User profiles (customers)
CREATE TABLE user_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id),
    address TEXT,
    preferences JSONB
);

-- Vendor profiles (restaurants)
CREATE TABLE vendor_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id),
    restaurant_name VARCHAR(255),
    restaurant_address TEXT,
    gst_number VARCHAR(50),
    fssai_number VARCHAR(50),
    canteen_id BIGINT REFERENCES canteens(id)
);

-- Admin profiles
CREATE TABLE admin_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id),
    department VARCHAR(100),
    permissions JSONB
);
```

---

## API Design

### Single Login Endpoint

```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123"
}

Response:
{
  "success": true,
  "accessToken": "eyJhbGc...",
  "refreshToken": "...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "role": "VENDOR",
    "companyName": "My Restaurant"
  }
}
```

### JWT Payload

```json
{
  "sub": "user@example.com",
  "userId": 1,
  "role": "VENDOR",
  "iat": 1234567890,
  "exp": 1234571490
}
```

---

## Frontend Design

### Port 5173 - User Login (Customers)
- URL: `http://localhost:5173/login`
- For: Regular users (customers)
- After login: Redirect to `/home`
- Access: Order food, view canteens, manage profile

### Port 5174 - Vendor/Admin Login
- URL: `http://localhost:5174/login`
- For: Vendors and Admins
- After login:
  - VENDOR → Redirect to `/vendor-dashboard`
  - ADMIN → Redirect to `/admin-dashboard`
- Access: Manage menu, view orders, analytics

---

## Spring Security Configuration

### Role-Based Access Control

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) {
        http
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/canteens/**").permitAll()
                
                // User endpoints
                .requestMatchers("/api/user/**").hasRole("USER")
                
                // Vendor endpoints
                .requestMatchers("/api/vendor/**").hasAnyRole("VENDOR", "ADMIN")
                
                // Admin endpoints
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                
                // Everything else requires authentication
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

---

## Implementation Steps

### Step 1: Database Migration

Create migration to add `password_hash` column (already exists in your User entity):

```sql
-- V13__add_password_authentication.sql
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- Set default passwords for existing users (for testing)
UPDATE users 
SET password_hash = '$2a$10$...' -- BCrypt hash of 'password123'
WHERE password_hash IS NULL;
```

### Step 2: Update AuthService

```java
@Service
public class UnifiedAuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    
    public LoginResponse login(String email, String password) {
        // Find user
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));
        
        // Verify password
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid credentials");
        }
        
        // Check account status
        if (!user.getAccountActive()) {
            throw new AccountDisabledException("Account is disabled");
        }
        
        // Check vendor status
        if (user.getRole() == Role.VENDOR && 
            user.getVendorStatus() != VendorStatus.APPROVED) {
            throw new VendorNotApprovedException("Vendor not approved");
        }
        
        // Generate JWT
        String accessToken = jwtUtil.generateToken(user);
        String refreshToken = jwtUtil.generateRefreshToken(user);
        
        return LoginResponse.builder()
            .success(true)
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .user(UserDTO.from(user))
            .build();
    }
}
```

### Step 3: Update AuthController

```java
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    private final UnifiedAuthService authService;
    
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        LoginResponse response = authService.login(
            request.getEmail(), 
            request.getPassword()
        );
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(@RequestBody RegisterRequest request) {
        // Register new user with hashed password
        RegisterResponse response = authService.register(request);
        return ResponseEntity.ok(response);
    }
}
```

### Step 4: Frontend - User Login (Port 5173)

```jsx
// src/pages/Login.jsx
function UserLogin() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  const handleLogin = async () => {
    const response = await api.post('/api/auth/login', {
      email,
      password
    });
    
    localStorage.setItem('token', response.data.accessToken);
    localStorage.setItem('role', response.data.user.role);
    
    // Redirect based on role
    if (response.data.user.role === 'USER') {
      navigate('/home');
    } else {
      alert('Please use vendor/admin login portal');
    }
  };
  
  return (
    <div>
      <h1>Customer Login</h1>
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
      <button onClick={handleLogin}>Login</button>
    </div>
  );
}
```

### Step 5: Frontend - Vendor/Admin Login (Port 5174)

```jsx
// src/pages/VendorLogin.jsx
function VendorLogin() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  const handleLogin = async () => {
    const response = await api.post('/api/auth/login', {
      email,
      password
    });
    
    localStorage.setItem('token', response.data.accessToken);
    localStorage.setItem('role', response.data.user.role);
    
    // Redirect based on role
    if (response.data.user.role === 'VENDOR') {
      navigate('/vendor-dashboard');
    } else if (response.data.user.role === 'ADMIN') {
      navigate('/admin-dashboard');
    } else {
      alert('Please use customer login portal');
    }
  };
  
  return (
    <div>
      <h1>Vendor / Admin Login</h1>
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
      <button onClick={handleLogin}>Login</button>
    </div>
  );
}
```

---

## Access Control Matrix

| Role | Login Portal | Dashboard | Endpoints | Permissions |
|------|-------------|-----------|-----------|-------------|
| USER | Port 5173 | /home | /api/user/** | Order food, view canteens |
| VENDOR | Port 5174 | /vendor-dashboard | /api/vendor/** | Manage menu, view orders |
| ADMIN | Port 5174 | /admin-dashboard | /api/admin/** | Full system access |

---

## Security Features

✅ **Password Hashing**: BCrypt with salt
✅ **JWT Authentication**: Stateless tokens
✅ **Role-Based Access**: Spring Security RBAC
✅ **Account Status**: Active/Inactive flag
✅ **Vendor Approval**: Pending/Approved/Rejected
✅ **Refresh Tokens**: Long-lived tokens for session renewal
✅ **CORS Protection**: Separate origins for user/vendor portals

---

## Migration Strategy

### Phase 1: Add Password Support (Keep OTP)
- Add password_hash column
- Allow both OTP and password login
- Gradually migrate users to password

### Phase 2: Deprecate OTP
- Make password mandatory
- Remove OTP code
- Update documentation

### Phase 3: Separate Portals
- Deploy user portal on 5173
- Deploy vendor/admin portal on 5174
- Update DNS/routing

---

## Test Credentials (After Migration)

### Users (Port 5173)
```
Email: nikita.a@omoikaneinnovations.com
Password: password123
Role: USER
```

### Vendors (Port 5174)
```
Email: vendor@restaurant.com
Password: vendor123
Role: VENDOR
Status: APPROVED
```

### Admins (Port 5174)
```
Email: admin@omoikaneinnovations.com
Password: admin123
Role: ADMIN
```

---

**This design follows industry best practices for multi-role authentication!** 🎉
