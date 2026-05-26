# 🏢 Multi-Company Implementation - Step-by-Step Guide

## 📋 Overview

This guide explains how to implement multi-company support so your application can handle multiple companies, each with their own HR API configuration.

---

## 🎯 What You'll Achieve

### Before (Current):
```
Single Company → Single HR API URL → All users from one company
```

### After (Multi-Company):
```
Company A → HR API A → Company A users
Company B → HR API B → Company B users  
Company C → HR API C → Company C users
```

---

## 📊 Step 1: Database Setup

### Create Migration File

**File**: `V6__create_company_configs_table.sql`

**Already created!** This file will:
- Create `company_configs` table
- Add indexes for fast lookups
- Insert 4 default companies for testing

### Run Migration

```bash
# Stop application
# Restart to run migration
mvn spring-boot:run
```

**Look for:**
```
Flyway: Migrating schema to version 6 - create company configs table
Flyway: Successfully applied 1 migration
```

### Verify Table Created

```sql
-- Check table exists
SELECT * FROM company_configs;

-- Should show 4 companies:
-- 1. Omoiservespare Pvt Ltd
-- 2. Omoikane Innovations
-- 3. Tech Corp
-- 4. Innovation Labs
```

---

## 💾 Step 2: Create Entity Class

### File: `CompanyConfig.java`

```java
package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

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
    
    // Additional Settings
    @Column(columnDefinition = "jsonb")
    private String additionalSettings;
    
    // Constructors
    public CompanyConfig() {}
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    
    public String getCompanyCode() { return companyCode; }
    public void setCompanyCode(String companyCode) { this.companyCode = companyCode; }
    
    public Boolean getHrApiEnabled() { return hrApiEnabled; }
    public void setHrApiEnabled(Boolean hrApiEnabled) { this.hrApiEnabled = hrApiEnabled; }
    
    public String getHrApiBaseUrl() { return hrApiBaseUrl; }
    public void setHrApiBaseUrl(String hrApiBaseUrl) { this.hrApiBaseUrl = hrApiBaseUrl; }
    
    public String getHrApiToken() { return hrApiToken; }
    public void setHrApiToken(String hrApiToken) { this.hrApiToken = hrApiToken; }
    
    public Integer getHrApiTimeout() { return hrApiTimeout; }
    public void setHrApiTimeout(Integer hrApiTimeout) { this.hrApiTimeout = hrApiTimeout; }
    
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    
    public Integer getMaxEmployees() { return maxEmployees; }
    public void setMaxEmployees(Integer maxEmployees) { this.maxEmployees = maxEmployees; }
    
    public String getSubscriptionTier() { return subscriptionTier; }
    public void setSubscriptionTier(String subscriptionTier) { this.subscriptionTier = subscriptionTier; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
    
    public String getAdditionalSettings() { return additionalSettings; }
    public void setAdditionalSettings(String additionalSettings) { this.additionalSettings = additionalSettings; }
}
```

---

## 📦 Step 3: Create Repository

### File: `CompanyConfigRepository.java`

```java
package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.CompanyConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CompanyConfigRepository extends JpaRepository<CompanyConfig, Long> {
    
    Optional<CompanyConfig> findByCompanyName(String companyName);
    
    Optional<CompanyConfig> findByCompanyCode(String companyCode);
    
    Optional<CompanyConfig> findByCompanyNameAndIsActive(String companyName, Boolean isActive);
    
    List<CompanyConfig> findByIsActive(Boolean isActive);
    
    @Query("SELECT c FROM CompanyConfig c WHERE LOWER(c.companyName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<CompanyConfig> searchByCompanyName(@Param("searchTerm") String searchTerm);
    
    boolean existsByCompanyName(String companyName);
}
```

---

## 🔧 Step 4: Create Service

### File: `CompanyConfigService.java`

```java
package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.CompanyConfig;
import com.omoikaneinnovations.omoiservespare.repository.CompanyConfigRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

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
        config.ifPresent(c -> {
            configCache.put(companyName, c);
            logger.info("Loaded and cached config for: {}", companyName);
        });
        
        if (config.isEmpty()) {
            logger.warn("No active configuration found for company: {}", companyName);
        }
        
        return config;
    }
    
    /**
     * Validate if company exists and is active
     */
    public boolean isValidCompany(String companyName) {
        return getCompanyConfig(companyName).isPresent();
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
        
        logger.info("Saved company config: {} (ID: {})", saved.getCompanyName(), saved.getId());
        return saved;
    }
    
    /**
     * Get all active companies
     */
    public List<CompanyConfig> getAllActiveCompanies() {
        return companyConfigRepository.findByIsActive(true);
    }
    
    /**
     * Clear cache (useful for testing or after updates)
     */
    public void clearCache() {
        configCache.clear();
        logger.info("Company config cache cleared");
    }
    
    /**
     * Get cache statistics
     */
    public Map<String, Object> getCacheStats() {
        return Map.of(
            "cachedCompanies", configCache.size(),
            "companies", configCache.keySet()
        );
    }
}
```

---

## 🔄 Step 5: Update HRApiService

### Modify to use CompanyConfigService

```java
// Add to constructor
private final CompanyConfigService companyConfigService;

public HRApiService(
        RestTemplate restTemplate, 
        MockHRDataService mockHRDataService,
        CompanyConfigService companyConfigService) {
    this.restTemplate = restTemplate;
    this.mockHRDataService = mockHRDataService;
    this.companyConfigService = companyConfigService;
}

// Update getEmployeeByEmail method
public Optional<HREmployeeDTO> getEmployeeByEmail(String companyName, String email) {
    // Get company-specific configuration
    Optional<CompanyConfig> configOpt = companyConfigService.getCompanyConfig(companyName);
    
    if (configOpt.isEmpty()) {
        logger.warn("No configuration found for company: {}", companyName);
        return Optional.empty();
    }
    
    CompanyConfig config = configOpt.get();
    
    // Use mock data if HR API is disabled for this company
    if (!config.getHrApiEnabled()) {
        logger.info("HR API disabled for {}, using mock data", companyName);
        return mockHRDataService.findByEmail(email);
    }
    
    // Call company-specific HR API
    logger.info("Calling HR API for {}: {}", companyName, config.getHrApiBaseUrl());
    return callCompanyHRApi(config, "/employees/by-email/" + email);
}

// Add new method for company-specific API calls
private Optional<HREmployeeDTO> callCompanyHRApi(CompanyConfig config, String endpoint) {
    try {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + config.getHrApiToken());
        headers.setContentType(MediaType.APPLICATION_JSON);
        
        HttpEntity<String> entity = new HttpEntity<>(headers);
        
        String url = config.getHrApiBaseUrl() + endpoint;
        
        ResponseEntity<HREmployeeDTO> response = restTemplate.exchange(
            url, 
            HttpMethod.GET, 
            entity, 
            HREmployeeDTO.class
        );
        
        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            logger.info("Successfully fetched employee data from company HR API");
            return Optional.of(response.getBody());
        }
    } catch (Exception e) {
        logger.error("Error calling company HR API: " + endpoint, e);
    }
    
    return Optional.empty();
}
```

---

## 🧪 Step 6: Testing

### Test 1: Verify Database

```sql
SELECT company_name, company_code, hr_api_enabled, is_active 
FROM company_configs;
```

**Expected**: 4 companies

### Test 2: Test API

```bash
# Get all companies
curl http://localhost:8080/api/hr-mock/statistics

# Login with Company A
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Omoiservespare Pvt Ltd",
    "email": "nikita.a@omoikaneinnovations.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'

# Login with Company B
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "Tech Corp",
    "email": "michael.johnson@techcorp.com",
    "phoneNumber": "",
    "accountType": "PROFESSIONAL"
  }'
```

---

## 📋 Step 7: Add Management API

### Create Controller for Company Management

```java
@RestController
@RequestMapping("/api/admin/companies")
public class CompanyConfigController {
    
    private final CompanyConfigService companyConfigService;
    
    @GetMapping
    public ResponseEntity<List<CompanyConfig>> getAllCompanies() {
        return ResponseEntity.ok(companyConfigService.getAllActiveCompanies());
    }
    
    @GetMapping("/{companyName}")
    public ResponseEntity<CompanyConfig> getCompany(@PathVariable String companyName) {
        return companyConfigService.getCompanyConfig(companyName)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<CompanyConfig> createCompany(@RequestBody CompanyConfig config) {
        CompanyConfig saved = companyConfigService.saveCompanyConfig(config);
        return ResponseEntity.ok(saved);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<CompanyConfig> updateCompany(
            @PathVariable Long id, 
            @RequestBody CompanyConfig config) {
        config.setId(id);
        CompanyConfig updated = companyConfigService.saveCompanyConfig(config);
        return ResponseEntity.ok(updated);
    }
}
```

---

## ✅ Summary

### What You've Implemented:

1. ✅ Database table for company configurations
2. ✅ Entity and Repository for data access
3. ✅ Service layer with caching
4. ✅ Updated HR API service for multi-company
5. ✅ Management API for companies

### How It Works:

```
User Login (Company: "Tech Corp")
    ↓
Get company config from database
    ↓
Use Tech Corp's HR API URL and token
    ↓
Fetch employee from Tech Corp's HR system
    ↓
Complete login
```

### Benefits:

- ✅ Support unlimited companies
- ✅ Each company has own HR API
- ✅ Easy to add new companies
- ✅ Cached for performance
- ✅ Production-ready architecture

**You're now ready for multi-company support!** 🚀
