# 🏢 Multi-Company Architecture - Complete Guide

## 📋 Current Situation

**Single Company Setup:**
```properties
hr.api.enabled=false
hr.api.base-url=https://api.hrcompany.com/v1
hr.api.token=demo-token
```

**Problem:** This only works for ONE company. What if you have multiple companies, each with their own HR system?

---

## 🎯 Multi-Company Solution

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Your Application                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  User Login (Company Name: "Tech Corp")                 │
│         ↓                                                │
│  CompanyConfigService.getConfig("Tech Corp")            │
│         ↓                                                │
│  Returns: Tech Corp's HR API URL & Token                │
│         ↓                                                │
│  HRApiService.getEmployee(config, email)                │
│         ↓                                                │
│  Calls: https://techcorp-hr-api.com/employees           │
│                                                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  User Login (Company Name: "Innovation Labs")           │
│         ↓                                                │
│  CompanyConfigService.getConfig("Innovation Labs")      │
│         ↓                                                │
│  Returns: Innovation Labs' HR API URL & Token           │
│         ↓                                                │
│  HRApiService.getEmployee(config, email)                │
│         ↓                                                │
│  Calls: https://innovationlabs-hr.com/api/v2/employees │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Database Design

### Step 1: Create Company Configuration Table

```sql
CREATE TABLE company_configs (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(255) UNIQUE NOT NULL,
    company_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- HR API Configuration
    hr_api_enabled BOOLEAN DEFAULT true,
    hr_api_base_url VARCHAR(500) NOT NULL,
    hr_api_token VARCHAR(500) NOT NULL,
    hr_api_timeout INTEGER DEFAULT 30000,
    
    -- Company Settings
    is_active BOOLEAN DEFAULT true,
    max_employees INTEGER,
    subscription_tier VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    
    -- Additional Settings (JSON for flexibility)
    additional_settings JSONB
);

-- Indexes for fast lookup
CREATE INDEX idx_company_name ON company_configs(company_name);
CREATE INDEX idx_company_code ON company_configs(company_code);
CREATE INDEX idx_is_active ON company_configs(is_active);
```

### Step 2: Sample Data

```sql
-- Company 1: Omoiservespare
INSERT INTO company_configs (
    company_name, 
    company_code, 
    hr_api_enabled, 
    hr_api_base_url, 
    hr_api_token,
    is_active
) VALUES (
    'Omoiservespare Pvt Ltd',
    'OMOI',
    true,
    'https://omoiservespare-hr.com/api/v1',
    'omoi-secret-token-123',
    true
);

-- Company 2: Tech Corp
INSERT INTO company_configs (
    company_name, 
    company_code, 
    hr_api_enabled, 
    hr_api_base_url, 
    hr_api_token,
    is_active
) VALUES (
    'Tech Corp',
    'TECH',
    true,
    'https://techcorp-hr-api.com/v2',
    'tech-secret-token-456',
    true
);

-- Company 3: Innovation Labs
INSERT INTO company_configs (
    company_name, 
    company_code, 
    hr_api_enabled, 
    hr_api_base_url, 
    hr_api_token,
    is_active
) VALUES (
    'Innovation Labs',
    'INNO',
    true,
    'https://innovation-labs.com/hr/api',
    'inno-secret-token-789',
    true
);
```

---

## 💾 Implementation Steps

### Step 1: Create Entity

```java
@Entity
@Table(name = "company_configs")
public class CompanyConfig {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String companyName;
    
    @Column(unique = true, nullable = false)
    private String companyCode;
    
    // HR API Configuration
    private Boolean hrApiEnabled = true;
    
    @Column(length = 500)
    private String hrApiBaseUrl;
    
    @Column(length = 500)
    private String hrApiToken;
    
    private Integer hrApiTimeout = 30000;
    
    // Company Settings
    private Boolean isActive = true;
    private Integer maxEmployees;
    private String subscriptionTier;
    
    // Metadata
    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    private LocalDateTime updatedAt = LocalDateTime.now();
    private String createdBy;
    
    // Additional Settings (stored as JSON)
    @Column(columnDefinition = "jsonb")
    private String additionalSettings;
    
    // Getters and Setters
    // ... (standard getters/setters)
}
```

### Step 2: Create Repository

```java
@Repository
public interface CompanyConfigRepository extends JpaRepository<CompanyConfig, Long> {
    
    Optional<CompanyConfig> findByCompanyName(String companyName);
    
    Optional<CompanyConfig> findByCompanyCode(String companyCode);
    
    Optional<CompanyConfig> findByCompanyNameAndIsActive(String companyName, Boolean isActive);
    
    List<CompanyConfig> findByIsActive(Boolean isActive);
    
    @Query("SELECT c FROM CompanyConfig c WHERE LOWER(c.companyName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<CompanyConfig> searchByCompanyName(@Param("searchTerm") String searchTerm);
}
```

### Step 3: Create Service

```java
@Service
public class CompanyConfigService {
    
    private static final Logger logger = LoggerFactory.getLogger(CompanyConfigService.class);
    
    private final CompanyConfigRepository companyConfigRepository;
    
    // Cache for frequently accessed configs
    private final Map<String, CompanyConfig> configCache = new ConcurrentHashMap<>();
    
    public CompanyConfigService(CompanyConfigRepository companyConfigRepository) {
        this.companyConfigRepository = companyConfigRepository;
    }
    
    /**
     * Get company configuration by company name
     */
    public Optional<CompanyConfig> getCompanyConfig(String companyName) {
        // Check cache first
        if (configCache.containsKey(companyName)) {
            logger.debug("Returning cached config for: {}", companyName);
            return Optional.of(configCache.get(companyName));
        }
        
        // Fetch from database
        Optional<CompanyConfig> config = companyConfigRepository
            .findByCompanyNameAndIsActive(companyName, true);
        
        // Cache if found
        config.ifPresent(c -> configCache.put(companyName, c));
        
        return config;
    }
    
    /**
     * Get HR API configuration for a company
     */
    public Optional<HRApiConfig> getHRApiConfig(String companyName) {
        return getCompanyConfig(companyName)
            .map(config -> new HRApiConfig(
                config.getHrApiEnabled(),
                config.getHrApiBaseUrl(),
                config.getHrApiToken(),
                config.getHrApiTimeout()
            ));
    }
    
    /**
     * Create or update company configuration
     */
    @Transactional
    public CompanyConfig saveCompanyConfig(CompanyConfig config) {
        config.setUpdatedAt(LocalDateTime.now());
        CompanyConfig saved = companyConfigRepository.save(config);
        
        // Update cache
        configCache.put(saved.getCompanyName(), saved);
        
        logger.info("Saved company config: {}", saved.getCompanyName());
        return saved;
    }
    
    /**
     * Validate if company exists and is active
     */
    public boolean isValidCompany(String companyName) {
        return getCompanyConfig(companyName).isPresent();
    }
    
    /**
     * Clear cache (useful for testing or after updates)
     */
    public void clearCache() {
        configCache.clear();
        logger.info("Company config cache cleared");
    }
    
    /**
     * Get all active companies
     */
    public List<CompanyConfig> getAllActiveCompanies() {
        return companyConfigRepository.findByIsActive(true);
    }
}
```

### Step 4: Create DTO for HR API Config

```java
public class HRApiConfig {
    private Boolean enabled;
    private String baseUrl;
    private String token;
    private Integer timeout;
    
    public HRApiConfig(Boolean enabled, String baseUrl, String token, Integer timeout) {
        this.enabled = enabled;
        this.baseUrl = baseUrl;
        this.token = token;
        this.timeout = timeout;
    }
    
    // Getters
    public Boolean isEnabled() { return enabled; }
    public String getBaseUrl() { return baseUrl; }
    public String getToken() { return token; }
    public Integer getTimeout() { return timeout; }
}
```

### Step 5: Update HRApiService

```java
@Service
public class HRApiService {
    
    private final RestTemplate restTemplate;
    private final MockHRDataService mockHRDataService;
    private final CompanyConfigService companyConfigService;
    
    public HRApiService(
            RestTemplate restTemplate, 
            MockHRDataService mockHRDataService,
            CompanyConfigService companyConfigService) {
        this.restTemplate = restTemplate;
        this.mockHRDataService = mockHRDataService;
        this.companyConfigService = companyConfigService;
    }
    
    /**
     * Get employee by email with company-specific configuration
     */
    public Optional<HREmployeeDTO> getEmployeeByEmail(String companyName, String email) {
        // Get company-specific HR API configuration
        Optional<HRApiConfig> configOpt = companyConfigService.getHRApiConfig(companyName);
        
        if (configOpt.isEmpty()) {
            logger.warn("No HR API configuration found for company: {}", companyName);
            return Optional.empty();
        }
        
        HRApiConfig config = configOpt.get();
        
        // Use mock data if HR API is disabled
        if (!config.isEnabled()) {
            logger.info("HR API disabled for {}, using mock data", companyName);
            return mockHRDataService.findByEmail(email);
        }
        
        // Call company-specific HR API
        return callHRApi(config, "/employees/by-email/" + email, HREmployeeDTO.class);
    }
    
    /**
     * Generic method to call HR API with company-specific config
     */
    private <T> Optional<T> callHRApi(HRApiConfig config, String endpoint, Class<T> responseType) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + config.getToken());
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            String url = config.getBaseUrl() + endpoint;
            
            // Create RestTemplate with company-specific timeout
            RestTemplate customRestTemplate = createRestTemplateWithTimeout(config.getTimeout());
            
            ResponseEntity<T> response = customRestTemplate.exchange(
                url, 
                HttpMethod.GET, 
                entity, 
                responseType
            );
            
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                return Optional.of(response.getBody());
            }
        } catch (Exception e) {
            logger.error("Error calling HR API: " + endpoint, e);
        }
        
        return Optional.empty();
    }
    
    private RestTemplate createRestTemplateWithTimeout(Integer timeout) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(timeout);
        factory.setReadTimeout(timeout);
        return new RestTemplate(factory);
    }
}
```

### Step 6: Update AuthService

```java
@Service
public class AuthService {
    
    private final HRApiService hrApiService;
    private final CompanyConfigService companyConfigService;
    // ... other dependencies
    
    public boolean validateLogin(
            String companyName,
            String email,
            String phoneNumber,
            AccountType accountType) {
        
        logger.info("=== LOGIN VALIDATION START ===");
        logger.info("Company: {}", companyName);
        
        // Step 1: Validate company exists and is active
        if (!companyConfigService.isValidCompany(companyName)) {
            logger.warn("Company not found or inactive: {}", companyName);
            return false;
        }
        
        // Step 2: Fetch employee from company-specific HR API
        Optional<HREmployeeDTO> hrEmployeeOpt = hrApiService.getEmployeeByEmail(companyName, email);
        
        if (hrEmployeeOpt.isEmpty()) {
            logger.warn("Employee not found in HR system: {}", email);
            return false;
        }
        
        // ... rest of validation logic
    }
}
```

---

## 🔄 Complete Flow

### Login Flow with Multiple Companies

```
1. User enters:
   - Company: "Tech Corp"
   - Email: "john@techcorp.com"

2. AuthService.validateLogin()
   ↓
3. CompanyConfigService.getCompanyConfig("Tech Corp")
   ↓
4. Database Query:
   SELECT * FROM company_configs 
   WHERE company_name = 'Tech Corp' 
   AND is_active = true
   ↓
5. Returns:
   {
     hrApiBaseUrl: "https://techcorp-hr-api.com/v2",
     hrApiToken: "tech-secret-token-456",
     hrApiEnabled: true
   }
   ↓
6. HRApiService.getEmployeeByEmail("Tech Corp", "john@techcorp.com")
   ↓
7. HTTP Call:
   GET https://techcorp-hr-api.com/v2/employees/by-email/john@techcorp.com
   Authorization: Bearer tech-secret-token-456
   ↓
8. Returns employee data
   ↓
9. Create/update user in local database
   ↓
10. Generate OTP
    ↓
11. Login success
```

---

## 📋 Migration Strategy

### Phase 1: Add Database Table
```sql
-- Run migration
CREATE TABLE company_configs (...);
```

### Phase 2: Seed Initial Data
```sql
-- Add your current company
INSERT INTO company_configs (...) VALUES (...);
```

### Phase 3: Deploy Code Changes
- Add CompanyConfig entity
- Add CompanyConfigService
- Update HRApiService
- Update AuthService

### Phase 4: Test
- Test with existing company
- Add new company
- Test with new company

### Phase 5: Add Management UI
- Admin panel to add/edit companies
- Company configuration management
- API key rotation

---

## 🎯 Benefits

1. **Scalability**: Support unlimited companies
2. **Flexibility**: Each company can have different HR API
3. **Security**: Company-specific API tokens
4. **Performance**: Caching for frequently accessed configs
5. **Maintainability**: Easy to add/remove companies
6. **Monitoring**: Track per-company API usage

---

## 🔒 Security Considerations

1. **Encrypt API Tokens**: Store encrypted in database
2. **Access Control**: Only admins can manage company configs
3. **Audit Logging**: Track who changes company configs
4. **Token Rotation**: Support for rotating API tokens
5. **Rate Limiting**: Per-company rate limits

---

## 📊 Monitoring

### Metrics to Track:
- API calls per company
- Response times per company
- Error rates per company
- Active companies count
- Employee count per company

### Alerts:
- Company HR API down
- High error rate for specific company
- Slow response times
- Token expiration warnings

---

This architecture allows you to scale from 1 company to 1000+ companies seamlessly!
