import axios from "axios";

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
  timeout: 60000, // 60 seconds - INCREASED FROM 30s
  withCredentials: true
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  config.headers["X-Device-Id"] = getDeviceId();
  return config;
});

let isRefreshing = false;
let refreshPromise = null;

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (!error.response) {
      return Promise.reject(error);
    }

    const { status } = error.response;
    const originalRequest = error.config;
    const isUnauthorized = status === 401;
    const isRefreshCall = originalRequest?.url?.includes("/api/auth/refresh");
    const isApiCall = originalRequest?.url?.startsWith("/api");

    if (isUnauthorized && isRefreshCall) {
      localStorage.removeItem("token");
      localStorage.removeItem("deviceId");
      localStorage.removeItem("userEmail");
      localStorage.removeItem("companyName");
      localStorage.removeItem("phoneNumber");
      localStorage.removeItem("accountType");
      window.location.href = "/login";
      return Promise.reject(error);
    }

    if (isUnauthorized && isApiCall && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        if (!isRefreshing) {
          isRefreshing = true;
          refreshPromise = api
            .post("/api/auth/refresh")
            .then((res) => {
              const newToken = res.data.accessToken;
              localStorage.setItem("token", newToken);
              return newToken;
            })
            .finally(() => {
              isRefreshing = false;
              refreshPromise = null;
            });
        }

        const newAccessToken = await refreshPromise;
        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
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
