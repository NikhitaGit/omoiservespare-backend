import api from "./axiosInstance";

export const fetchCanteens = async () => {
  try {
    const res = await api.get("/api/canteens", {
      timeout: 60000, // 60 seconds
    });
    return res.data;
  } catch (error) {
    console.error("Error fetching canteens:", error);
    throw error;
  }
};

export const fetchMenu = async (canteenId) => {
  try {
    const res = await api.get(`/api/menu/${canteenId}`, {
      timeout: 60000, // 60 seconds
    });
    return res.data;
  } catch (error) {
    console.error(`Error fetching menu for canteen ${canteenId}:`, error);
    throw error;
  }
};
