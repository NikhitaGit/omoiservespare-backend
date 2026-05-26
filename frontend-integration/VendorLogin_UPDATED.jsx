import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../styles/VendorLogin.css";
import logo from "../assets/TransperantLogo.png";

const VendorLogin = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (!email || !password) {
      setError("Please fill in all fields.");
      return;
    }

    setLoading(true);

    try {
      const response = await fetch("http://localhost:8080/api/v2/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          password,
        }),
      });

      const data = await response.json();

      if (!response.ok || !data.success) {
        throw new Error(data.message || "Login failed");
      }

      // Store token and user info
      localStorage.setItem("accessToken", data.accessToken);
      localStorage.setItem("userRole", data.user.role);
      localStorage.setItem("userEmail", data.user.email);
      localStorage.setItem("userId", data.user.id);

      // Check role and redirect accordingly
      if (data.user.role === "VENDOR") {
        // Check vendor status
        if (data.user.vendorStatus === "PENDING") {
          alert("Your vendor application is pending approval. Please wait for admin approval.");
          return;
        }
        if (data.user.vendorStatus === "REJECTED") {
          alert("Your vendor application was rejected. Please contact support.");
          return;
        }
        if (data.user.vendorStatus === "SUSPENDED") {
          alert("Your vendor account is suspended. Please contact support.");
          return;
        }
        
        // Vendor approved - redirect to monitor dashboard
        alert("Login successful! 🚀");
        navigate("/monitor");
      } else if (data.user.role === "ADMIN") {
        alert("Login successful! Welcome Admin 👑");
        navigate("/admin/dashboard");
      } else if (data.user.role === "USER") {
        alert("Login successful! Welcome 🎉");
        navigate("/user/dashboard");
      } else {
        throw new Error("Unknown user role");
      }
    } catch (err) {
      setError(err.message || "Login failed. Please try again.");
      console.error("Login error:", err);
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
        <h1 className="welcome">Welcome!</h1>

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
          <label htmlFor="email">Email</label>
          <input
            type="email"
            id="email"
            placeholder="Enter your email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            disabled={loading}
          />

          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            placeholder="Enter your password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            disabled={loading}
          />

          <button 
            type="submit" 
            className="login-btn"
            disabled={loading}
          >
            {loading ? "Logging in..." : "Log In"}
          </button>
        </form>
      </div>

      <div className="extra-links">
        <p>
          Don't have an account?{" "}
          <button
            className="signup"
            onClick={() => navigate("/vendor/signup")}
            disabled={loading}
          >
            Sign up
          </button>
        </p>
      </div>
    </div>
  );
};

export default VendorLogin;
