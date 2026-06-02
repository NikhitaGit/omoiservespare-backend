import axios from 'axios';

// Helper function to get or create device ID
function getDeviceId() {
  let deviceId = localStorage.getItem('deviceId');
  if (!deviceId) {
    deviceId = crypto.randomUUID();
    localStorage.setItem('deviceId', deviceId);
    console.log("Created new device ID:", deviceId);
  }
  return deviceId;
}

const api = axios.create({
  baseURL: 'http://localhost:8080',
  timeout: 60000, // 60 seconds timeout for email operations
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true, // Important for cookies
});

// Request interceptor to add token and device ID to all requests
api.interceptors.request.use(
  (config) => {
    // Add device ID to all requests
    const deviceId = getDeviceId();
    config.headers['X-Device-Id'] = deviceId;
    
    // Add token if available
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
      console.log("Adding token to request:", config.url);
    }
    
    console.log("Request headers:", config.headers);
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response) {
      // Handle 401 Unauthorized - auto logout
      if (error.response.status === 401) {
        console.log("401 Unauthorized - clearing session and redirecting to login");
        localStorage.removeItem('token');
        localStorage.removeItem('userEmail');
        localStorage.removeItem('companyName');
        localStorage.removeItem('phoneNumber');
        localStorage.removeItem('accountType');
        localStorage.removeItem('deviceId');
        window.location.href = '/login';
      }
      
      // Return error message from backend
      const message = error.response.data?.message || error.response.data?.error || 'An error occurred';
      return Promise.reject(new Error(message));
    }
    
    return Promise.reject(error);
  }
);

export default api;
