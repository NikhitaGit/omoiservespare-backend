import api from "./axiosInstance";

export const getAllCoupons = async () => {
  try {
    const response = await api.get("/api/coupons", {
      timeout: 60000, // 60 seconds
    });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch coupons:", error);
    throw error;
  }
};

export const getAvailableCoupons = async (orderValue, restaurantId = null) => {
  try {
    const params = { orderValue };
    if (restaurantId) {
      params.restaurantId = restaurantId;
    }

    const response = await api.get("/api/coupons/available", {
      params,
      timeout: 60000, // 60 seconds
    });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch available coupons:", error);
    throw error;
  }
};

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
        timeout: 60000, // 60 seconds
      }
    );
    return response.data;
  } catch (error) {
    console.error("Failed to validate coupon:", error);
    // Return a user-friendly error
    if (error.code === 'ECONNABORTED') {
      throw new Error("Request timed out. Please try again.");
    }
    throw error;
  }
};
