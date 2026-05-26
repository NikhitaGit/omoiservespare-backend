import axios from "axios";

/**
 * Generate or reuse a stable device id
 * (1 device = 1 browser / app install)
 */
function getDeviceId() {
  let deviceId = localStorage.getItem("deviceId");
  if (!deviceId) {
    deviceId = crypto.randomUUID();
    localStorage.setItem("deviceId", deviceId);
  }
  return deviceId;
}

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 30000, // ✅ FIXED: Increased from 10000 to 30000 (30 seconds)
  withCredentials: true // 🔥 REQUIRED for HttpOnly refresh cookie
});

/**
 * ===============================
 * REQUEST INTERCEPTOR
 * ===============================
 */
api.interceptors.request.use((config) => {
  // ✅ FIXED: Use "token" to match OtpVerification.jsx
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  // 🔒 device-bound refresh token
  config.headers["X-Device-Id"] = getDeviceId();

  return config;
});

/**
 * ===============================
 * REFRESH LOCK
 * ===============================
 */
let isRefreshing = false;
let refreshPromise = null;

/**
 * ===============================
 * RESPONSE INTERCEPTOR
 * ===============================
 */
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    // ❌ Network / CORS / timeout errors
    if (!error.response) {
      return Promise.reject(error);
    }

    const { status } = error.response;
    const originalRequest = error.config;
    const isUnauthorized = status === 401;
    const isRefreshCall = originalRequest?.url?.includes("/api/auth/refresh");
    const isApiCall = originalRequest?.url?.startsWith("/api");

    /**
     * 🚨 If refresh itself fails → logout
     */
    if (isUnauthorized && isRefreshCall) {
      // ✅ FIXED: Clear "token" instead of "authToken"
      localStorage.removeItem("token");
      localStorage.removeItem("deviceId");
      localStorage.removeItem("userEmail");
      localStorage.removeItem("companyName");
      localStorage.removeItem("phoneNumber");
      localStorage.removeItem("accountType");
      window.location.href = "/login";
      return Promise.reject(error);
    }

    /**
     * 🔁 Refresh access token
     */
    if (isUnauthorized && isApiCall && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        // 🔒 SINGLE refresh request
        if (!isRefreshing) {
          isRefreshing = true;
          refreshPromise = api
            .post("/api/auth/refresh")
            .then((res) => {
              const newToken = res.data.accessToken;
              // ✅ FIXED: Save as "token" instead of "authToken"
              localStorage.setItem("token", newToken);
              return newToken;
            })
            .finally(() => {
              isRefreshing = false;
              refreshPromise = null;
            });
        }

        const newAccessToken = await refreshPromise;

        // 🔁 retry original request
        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        // ❌ refresh failed → logout
        // ✅ FIXED: Clear "token" instead of "authToken"
        localStorage.removeItem("token");
        localStorage.removeItem("deviceId");
        localStorage.removeItem("userEmail");
        localStorage.removeItem("companyName");
        localStorage.removeItem("phoneNumber");
        localStorage.removeItem("accountType");
        window.location.href = "/login";
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
