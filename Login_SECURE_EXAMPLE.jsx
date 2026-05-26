import React, { useState } from "react";
import tokenManager from "./SecureTokenManager";

const SecureLogin = () => {
  const [email, setEmail] = useState("");
  const [accountType, setAccountType] = useState("PROFESSIONAL");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState("email"); // "email" or "otp"
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const sendOTP = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await fetch("http://localhost:8080/api/auth/send-otp", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, accountType })
      });

      if (response.ok) {
        setStep("otp");
        alert("OTP sent! Check your email.");
      } else {
        const errorText = await response.text();
        setError(`Failed to send OTP: ${errorText}`);
      }
    } catch (error) {
      setError(`Network error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const verifyOTP = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await fetch("http://localhost:8080/api/auth/verify-otp", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, otp, accountType })
      });

      if (response.ok) {
        const data = await response.json();
        
        // SECURE: Store token using secure token manager
        // Token is encrypted and not visible in plain text
        tokenManager.setToken(data.token);
        
        alert("Login successful!");
        
        // Redirect or update app state
        window.location.href = "/dashboard";
      } else {
        const errorText = await response.text();
        setError(`Invalid OTP: ${errorText}`);
      }
    } catch (error) {
      setError(`Network error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    // SECURE: Clear token from all storage
    tokenManager.clearToken();
    setStep("email");
    setOtp("");
    alert("Logged out successfully");
  };

  // Check if already logged in
  const isLoggedIn = tokenManager.isAuthenticated();
  const tokenMetadata = tokenManager.getTokenMetadata();

  if (isLoggedIn) {
    return (
      <div style={{ padding: "20px", maxWidth: "400px", margin: "0 auto" }}>
        <h2>🔒 Secure Session</h2>
        <div style={{ 
          padding: "15px", 
          backgroundColor: "#e7f3ff",
          borderRadius: "4px",
          marginBottom: "20px"
        }}>
          <p><strong>Email:</strong> {tokenMetadata?.email}</p>
          <p><strong>Account Type:</strong> {tokenMetadata?.accountType}</p>
          {tokenMetadata?.expiresIn && (
            <p><strong>Session expires in:</strong> {Math.floor(tokenMetadata.expiresIn / 60)} minutes</p>
          )}
          <p style={{ fontSize: "12px", color: "#666", marginTop: "10px" }}>
            ✓ Token is encrypted and securely stored
          </p>
        </div>
        <button 
          onClick={logout}
          style={{
            width: "100%",
            padding: "10px",
            backgroundColor: "#dc3545",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer"
          }}
        >
          Logout
        </button>
      </div>
    );
  }

  return (
    <div style={{ padding: "20px", maxWidth: "400px", margin: "0 auto" }}>
      <h2>🔒 Secure Login</h2>
      
      {error && (
        <div style={{ 
          padding: "10px", 
          backgroundColor: "#fee", 
          color: "#c00",
          borderRadius: "4px",
          marginBottom: "15px"
        }}>
          {error}
        </div>
      )}

      {step === "email" ? (
        <form onSubmit={sendOTP}>
          <div style={{ marginBottom: "15px" }}>
            <label style={{ display: "block", marginBottom: "5px" }}>Email:</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              style={{
                width: "100%",
                padding: "10px",
                border: "1px solid #ddd",
                borderRadius: "4px"
              }}
            />
          </div>

          <div style={{ marginBottom: "15px" }}>
            <label style={{ display: "block", marginBottom: "5px" }}>Account Type:</label>
            <select
              value={accountType}
              onChange={(e) => setAccountType(e.target.value)}
              style={{
                width: "100%",
                padding: "10px",
                border: "1px solid #ddd",
                borderRadius: "4px"
              }}
            >
              <option value="PROFESSIONAL">Professional</option>
              <option value="REGULAR">Regular</option>
            </select>
          </div>

          <button
            type="submit"
            disabled={loading}
            style={{
              width: "100%",
              padding: "10px",
              backgroundColor: "#007bff",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: loading ? "not-allowed" : "pointer"
            }}
          >
            {loading ? "Sending..." : "Send OTP"}
          </button>
        </form>
      ) : (
        <form onSubmit={verifyOTP}>
          <div style={{ marginBottom: "15px" }}>
            <label style={{ display: "block", marginBottom: "5px" }}>Enter OTP:</label>
            <input
              type="text"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
              required
              maxLength="6"
              style={{
                width: "100%",
                padding: "10px",
                border: "1px solid #ddd",
                borderRadius: "4px",
                fontSize: "18px",
                letterSpacing: "5px",
                textAlign: "center"
              }}
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            style={{
              width: "100%",
              padding: "10px",
              backgroundColor: "#28a745",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: loading ? "not-allowed" : "pointer",
              marginBottom: "10px"
            }}
          >
            {loading ? "Verifying..." : "Verify OTP"}
          </button>

          <button
            type="button"
            onClick={() => setStep("email")}
            style={{
              width: "100%",
              padding: "10px",
              backgroundColor: "#6c757d",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: "pointer"
            }}
          >
            Back
          </button>
        </form>
      )}

      <div style={{ 
        marginTop: "20px", 
        padding: "10px", 
        backgroundColor: "#f8f9fa",
        borderRadius: "4px",
        fontSize: "12px",
        color: "#666"
      }}>
        <strong>🔒 Security Features:</strong>
        <ul style={{ marginTop: "5px", paddingLeft: "20px" }}>
          <li>Token encrypted before storage</li>
          <li>Not visible in localStorage inspector</li>
          <li>Automatic expiry handling</li>
          <li>Secure session management</li>
        </ul>
      </div>
    </div>
  );
};

export default SecureLogin;
