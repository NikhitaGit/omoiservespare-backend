import api from './axiosInstance';

/**
 * Validate a coupon code
 */
export const validateCoupon = async (couponCode, orderValue, restaurantId = null) => {
  try {
    const response = await api.post(
      '/api/coupons/validate',
      {
        couponCode,
        orderValue,
        restaurantId,
      },
      {
        timeout: 30000, // 30 seconds timeout (increased from 10s)
      }
    );
    return response.data;
  } catch (error) {
    console.error('Error validating coupon:', error);
    throw error;
  }
};

/**
 * Get all available coupons
 */
export const getAvailableCoupons = async (orderValue, restaurantId = null) => {
  try {
    const params = { orderValue };
    if (restaurantId) {
      params.restaurantId = restaurantId;
    }

    const response = await api.get('/api/coupons/available', {
      params,
      timeout: 30000,
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching available coupons:', error);
    throw error;
  }
};

/**
 * Get all coupons (for coupons page)
 */
export const getAllCoupons = async () => {
  try {
    const response = await api.get('/api/coupons', {
      timeout: 30000,
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching all coupons:', error);
    throw error;
  }
};
