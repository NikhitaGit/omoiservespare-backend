import api from "./axiosInstance";

/**
 * Get all active coupons
 */
export const getAllCoupons = async () => {
  try {
    const response = await api.get("/api/coupons", {
      timeout: 30000, // ✅ ADDED: 30-second timeout
    });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch coupons:", error);
    throw error;
  }
};

/**
 * Get available coupons for current cart
 */
export const getAvailableCoupons = async (orderValue, restaurantId = null) => {
  try {
    const params = { orderValue };
    if (restaurantId) {
      params.restaurantId = restaurantId;
    }

    const response = await api.get("/api/coupons/available", {
      params,
      timeout: 30000, // ✅ ADDED: 30-second timeout
    });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch available coupons:", error);
    throw error;
  }
};

/**
 * Validate coupon
 */
export const validateCoupon = async (
  couponCode,
  orderValue,
  restaurantId = null
) => {
  try {
    const response = await api.post(
      "/api/coupons/validate",
      {
        couponCode,
        orderValue,
        restaurantId,
      },
      {
        timeout: 30000, // ✅ ADDED: 30-second timeout
      }
    );
    return response.data;
  } catch (error) {
    console.error("Failed to validate coupon:", error);
    throw error;
  }
};
