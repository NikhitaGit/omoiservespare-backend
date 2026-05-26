import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../styles/VendorLogin.css";
import logo from "../assets/TransperantLogo.png";

const VendorSignup = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: "",
    password: "",
    confirmPassword: "",
    companyName: "",
    phoneNumber: "",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    // Validation
    if (!formData.email || !formData.password || !formData.companyName || !formData.phoneNumber) {
      setError("Please fill in all fields.");
      return;
    }

    if (formData.password.length < 6) {
      setError("Password must be at least 6 characters.");
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    setLoading(true);

    try {
      const response = await fetch("http://localhost:8080/api/v2/auth/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: formData.email,
          password: formData.password,
          companyName: formData.companyName,
          phoneNumber: formData.phoneNumber,
          role: "VENDOR", // Vendor signup
        }),
      });

      const data = await response.json();

      if (!response.ok || !data.success) {
        throw new Error(data.message || "Signup failed");
      }

      // Store token and user info
      localStorage.setItem("accessToken", data.accessToken);
      localStorage.setItem("userRole", data.user.role);
      localStorage.setItem("userEmail", data.user.email);
      localStorage.setItem("userId", data.user.id);

      // Show success message
      alert(data.message || "Vendor registration successful! Awaiting admin approval.");
      
      // Redirect to login or pending page
      navigate("/vendor/pending");
    } catch (err) {
      setError(err.message || "Signup failed. Please try again.");
      console.error("Signup error:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container full-height flex-center flex-column">
      <div className="logo">
        <img src={logo} alt="Company Logo" />
      </div>

      <div className="content">
        <h1 className="welcome">Vendor Signup</h1>

        {error && (
          <div style={{ 
            color: "red", 
            marginBottom: "15px", 
            padding: "10px", 
            backgroundColor: "#ffe6e6",
            borderRadius: "5px"
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <label htmlFor="companyName">Company Name</label>
          <input
            type="text"
            id="companyName"
            name="companyName"
            placeholder="Enter your company name"
            value={formData.companyName}
            onChange={handleChange}
            required
            disabled={loading}
          />

          <label htmlFor="email">Email</label>
          <input
            type="email"
            id="email"
            name="email"
            placeholder="Enter your email"
            value={formData.email}
            onChange={handleChange}
            required
            disabled={loading}
          />

          <label htmlFor="phoneNumber">Phone Number</label>
          <input
            type="tel"
            id="phoneNumber"
            name="phoneNumber"
            placeholder="Enter your phone number"
            value={formData.phoneNumber}
            onChange={handleChange}
            required
            disabled={loading}
          />

          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            name="password"
            placeholder="Enter your password (min 6 characters)"
            value={formData.password}
            onChange={handleChange}
            required
            disabled={loading}
          />

          <label htmlFor="confirmPassword">Confirm Password</label>
          <input
            type="password"
            id="confirmPassword"
            name="confirmPassword"
            placeholder="Confirm your password"
            value={formData.confirmPassword}
            onChange={handleChange}
            required
            disabled={loading}
          />

          <button 
            type="submit" 
            className="login-btn"
            disabled={loading}
          >
            {loading ? "Creating Account..." : "Sign Up"}
          </button>
        </form>
      </div>

      <div className="extra-links">
        <p>
          Already have an account?{" "}
          <button
            className="signup"
            onClick={() => navigate("/vendor/login")}
            disabled={loading}
          >
            Log in
          </button>
        </p>
      </div>
    </div>
  );
};

export default VendorSignup;
