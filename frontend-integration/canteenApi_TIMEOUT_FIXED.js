import api from "./axiosInstance";

/* 🏪 FETCH ALL CANTEENS (Public) */
export const fetchCanteens = async () => {
  try {
    const res = await api.get("/api/canteens", {
      timeout: 30000, // ✅ ADDED: 30-second timeout for this specific call
    });
    return res.data;
  } catch (error) {
    console.error("Error fetching canteens:", error);
    throw error;
  }
};

/* 📋 FETCH MENU BY CANTEEN (Public / Protected later) */
export const fetchMenu = async (canteenId) => {
  try {
    const res = await api.get(`/api/menu/${canteenId}`, {
      timeout: 30000, // ✅ ADDED: 30-second timeout
    });
    return res.data;
  } catch (error) {
    console.error(`Error fetching menu for canteen ${canteenId}:`, error);
    throw error;
  }
};
