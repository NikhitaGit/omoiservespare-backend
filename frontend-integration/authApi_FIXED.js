import api from "./axiosInstance";

export const loginUser = (payload) =>
  api.post("/api/auth/login", payload).then(res => res.data);

export const verifyOtp = (payload) =>
  api.post("/api/auth/verify-otp", payload, {
    headers: {
      'X-Device-Id': getDeviceId()
    }
  }).then(res => {
    console.log("Raw API response:", res.data);
    return res.data;
  });

// Helper function to get or create device ID
function getDeviceId() {
  let deviceId = localStorage.getItem('deviceId');
  if (!deviceId) {
    deviceId = 'device-' + Math.random().toString(36).substr(2, 9) + '-' + Date.now();
    localStorage.setItem('deviceId', deviceId);
  }
  return deviceId;
}
