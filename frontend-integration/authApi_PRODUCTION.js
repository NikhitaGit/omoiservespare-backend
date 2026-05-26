import api from "./axiosInstance";

/**
 * 🔐 Production Authentication API
 * 
 * Two login flows:
 * 1. VENDOR: Email + Password → Direct JWT
 * 2. USER/ADMIN: Company + Email → OTP → JWT
 */

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

/**
 * ========================================
 * VENDOR LOGIN (Email + Password)
 * ========================================
 * Used by: Vendors on port 5174
 * Flow: Email + Password → JWT tokens immediately
 */
export const vendorLogin = (email, password) =>
  api.post("/api/auth/vendor/login", 
    { email, password },
    {
      headers: {
        'X-Device-Id': getDeviceId()
      }
    }
  ).then(res => {
    console.log("Vendor login response:", res.data);
    return res.data;
  });

/**
 * ========================================
 * USER/ADMIN LOGIN (Company + Email → OTP)
 * ========================================
 * Used by: Users and Admins on port 5173
 * Flow: Company + Email → OTP sent
 */
export const userAdminLogin = (companyName, email, phoneNumber = null) =>
  api.post("/api/auth/user/login", {
    companyName,
    email,
    phoneNumber
  }).then(res => {
    console.log("User/Admin login response:", res.data);
    return res.data;
  });

/**
 * ========================================
 * VERIFY OTP (Complete User/Admin Login)
 * ========================================
 * Used by: Users and Admins after receiving OTP
 * Flow: Email + OTP → JWT tokens
 */
export const verifyOtp = (emailOrPayload, otp) => {
  // Support both calling styles:
  // 1. verifyOtp(email, otp) - two parameters
  // 2. verifyOtp({email, otp}) - object parameter
  let email, otpCode;
  
  if (typeof emailOrPayload === 'object') {
    // Called with object: verifyOtp({email, otp})
    email = emailOrPayload.email;
    otpCode = emailOrPayload.otp;
  } else {
    // Called with separate params: verifyOtp(email, otp)
    email = emailOrPayload;
    otpCode = otp;
  }
  
  return api.post("/api/auth/verify-otp",
    { email, otp: otpCode },
    {
      headers: {
        'X-Device-Id': getDeviceId()
      }
    }
  ).then(res => {
    console.log("OTP verification response:", res.data);
    return res.data;
  });
};

/**
 * ========================================
 * REFRESH TOKEN
 * ========================================
 * Used by: All roles to refresh expired access tokens
 */
export const refreshToken = () =>
  api.post("/api/auth/refresh", {}, {
    headers: {
      'X-Device-Id': getDeviceId()
    }
  }).then(res => res.data);

/**
 * ========================================
 * LEGACY SUPPORT (for backward compatibility)
 * ========================================
 */

// Legacy loginUser function (maps to userAdminLogin)
export const loginUser = (payload) => {
  if (payload.password) {
    // Vendor login
    return vendorLogin(payload.email, payload.password);
  } else {
    // User/Admin login
    return userAdminLogin(
      payload.companyName,
      payload.email,
      payload.phoneNumber
    );
  }
};
