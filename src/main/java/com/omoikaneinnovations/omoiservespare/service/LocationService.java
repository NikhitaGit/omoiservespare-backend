package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.AddressResponse;
import com.omoikaneinnovations.omoiservespare.dto.LocationRequest;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.entity.UserAddress;
import com.omoikaneinnovations.omoiservespare.repository.UserAddressRepository;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 📍 Location Service
 * Production-ready location management like Swiggy/Zomato
 */
@Service
public class LocationService {

    @Autowired
    private UserAddressRepository addressRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GoogleMapsService googleMapsService;

    /**
     * 📍 Save location (handles both current location and manual address)
     * Follows the flowchart: Frontend GPS → POST /api/location → Get logged-in user → location.setUser(user) → Save to PostgreSQL
     */
    @Transactional
    public AddressResponse saveLocation(Long userId, LocationRequest request) {
        // Step 1: Get logged-in user from database (as per flowchart)
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        // Step 2: Create new address entity
        UserAddress address = new UserAddress();
        address.setUser(user); // Set User entity (not just userId) as per flowchart
        address.setTitle(request.getTitle());
        
        // Handle empty phone number - set to null instead of empty string
        String phoneNumber = request.getPhoneNumber();
        if (phoneNumber != null && phoneNumber.trim().isEmpty()) {
            phoneNumber = null;
        }
        address.setPhoneNumber(phoneNumber);

        if (request.getType() == LocationRequest.LocationType.CURRENT) {
            // Current Location Flow: lat/lng provided, get address
            if (request.getLatitude() == null || request.getLongitude() == null) {
                throw new IllegalArgumentException("Latitude and longitude are required for current location");
            }

            address.setLatitude(request.getLatitude());
            address.setLongitude(request.getLongitude());

            // Reverse geocode to get readable address
            String resolvedAddress = googleMapsService.reverseGeocode(
                request.getLatitude(), 
                request.getLongitude()
            );
            address.setAddress(resolvedAddress);

        } else {
            // Manual Address Flow: address provided, get lat/lng
            if (request.getAddress() == null || request.getAddress().trim().isEmpty()) {
                throw new IllegalArgumentException("Address is required for manual location");
            }

            address.setAddress(request.getAddress());

            // Forward geocode to get coordinates
            Map<String, Double> coords = googleMapsService.geocode(request.getAddress());
            address.setLatitude(coords.get("latitude"));
            address.setLongitude(coords.get("longitude"));
        }

        // Set as default if this is the first address
        boolean isFirstAddress = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId).isEmpty();
        address.setIsDefault(isFirstAddress);

        // Step 3: Save to PostgreSQL (as per flowchart)
        UserAddress saved = addressRepository.save(address);
        return mapToResponse(saved);
    }

    /**
     * 📋 Get all addresses for a user
     */
    public List<AddressResponse> getUserAddresses(Long userId) {
        return addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    /**
     * 🏠 Get default address for a user
     */
    public AddressResponse getDefaultAddress(Long userId) {
        return addressRepository.findByUserIdAndIsDefaultTrue(userId)
                .map(this::mapToResponse)
                .orElse(null);
    }

    /**
     * ⭐ Set address as default
     */
    @Transactional
    public AddressResponse setDefaultAddress(Long userId, Long addressId) {
        UserAddress address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Address not found"));

        // Reset all defaults for this user
        addressRepository.resetDefaultForUser(userId);

        // Set this address as default
        address.setIsDefault(true);
        UserAddress updated = addressRepository.save(address);

        return mapToResponse(updated);
    }

    /**
     * ✏️ Update address
     */
    @Transactional
    public AddressResponse updateAddress(Long userId, Long addressId, LocationRequest request) {
        // Get logged-in user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        UserAddress address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Address not found"));

        address.setUser(user); // Ensure user is set
        address.setTitle(request.getTitle());
        
        // Handle empty phone number - set to null instead of empty string
        String phoneNumber = request.getPhoneNumber();
        if (phoneNumber != null && phoneNumber.trim().isEmpty()) {
            phoneNumber = null;
        }
        address.setPhoneNumber(phoneNumber);

        if (request.getType() == LocationRequest.LocationType.CURRENT) {
            if (request.getLatitude() == null || request.getLongitude() == null) {
                throw new IllegalArgumentException("Latitude and longitude are required");
            }

            address.setLatitude(request.getLatitude());
            address.setLongitude(request.getLongitude());

            String resolvedAddress = googleMapsService.reverseGeocode(
                request.getLatitude(), 
                request.getLongitude()
            );
            address.setAddress(resolvedAddress);

        } else {
            if (request.getAddress() == null || request.getAddress().trim().isEmpty()) {
                throw new IllegalArgumentException("Address is required");
            }

            address.setAddress(request.getAddress());

            Map<String, Double> coords = googleMapsService.geocode(request.getAddress());
            address.setLatitude(coords.get("latitude"));
            address.setLongitude(coords.get("longitude"));
        }

        UserAddress updated = addressRepository.save(address);
        return mapToResponse(updated);
    }

    /**
     * 🗑️ Delete address
     */
    @Transactional
    public void deleteAddress(Long userId, Long addressId) {
        UserAddress address = addressRepository.findByIdAndUserId(addressId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Address not found"));

        boolean wasDefault = address.getIsDefault();
        addressRepository.delete(address);

        // If deleted address was default, set another as default
        if (wasDefault) {
            List<UserAddress> remaining = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId);
            if (!remaining.isEmpty()) {
                UserAddress newDefault = remaining.get(0);
                newDefault.setIsDefault(true);
                addressRepository.save(newDefault);
            }
        }
    }

    /**
     * 🔄 Map entity to response DTO
     */
    private AddressResponse mapToResponse(UserAddress address) {
        return new AddressResponse(
            address.getId(),
            address.getTitle(),
            address.getAddress(),
            address.getLatitude(),
            address.getLongitude(),
            address.getPhoneNumber(),
            address.getIsDefault(),
            address.getCreatedAt()
        );
    }
}
