import api from "./axiosInstance";

/**
 * Admin Dashboard API
 * Connects to Spring Boot backend
 */

/**
 * Get dashboard data
 * @param {string} range - 'today', 'week', '15d', 'month', 'year'
 * @returns {Promise} Dashboard data
 */
export const getDashboard = async (range = "week") => {
  const res = await api.get(`/api/admin/dashboard?range=${range}`);
  return res.data;
};

/**
 * Get dashboard with custom date range
 * @param {string} start - Start date (YYYY-MM-DD)
 * @param {string} end - End date (YYYY-MM-DD)
 * @returns {Promise} Dashboard data
 */
export const getDashboardByDateRange = async (start, end) => {
  const res = await api.get(`/api/admin/dashboard?start=${start}&end=${end}`);
  return res.data;
};

/**
 * Health check
 * @returns {Promise} Health status
 */
export const healthCheck = async () => {
  const res = await api.get("/api/admin/dashboard/health");
  return res.data;
};
