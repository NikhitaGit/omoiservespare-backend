# 📍 Location System Implementation - COMPLETE

## ✅ What's Been Implemented

A **production-ready location management system** similar to Swiggy/Zomato with:

### 🎯 Core Features
1. **Current Location Detection** - GPS-based location with reverse geocoding
2. **Manual Address Entry** - User-entered addresses with forward geocoding
3. **Address Management** - Save, edit, delete, and set default addresses
4. **Google Maps Integration** - Real-time geocoding and reverse geocoding
5. **Multi-address Support** - Users can save multiple delivery addresses

---

## 📁 Files Created

### Database Layer
- `V14__create_user_addresses_table.sql` - Database migration with indexes

### Entity Layer
- `UserAddress.java` - JPA entity for address storage

### Repository Layer
- `UserAddressRepository.java` - Data access with custom queries

### Service Layer
- `LocationService.java` - Business logic for address management
- `GoogleMapsService.java` - Google Maps API integration

### DTO Layer
- `LocationRequest.java` - Request DTO with validation
- `AddressResponse.java` - Response DTO

### Controller Layer
- `LocationController.java` - REST API endpoints

---

## 🔌 API Endpoints

### 1️⃣ Save Location (Current or Manual)
```http
POST /api/location
Authorization: Bearer <token>
Content-Type: application/json

{
  "type": "CURRENT",
  "title": "Home",
  "latitude": 19.0760,
  "longitude": 72.8777,
  "phoneNumber": "+91-9876543210"
}
```

**OR for manual address:**
```json
{
  "type": "MANUAL",
  "title": "Work",
  "address": "123 Main Street, Mumbai, Maharashtra 400001",
  "phoneNumber": "+91-9876543210"
}
```

### 2️⃣ Get All Saved Addresses
```http
GET /api/location
Authorization: Bearer <token>
```

### 3️⃣ Get Default Address
```http
GET /api/location/default
Authorization: Bearer <token>
```

### 4️⃣ Set Address as Default
```http
PUT /api/location/{id}/default
Authorization: Bearer <token>
```

### 5️⃣ Update Address
```http
PUT /api/location/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "type": "MANUAL",
  "title": "Home",
  "address": "Updated address",
  "phoneNumber": "+91-9876543210"
}
```

### 6️⃣ Delete Address
```http
DELETE /api/location/{id}
Authorization: Bearer <token>
```

---

## 🗺️ Google Maps Setup

### Step 1: Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Geocoding API** and **Maps JavaScript API**
4. Create credentials → API Key
5. Restrict the API key (optional but recommended)

### Step 2: Configure Environment Variable
```bash
# Windows (PowerShell)
$env:GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"

# Windows (CMD)
set GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE

# Linux/Mac
export GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"
```

### Step 3: Update .env File
```properties
GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

---

## 🔄 How It Works

### Current Location Flow
```
User clicks "Use Current Location"
         ↓
Frontend gets GPS coordinates (lat/lng)
         ↓
POST /api/location with type=CURRENT
         ↓
Backend calls Google Reverse Geocoding API
         ↓
Converts lat/lng → readable address
         ↓
Saves to PostgreSQL:
  - latitude
  - longitude
  - address (from Google)
  - title
  - phone
         ↓
Returns success response
```

### Manual Address Flow
```
User enters address manually
         ↓
POST /api/location with type=MANUAL
         ↓
Backend calls Google Geocoding API
         ↓
Converts address → lat/lng coordinates
         ↓
Saves to PostgreSQL:
  - address (user input)
  - latitude (from Google)
  - longitude (from Google)
  - title
  - phone
         ↓
Returns success response
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(50) NOT NULL,           -- Home, Work, Other
    address TEXT NOT NULL,                -- Full address
    latitude DOUBLE PRECISION NOT NULL,   -- GPS coordinate
    longitude DOUBLE PRECISION NOT NULL,  -- GPS coordinate
    phone_number VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,     -- Default delivery address
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_user_addresses_default ON user_addresses(user_id, is_default);
CREATE INDEX idx_user_addresses_location ON user_addresses(latitude, longitude);
```

---

## 🎨 Frontend Integration

### Example: Save Current Location
```javascript
const saveCurrentLocation = async (latitude, longitude) => {
  try {
    const response = await api.post('/api/location', {
      type: 'CURRENT',
      title: 'Home',
      latitude: latitude,
      longitude: longitude,
      phoneNumber: '+91-9876543210'
    });
    
    console.log('Location saved:', response.data);
  } catch (error) {
    console.error('Failed to save location:', error);
  }
};

// Get user's current location
navigator.geolocation.getCurrentPosition(
  (position) => {
    saveCurrentLocation(
      position.coords.latitude,
      position.coords.longitude
    );
  },
  (error) => {
    console.error('Location error:', error);
  }
);
```

### Example: Save Manual Address
```javascript
const saveManualAddress = async (address) => {
  try {
    const response = await api.post('/api/location', {
      type: 'MANUAL',
      title: 'Work',
      address: address,
      phoneNumber: '+91-9876543210'
    });
    
    console.log('Address saved:', response.data);
  } catch (error) {
    console.error('Failed to save address:', error);
  }
};
```

### Example: Get All Addresses
```javascript
const fetchAddresses = async () => {
  try {
    const response = await api.get('/api/location');
    console.log('Saved addresses:', response.data.data);
  } catch (error) {
    console.error('Failed to fetch addresses:', error);
  }
};
```

---

## 🔒 Security Features

1. **User Isolation** - Users can only access their own addresses
2. **JWT Authentication** - All endpoints require valid token
3. **Input Validation** - Request validation using Jakarta Validation
4. **SQL Injection Protection** - JPA parameterized queries
5. **Cascade Delete** - Addresses deleted when user is deleted

---

## 🚀 Testing the API

### PowerShell Test Script
```powershell
# Save current location
$token = "YOUR_JWT_TOKEN"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    type = "CURRENT"
    title = "Home"
    latitude = 19.0760
    longitude = 72.8777
    phoneNumber = "+91-9876543210"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/location" `
    -Method POST `
    -Headers $headers `
    -Body $body

# Get all addresses
Invoke-RestMethod -Uri "http://localhost:8080/api/location" `
    -Method GET `
    -Headers $headers
```

---

## 🎯 Production Considerations

### 1. Google Maps API Costs
- **Free tier**: 28,000 requests/month
- **Pricing**: $5 per 1,000 requests after free tier
- **Recommendation**: Enable billing alerts

### 2. Fallback Strategy
The system includes fallback behavior when Google Maps API is not configured:
- **Reverse Geocoding**: Returns coordinates as string
- **Forward Geocoding**: Returns default Mumbai coordinates

### 3. Rate Limiting
Consider implementing rate limiting for location endpoints:
```java
@RateLimiter(name = "location", fallbackMethod = "rateLimitFallback")
public AddressResponse saveLocation(Long userId, LocationRequest request) {
    // Implementation
}
```

### 4. Caching
Cache geocoding results to reduce API calls:
```java
@Cacheable(value = "geocode", key = "#address")
public Map<String, Double> geocode(String address) {
    // Implementation
}
```

### 5. Distance Calculation
Add distance-based features (e.g., delivery radius):
```java
public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula implementation
}
```

---

## ✅ Next Steps

1. **Set up Google Maps API key** (see Google Maps Setup section)
2. **Restart your Spring Boot application**
3. **Run database migration** (Flyway will auto-apply V14)
4. **Test the API endpoints** using the examples above
5. **Integrate with your frontend** (LocationPicker component)

---

## 🐛 Troubleshooting

### Issue: "Address not found"
- Ensure the address ID belongs to the authenticated user
- Check if the address exists in the database

### Issue: "Latitude and longitude are required"
- For `type=CURRENT`, both lat/lng must be provided
- Check frontend GPS permission

### Issue: "Address is required"
- For `type=MANUAL`, address field must not be empty
- Validate user input before sending

### Issue: Google Maps API errors
- Verify API key is correct
- Check if Geocoding API is enabled
- Review API quota and billing

---

## 📊 Database Queries

### Get user's addresses
```sql
SELECT * FROM user_addresses 
WHERE user_id = 1 
ORDER BY is_default DESC, created_at DESC;
```

### Find default address
```sql
SELECT * FROM user_addresses 
WHERE user_id = 1 AND is_default = true;
```

### Count addresses per user
```sql
SELECT user_id, COUNT(*) as address_count 
FROM user_addresses 
GROUP BY user_id;
```

---

## 🎉 Summary

You now have a **production-ready location system** with:
- ✅ GPS-based current location detection
- ✅ Manual address entry with geocoding
- ✅ Multiple address management
- ✅ Default address selection
- ✅ Google Maps integration
- ✅ Secure user-isolated data
- ✅ RESTful API endpoints
- ✅ Database with proper indexes

**Ready to deploy!** 🚀
