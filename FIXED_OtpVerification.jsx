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

      // ✅ CRITICAL FIX: Save as "token" not "authToken"
      // This must match what RaiseTicket and other components look for
      localStorage.setItem("token", result.accessToken);
      
      // Optional: Save user info if returned
      if (result.user) {
        localStorage.setItem("user", JSON.stringify(result.user));
      }

      console.log("Token saved successfully as 'token'");

      // Clean up temporary login info
      localStorage.removeItem("loginEmail");
      localStorage.removeItem("loginPhone");

      alert("Login successful 🎉");
      navigate("/home");
      
    } catch (err) {
      console.error("OTP verification error:", err);
      alert(err.message || "OTP verification failed");
      
      // Optional cleanup on error
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
