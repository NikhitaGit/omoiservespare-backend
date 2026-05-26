package com.omoikaneinnovations.omoiservespare.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

import jakarta.annotation.PostConstruct;

/**
 * 🗺️ Google Maps API Configuration
 * Production-ready configuration with validation and monitoring
 */
@Configuration
public class GoogleMapsConfig {

    @Value("${google.maps.api.key:}")
    private String apiKey;

    @Value("${google.maps.api.enabled:true}")
    private boolean enabled;

    @Value("${google.maps.api.timeout:5000}")
    private int timeout;

    @PostConstruct
    public void init() {
        if (enabled) {
            if (apiKey == null || apiKey.isEmpty()) {
                System.err.println("⚠️  WARNING: Google Maps API key is not configured!");
                System.err.println("   Location system will use fallback coordinates.");
                System.err.println("   Set GOOGLE_MAPS_API_KEY environment variable for production.");
            } else {
                System.out.println("✅ Google Maps API configured");
                System.out.println("   API Key: " + maskApiKey(apiKey));
                System.out.println("   Timeout: " + timeout + "ms");
            }
        } else {
            System.out.println("ℹ️  Google Maps API is disabled");
        }
    }

    @Bean
    public RestTemplate googleMapsRestTemplate() {
        return new RestTemplate();
    }

    /**
     * Mask API key for logging (show only first 10 and last 4 characters)
     */
    private String maskApiKey(String key) {
        if (key == null || key.length() < 15) {
            return "***";
        }
        String start = key.substring(0, 10);
        String end = key.substring(key.length() - 4);
        return start + "..." + end;
    }

    // Getters
    public String getApiKey() {
        return apiKey;
    }

    public boolean isEnabled() {
        return enabled && apiKey != null && !apiKey.isEmpty();
    }

    public int getTimeout() {
        return timeout;
    }
}
