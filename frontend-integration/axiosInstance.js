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

// Helper function to check if token is expired
function isTokenExpired(token) {
  if (!token) return true;
  
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    const exp = payload.exp * 1000; // Convert to milliseconds
    const now = Date.now();
    
    // Token is expired if expiration time is less than current time
    // Add 5 second buffer
    return exp < (now + 5000);
  } catch (error) {
    console.error('Error checking token expiration:', error);
    return true; // If we can't parse, assume expired
  }
}

// Response interceptor to handle errors with intelligent 401 handling
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response) {
      // Handle 401 Unauthorized - but ONLY redirect if token is actually expired
      if (error.response.status === 401) {
        const token = localStorage.getItem('token');
        const isExpired = isTokenExpired(token);
        
        console.log("401 Unauthorized detected");
        console.log("  Token exists:", !!token);
        console.log("  Token expired:", isExpired);
        console.log("  Request URL:", error.config?.url);
        
        // CRITICAL FIX: Only auto-redirect if token is missing or expired
        // This prevents redirecting when user has valid token but endpoint returns 401 for other reasons
        if (!token || isExpired) {
          console.log("❌ Token missing or expired - clearing session and redirecting");
          localStorage.removeItem('token');
          localStorage.removeItem('userEmail');
          localStorage.removeItem('companyName');
          localStorage.removeItem('phoneNumber');
          localStorage.removeItem('accountType');
          localStorage.removeItem('deviceId');
          window.location.href = '/login';
        } else {
          console.log("⚠️ Valid token exists but 401 received - NOT auto-redirecting");
          console.log("   This allows components to handle auth errors gracefully");
          // Let the component handle the error - don't auto-redirect
          // The component can show appropriate error message or prompt user to login
        }
      }
      
      // Return error message from backend
      const message = error.response.data?.message || error.response.data?.error || 'An error occurred';
      return Promise.reject(new Error(message));
    }
    
    return Promise.reject(error);
  }
);

export default api;
