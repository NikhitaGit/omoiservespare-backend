import axios from "axios";

/**
 * ================================
 * DEVICE ID MANAGEMENT  
 * ================================
 */
function getDeviceId() {
  let deviceId = localStorage.getItem("deviceId");
  if (!deviceId) {
    deviceId = crypto.randomUUID();
    localStorage.setItem("deviceId", deviceId);
  }
  return deviceId;
}

console.log("API URL:", import.meta.env.VITE_API_BASE_URL);

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || "http://localhost:8080",
  timeout: 180000, // 3 minutes
  withCredentials: true
});

/**
 * ================================
 * REQUEST INTERCEPTOR
 * ================================
 */
api.interceptors.request.use((config) => {
  // Add device ID
  config.headers["X-Device-Id"] = getDeviceId();
  
  // Add token if available
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  return config;
});

/**
 * ================================
 * RESPONSE INTERCEPTOR
 * ✅ SIMPLIFIED - NO AUTOMATIC REDIRECT
 * ================================
 */
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Just return the error, let components handle it
    // NO automatic redirect to login
    console.error("API Error:", error.response?.status, error.response?.data);
    return Promise.reject(error);
  }
);

export default api;
