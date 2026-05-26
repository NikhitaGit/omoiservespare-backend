package com.omoikaneinnovations.omoiservespare.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.omoikaneinnovations.omoiservespare.config.GoogleMapsConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 🗺️ Google Maps API Service
 * Production-ready with caching, rate limiting, and monitoring
 */
@Service
public class GoogleMapsService {

    @Autowired
    private GoogleMapsConfig config;

    @Autowired
    private RestTemplate googleMapsRestTemplate;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final String GEOCODE_API = "https://maps.googleapis.com/maps/api/geocode/json";
    
    // Simple in-memory cache (consider Redis for production)
    private final Map<String, CachedResult> geocodeCache = new ConcurrentHashMap<>();
    private final Map<String, CachedResult> reverseGeocodeCache = new ConcurrentHashMap<>();
    
    // Rate limiting counters
    private int dailyRequestCount = 0;
    private LocalDateTime lastResetDate = LocalDateTime.now();
    private static final int DAILY_LIMIT = 2500; // Set your limit

    /**
     * Cached result with expiration
     */
    private static class CachedResult {
        Object data;
        LocalDateTime timestamp;
        
        CachedResult(Object data) {
            this.data = data;
            this.timestamp = LocalDateTime.now();
        }
        
        boolean isExpired() {
            // Cache for 24 hours
            return timestamp.plusHours(24).isBefore(LocalDateTime.now());
        }
    }

    /**
     * 📍 Reverse Geocoding: Convert lat/lng to detailed address components
     * Returns formatted address like Google Maps: Area, City, State, Country
     */
    public Map<String, String> reverseGeocodeDetailed(Double latitude, Double longitude) {
        Map<String, String> addressComponents = new HashMap<>();
        
        if (!config.isEnabled()) {
            addressComponents.put("formatted_address", String.format("Location: %.6f, %.6f", latitude, longitude));
            addressComponents.put("area", "");
            addressComponents.put("city", "");
            addressComponents.put("state", "");
            addressComponents.put("country", "");
            addressComponents.put("postal_code", "");
            return addressComponents;
        }

        // Check cache first
        String cacheKey = "detailed_" + latitude + "," + longitude;
        CachedResult cached = reverseGeocodeCache.get(cacheKey);
        if (cached != null && !cached.isExpired()) {
            System.out.println("✅ Detailed reverse geocode cache hit: " + cacheKey);
            return (Map<String, String>) cached.data;
        }

        // Check rate limit
        if (!checkRateLimit()) {
            System.err.println("⚠️  Rate limit exceeded, using fallback");
            addressComponents.put("formatted_address", String.format("Location: %.6f, %.6f", latitude, longitude));
            return addressComponents;
        }

        try {
            String url = UriComponentsBuilder.fromHttpUrl(GEOCODE_API)
                    .queryParam("latlng", latitude + "," + longitude)
                    .queryParam("key", config.getApiKey())
                    .toUriString();

            String response = googleMapsRestTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(response);

            incrementRequestCount();

            String status = root.path("status").asText();
            
            if ("OK".equals(status)) {
                JsonNode results = root.path("results");
                if (results.isArray() && results.size() > 0) {
                    JsonNode firstResult = results.get(0);
                    
                    // Get formatted address
                    String formattedAddress = firstResult.path("formatted_address").asText();
                    addressComponents.put("formatted_address", formattedAddress);
                    
                    // Parse address components
                    JsonNode components = firstResult.path("address_components");
                    for (JsonNode component : components) {
                        JsonNode types = component.path("types");
                        String longName = component.path("long_name").asText();
                        String shortName = component.path("short_name").asText();
                        
                        for (JsonNode type : types) {
                            String typeStr = type.asText();
                            switch (typeStr) {
                                case "sublocality_level_1":
                                case "sublocality":
                                case "neighborhood":
                                    if (!addressComponents.containsKey("area")) {
                                        addressComponents.put("area", longName);
                                    }
                                    break;
                                case "locality":
                                    addressComponents.put("city", longName);
                                    break;
                                case "administrative_area_level_1":
                                    addressComponents.put("state", longName);
                                    break;
                                case "country":
                                    addressComponents.put("country", longName);
                                    break;
                                case "postal_code":
                                    addressComponents.put("postal_code", longName);
                                    break;
                            }
                        }
                    }
                    
                    // Ensure all fields exist
                    addressComponents.putIfAbsent("area", "");
                    addressComponents.putIfAbsent("city", "");
                    addressComponents.putIfAbsent("state", "");
                    addressComponents.putIfAbsent("country", "");
                    addressComponents.putIfAbsent("postal_code", "");
                    
                    // Cache the result
                    reverseGeocodeCache.put(cacheKey, new CachedResult(new HashMap<>(addressComponents)));
                    
                    System.out.println("✅ Detailed reverse geocoded: " + cacheKey);
                    System.out.println("   Area: " + addressComponents.get("area"));
                    System.out.println("   City: " + addressComponents.get("city"));
                    System.out.println("   State: " + addressComponents.get("state"));
                    
                    return addressComponents;
                }
            } else {
                System.err.println("⚠️  Google Maps API status: " + status);
                if (root.has("error_message")) {
                    System.err.println("   Error: " + root.path("error_message").asText());
                }
            }

            addressComponents.put("formatted_address", String.format("Location: %.6f, %.6f", latitude, longitude));
            return addressComponents;

        } catch (Exception e) {
            System.err.println("❌ Detailed reverse geocoding failed: " + e.getMessage());
            e.printStackTrace();
            addressComponents.put("formatted_address", String.format("Location: %.6f, %.6f", latitude, longitude));
            return addressComponents;
        }
    }

    /**
     * 📍 Reverse Geocoding: Convert lat/lng to address (simple version)
     * Production-ready with caching and rate limiting
     */
    public String reverseGeocode(Double latitude, Double longitude) {
        Map<String, String> detailed = reverseGeocodeDetailed(latitude, longitude);
        return detailed.get("formatted_address");
    }

    /**
     * 🔍 Forward Geocoding: Convert address to lat/lng
     * Production-ready with caching and rate limiting
     */
    public Map<String, Double> geocode(String address) {
        Map<String, Double> coords = new HashMap<>();

        if (!config.isEnabled()) {
            coords.put("latitude", 19.0760); // Mumbai default
            coords.put("longitude", 72.8777);
            return coords;
        }

        // Check cache first
        String cacheKey = address.toLowerCase().trim();
        CachedResult cached = geocodeCache.get(cacheKey);
        if (cached != null && !cached.isExpired()) {
            System.out.println("✅ Geocode cache hit: " + cacheKey);
            return (Map<String, Double>) cached.data;
        }

        // Check rate limit
        if (!checkRateLimit()) {
            System.err.println("⚠️  Rate limit exceeded, using fallback");
            coords.put("latitude", 19.0760);
            coords.put("longitude", 72.8777);
            return coords;
        }

        try {
            String url = UriComponentsBuilder.fromHttpUrl(GEOCODE_API)
                    .queryParam("address", address)
                    .queryParam("key", config.getApiKey())
                    .toUriString();

            String response = googleMapsRestTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(response);

            incrementRequestCount();

            String status = root.path("status").asText();
            
            if ("OK".equals(status)) {
                JsonNode results = root.path("results");
                if (results.isArray() && results.size() > 0) {
                    JsonNode location = results.get(0).path("geometry").path("location");
                    coords.put("latitude", location.path("lat").asDouble());
                    coords.put("longitude", location.path("lng").asDouble());
                    
                    // Cache the result
                    geocodeCache.put(cacheKey, new CachedResult(new HashMap<>(coords)));
                    
                    System.out.println("✅ Geocoded: " + address + " → " + coords);
                    return coords;
                }
            } else {
                System.err.println("⚠️  Google Maps API status: " + status);
                if (root.has("error_message")) {
                    System.err.println("   Error: " + root.path("error_message").asText());
                }
            }

            coords.put("latitude", 19.0760);
            coords.put("longitude", 72.8777);
            return coords;

        } catch (Exception e) {
            System.err.println("❌ Geocoding failed: " + e.getMessage());
            coords.put("latitude", 19.0760);
            coords.put("longitude", 72.8777);
            return coords;
        }
    }

    /**
     * ✅ Check if API is configured
     */
    public boolean isConfigured() {
        return config.isEnabled();
    }

    /**
     * 🔒 Check rate limit
     */
    private boolean checkRateLimit() {
        // Reset counter if it's a new day
        if (lastResetDate.toLocalDate().isBefore(LocalDateTime.now().toLocalDate())) {
            dailyRequestCount = 0;
            lastResetDate = LocalDateTime.now();
        }

        return dailyRequestCount < DAILY_LIMIT;
    }

    /**
     * 📊 Increment request counter
     */
    private void incrementRequestCount() {
        dailyRequestCount++;
        
        if (dailyRequestCount % 100 == 0) {
            System.out.println("📊 Google Maps API usage: " + dailyRequestCount + "/" + DAILY_LIMIT + " requests today");
        }
        
        if (dailyRequestCount >= DAILY_LIMIT * 0.9) {
            System.err.println("⚠️  WARNING: Approaching daily API limit (" + dailyRequestCount + "/" + DAILY_LIMIT + ")");
        }
    }

    /**
     * 📊 Get usage statistics
     */
    public Map<String, Object> getUsageStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("dailyRequestCount", dailyRequestCount);
        stats.put("dailyLimit", DAILY_LIMIT);
        stats.put("cacheSize", geocodeCache.size() + reverseGeocodeCache.size());
        stats.put("lastResetDate", lastResetDate);
        stats.put("configured", config.isEnabled());
        return stats;
    }

    /**
     * 🗑️ Clear cache (for maintenance)
     */
    public void clearCache() {
        geocodeCache.clear();
        reverseGeocodeCache.clear();
        System.out.println("✅ Google Maps cache cleared");
    }
}
