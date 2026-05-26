import api from "./axiosInstance";

// User/Admin login - requests OTP
export const loginUser = (payload) => {
  console.log("loginUser called with:", payload);
  
  // Map to the new unified auth endpoint
  return api.post("/api/auth/user/login", {
    companyName: payload.companyName,
    email: payload.email,
    phoneNumber: payload.phoneNumber
  }).then(res => {
    console.log("Login response:", res.data);
    return res.data;
  });
};

// Verify OTP
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
  
  console.log("Sending OTP verification:", { email, otp: otpCode });
  
  // Device ID is now automatically added by axiosInstance interceptor
  return api.post("/api/auth/verify-otp", { 
    email, 
    otp: otpCode 
  }).then(res => {
    console.log("Raw API response:", res.data);
    return res.data;
  });
};
