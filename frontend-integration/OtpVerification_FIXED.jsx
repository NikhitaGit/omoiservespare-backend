import React, { useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { verifyOtp } from "../api/authApi";
import "./OtpVerification.css";
import logo from "../assets/TransperantLogo.png";

const OtpVerification = () => {
  const navigate = useNavigate();
  const inputs = useRef([]);
  const [loading, setLoading] = useState(false);

  const handleInput = (e, index) => {
    if (e.target.value.length === 1 && index < inputs.current.length - 1) {
      inputs.current[index + 1].focus();
    }
  };

  const handleKeyDown = (e, index) => {
    if (e.key === "Backspace" && !e.target.value && index > 0) {
      inputs.current[index - 1].focus();
    }
  };

  const handleConfirm = async () => {
    const otp = inputs.current.map((input) => input.value).join("");
    
    if (otp.length !== 4) {
      alert("Please enter all 4 digits of the OTP.");
      return;
    }

    setLoading(true);

    try {
      const email = localStorage.getItem("loginEmail");
      
      const result = await verifyOtp({ email, otp });
      
      console.log("OTP verification result:", result);

      // ✅ FIXED: Check if result has accessToken
      if (result && result.accessToken) {
        // Save token
        localStorage.setItem("token", result.accessToken);
        console.log("Token saved successfully:", result.accessToken);

        // Save user info
        if (result.email) {
          localStorage.setItem("userEmail", result.email);
        }
        if (result.companyName) {
          localStorage.setItem("companyName", result.companyName);
        }
        if (result.phoneNumber) {
          localStorage.setItem("phoneNumber", result.phoneNumber);
        }
        if (result.accountType) {
          localStorage.setItem("accountType", result.accountType);
        }

        // Clean up temporary login info
        localStorage.removeItem("loginEmail");
        localStorage.removeItem("loginPhone");

        alert("Login successful 🎉");
        navigate("/home");
      } else {
        // Handle case where accessToken is missing
        console.error("No accessToken in response:", result);
        alert("Login failed: No access token received");
        navigate("/login");
      }
    } catch (err) {
      console.error("OTP verification error:", err);
      alert(err.message || "OTP verification failed");
      
      // Cleanup on error
      localStorage.removeItem("loginEmail");
      localStorage.removeItem("loginPhone");
      navigate("/login");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="containers">
      {/* Back Arrow */}
      <a href="/login" className="back-arrow">
        <i className="fa-solid fa-arrow-left"></i>
      </a>

      {/* Logo */}
      <div className="logo">
        <img src={logo} alt="Company Logo" />
      </div>

      <h2 className="title">Verification Code</h2>
      <p className="subtitle">
        We have sent a verification code to your email address
      </p>

      {/* OTP Inputs */}
      <div className="otp-boxes">
        {[0, 1, 2, 3].map((_, index) => (
          <input
            key={index}
            type="text"
            maxLength="1"
            className="otp-input"
            ref={(el) => (inputs.current[index] = el)}
            onInput={(e) => handleInput(e, index)}
            onKeyDown={(e) => handleKeyDown(e, index)}
          />
        ))}
      </div>

      <p className="resend" onClick={() => alert("OTP resent!")}>
        Resend OTP?
      </p>

      <button
        className="confirm-btn"
        onClick={handleConfirm}
        disabled={loading}
      >
        {loading ? "VERIFYING..." : "CONFIRM"}
      </button>
    </div>
  );
};

export default OtpVerification;
