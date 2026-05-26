import api from './axiosInstance';

/**
 * Fetch all canteens
 */
export const fetchCanteens = async () => {
  try {
    const response = await api.get('/api/canteens', {
      timeout: 30000, // 30 seconds timeout (increased from default)
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching canteens:', error);
    throw error;
  }
};

/**
 * Fetch canteen by ID
 */
export const fetchCanteenById = async (canteenId) => {
  try {
    const response = await api.get(`/api/canteens/${canteenId}`, {
      timeout: 30000,
    });
    return response.data;
  } catch (error) {
    console.error(`Error fetching canteen ${canteenId}:`, error);
    throw error;
  }
};

/**
 * Fetch menu items for a canteen
 */
export const fetchCanteenMenu = async (canteenId) => {
  try {
    const response = await api.get(`/api/canteens/${canteenId}/menu`, {
      timeout: 30000,
    });
    return response.data;
  } catch (error) {
    console.error(`Error fetching menu for canteen ${canteenId}:`, error);
    throw error;
  }
};
