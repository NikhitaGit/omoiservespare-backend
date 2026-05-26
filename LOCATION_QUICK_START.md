# 📍 Location System - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Run Database Migration
```powershell
# The migration will run automatically when you start the application
# Flyway will apply V14__create_user_addresses_table.sql
```

### Step 2: Set Google Maps API Key (Optional)
```powershell
# Get API key from: https://console.cloud.google.com/google/maps-apis
$env:GOOGLE_MAPS_API_KEY="YOUR_API_KEY_HERE"

# Or add to .env file:
# GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

**Note**: The system works without Google Maps API (uses fallback coordinates)

### Step 3: Restart Spring Boot
```powershell
# Stop current application (Ctrl+C)
# Then restart
mvn spring-boot:run
```

### Step 4: Test the API
```powershell
# Run the test script
.\test-location-api.ps1
```

---

## 📱 Frontend Integration

### Update Your LocationPicker Component

Add these API calls to your existing `LocationPicker.jsx`:

```javascript
import api from "../api/axiosInstance";

// Save current location
const handleUseCurrentLocation = () => {
  navigator.geolocation.getCurrentPosition(
    async (pos) => {
      try {
        const response = await api.post('/api/location', {
          type: 'CURRENT',
          title: 'Current Location',
          latitude: pos.coords.latitude,
          longitude: pos.coords.longitude,
          phoneNumber: newPhone
        });
        
        console.log('✅ Location saved:', response.data);
        // Refresh address list
        fetchAddresses();
      } catch (error) {
        console.error('❌ Failed to save location:', error);
      }
    },
    (error) => {
      console.error('GPS error:', error);
    }
  );
};

// Save manual address
const handleAddAddress = async () => {
  try {
    const response = await api.post('/api/location', {
      type: 'MANUAL',
      title: newTitle,
      address: newAddress,
      phoneNumber: newPhone
    });
    
    console.log('✅ Address saved:', response.data);
    setShowAdd(false);
    fetchAddresses();
  } catch (error) {
    console.error('❌ Failed to save address:', error);
  }
};

// Fetch all addresses
const fetchAddresses = async () => {
  try {
    const response = await api.get('/api/location');
    setSaved(response.data.data);
  } catch (error) {
    console.error('❌ Failed to fetch addresses:', error);
  }
};

// Delete address
const handleDelete = async (id) => {
  try {
    await api.delete(`/api/location/${id}`);
    console.log('✅ Address deleted');
    fetchAddresses();
  } catch (error) {
    console.error('❌ Failed to delete address:', error);
  }
};

// Update address
const handleSaveEdit = async () => {
  try {
    await api.put(`/api/location/${editId}`, {
      type: 'MANUAL',
      title: editTitle,
      address: editAddress,
      phoneNumber: editPhone
    });
    
    console.log('✅ Address updated');
    setShowEdit(false);
    fetchAddresses();
  } catch (error) {
    console.error('❌ Failed to update address:', error);
  }
};

// Load addresses on component mount
useEffect(() => {
  fetchAddresses();
}, []);
```

---

## 🔌 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/location` | Save new location |
| GET | `/api/location` | Get all addresses |
| GET | `/api/location/default` | Get default address |
| PUT | `/api/location/{id}` | Update address |
| PUT | `/api/location/{id}/default` | Set as default |
| DELETE | `/api/location/{id}` | Delete address |

---

## 📋 Request Examples

### Save Current Location
```json
{
  "type": "CURRENT",
  "title": "Home",
  "latitude": 19.0760,
  "longitude": 72.8777,
  "phoneNumber": "+91-9876543210"
}
```

### Save Manual Address
```json
{
  "type": "MANUAL",
  "title": "Work",
  "address": "Bandra Kurla Complex, Mumbai",
  "phoneNumber": "+91-9876543210"
}
```

---

## ✅ What You Get

- ✅ GPS-based location detection
- ✅ Manual address entry with geocoding
- ✅ Multiple address management
- ✅ Default address selection
- ✅ Edit and delete addresses
- ✅ User-isolated data (secure)
- ✅ Production-ready code

---

## 📚 Full Documentation

- **Complete Guide**: `LOCATION_SYSTEM_COMPLETE.md`
- **Google Maps Setup**: `GOOGLE_MAPS_SETUP_GUIDE.md`
- **Test Script**: `test-location-api.ps1`

---

## 🐛 Troubleshooting

### Backend not starting?
```powershell
# Check if port 8080 is available
netstat -ano | findstr :8080

# Check application logs
mvn spring-boot:run
```

### Database migration failed?
```sql
-- Check migration status
SELECT * FROM flyway_schema_history;

-- If needed, manually run migration
-- (Located in: src/main/resources/db/migration/V14__create_user_addresses_table.sql)
```

### API returns 401 Unauthorized?
- Ensure you're sending valid JWT token
- Check token expiration
- Verify Authorization header format: `Bearer <token>`

---

## 🎉 You're Ready!

Your location system is now production-ready and works exactly like Swiggy/Zomato! 🚀
