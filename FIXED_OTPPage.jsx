import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { verifyOTP } from "../api/authApi"; // Adjust import based on your API file
import "./OTPPage.css"; // Adjust CSS file name if different

const OTPPage = () => {
  const navigate = useNavigate();
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Get login info from localStorage
      const email = localStorage.getItem("loginEmail");
      const phone = localStorage.getItem("loginPhone");
      const companyName = localStorage.getItem("companyName");

      const otpData = {
        email: email || "",
        phoneNumber: phone || "",
        companyName: companyName || "",
        otp: otp,
      };

      console.log("Verifying OTP with data:", otpData);

      const result = await verifyOTP(otpData);
      
      console.log("OTP verification result:", result);

      if (result.success && result.token) {
        // ✅ CRITICAL: Save JWT token to localStorage
        localStorage.setItem("token", result.token);
        
        // Optional: Save user info if returned
        if (result.user) {
          localStorage.setItem("user", JSON.stringify(result.user));
        }

        console.log("Token saved successfully!");
        
        // Clean up temporary login info
        localStorage.removeItem("loginEmail");
        localStorage.removeItem("loginPhone");
        localStorage.removeItem("companyName");

        alert("Login successful!");
        
        // Navigate to dashboard or home
        navigate("/dashboard");
      } else {
        alert(result.message || "OTP verification failed");
      }
    } catch (err) {
      console.error("OTP verification error:", err);
      alert(err.message || "OTP verification failed");
    } finally {
      setLoading(false);
    }
  };

  const handleResendOTP = async () => {
    try {
      const email = localStorage.getItem("loginEmail");
      const phone = localStorage.getItem("loginPhone");
      const companyName = localStorage.getItem("companyName");

      // Call your resend OTP API
      // const result = await resendOTP({ email, phoneNumber: phone, companyName });
      
      alert("OTP resent successfully!");
    } catch (err) {
      console.error("Resend OTP error:", err);
      alert("Failed to resend OTP");
    }
  };

  return (
    <div className="otp-container">
      <div className="otp-content">
        <h1>Enter OTP</h1>
        <p>We've sent a verification code to your email/phone</p>
        
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            value={otp}
            onChange={(e) => setOtp(e.target.value)}
            placeholder="Enter 6-digit OTP"
            maxLength="6"
            required
            className="otp-input"
          />

          <button type="submit" className="verify-btn" disabled={loading}>
            {loading ? "Verifying..." : "Verify OTP"}
          </button>
        </form>

        <div className="resend-section">
          <span>Didn't receive the code? </span>
          <button className="resend-btn" onClick={handleResendOTP}>
            Resend OTP
          </button>
        </div>

        <button className="back-btn" onClick={() => navigate("/login")}>
          Back to Login
        </button>
      </div>
    </div>
  );
};

export default OTPPage;
