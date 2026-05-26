/**
 * 📍 Location API Service
 * Handles all location-related API calls
 */

import api from './axiosInstance';

/**
 * Save new location (current or manual)
 * @param {Object} locationData - Location data
 * @param {string} locationData.type - "CURRENT" or "MANUAL"
 * @param {string} locationData.title - Address title (Home, Work, Other)
 * @param {number} [locationData.latitude] - Required for CURRENT type
 * @param {number} [locationData.longitude] - Required for CURRENT type
 * @param {string} [locationData.address] - Required for MANUAL type
 * @param {string} [locationData.phoneNumber] - Optional phone number
 */
export const saveLocation = async (locationData) => {
  try {
    const response = await api.post('/api/location', locationData);
    return response.data;
  } catch (error) {
    console.error('Failed to save location:', error);
    throw error;
  }
};

/**
 * Get all saved addresses for current user
 */
export const getAllAddresses = async () => {
  try {
    const response = await api.get('/api/location');
    return response.data.data;
  } catch (error) {
    console.error('Failed to fetch addresses:', error);
    throw error;
  }
};

/**
 * Get default address for current user
 */
export const getDefaultAddress = async () => {
  try {
    const response = await api.get('/api/location/default');
    return response.data.data;
  } catch (error) {
    console.error('Failed to fetch default address:', error);
    throw error;
  }
};

/**
 * Set address as default
 * @param {number} addressId - Address ID
 */
export const setDefaultAddress = async (addressId) => {
  try {
    const response = await api.put(`/api/location/${addressId}/default`);
    return response.data;
  } catch (error) {
    console.error('Failed to set default address:', error);
    throw error;
  }
};

/**
 * Update existing address
 * @param {number} addressId - Address ID
 * @param {Object} locationData - Updated location data
 */
export const updateAddress = async (addressId, locationData) => {
  try {
    const response = await api.put(`/api/location/${addressId}`, locationData);
    return response.data;
  } catch (error) {
    console.error('Failed to update address:', error);
    throw error;
  }
};

/**
 * Delete address
 * @param {number} addressId - Address ID
 */
export const deleteAddress = async (addressId) => {
  try {
    const response = await api.delete(`/api/location/${addressId}`);
    return response.data;
  } catch (error) {
    console.error('Failed to delete address:', error);
    throw error;
  }
};

/**
 * Get current GPS location from browser
 * @returns {Promise<{latitude: number, longitude: number}>}
 */
export const getCurrentGPSLocation = () => {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation is not supported by this browser'));
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude
        });
      },
      (error) => {
        reject(error);
      },
      {
        enableHighAccuracy: true,
        timeout: 12000,
        maximumAge: 0
      }
    );
  });
};
