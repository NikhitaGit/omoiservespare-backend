import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { loginUser } from "../api/authApi";
import "./LoginPage.css";
import logo from "../assets/TransperantLogo.png";

const LoginPage = () => {
  const navigate = useNavigate();
  const [company, setCompany] = useState("");
  const [emailOrPhone, setEmailOrPhone] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Determine if input is email or phone number
      const isEmail = emailOrPhone.includes("@");
      const loginData = {
        companyName: company,
        email: isEmail ? emailOrPhone : "",
        phoneNumber: isEmail ? "" : emailOrPhone,
      };

      const result = await loginUser(loginData);
      alert(result.message);

      if (result.success) {
        // Store login info for OTP verification
        localStorage.setItem("loginEmail", isEmail ? emailOrPhone : "");
        localStorage.setItem("loginPhone", isEmail ? "" : emailOrPhone);
        localStorage.setItem("companyName", company);
        
        console.log("Login info saved, navigating to OTP page");
        navigate("/otp");
      }
    } catch (err) {
      console.error(err);
      alert(err.message || "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="containers">
      <div className="logo">
        <img src={logo} alt="Company Logo" />
      </div>
      <div className="content">
        <h1 className="welcome">Welcome!</h1>
        <form onSubmit={handleSubmit}>
          <label>Company Name</label>
          <input
            type="text"
            value={company}
            onChange={(e) => setCompany(e.target.value)}
            placeholder="Enter your company name"
            required
          />

          <label>Email/Phone Number</label>
          <input
            type="text"
            value={emailOrPhone}
            onChange={(e) => setEmailOrPhone(e.target.value)}
            placeholder="Enter email or phone number"
            required
          />

          <button type="submit" className="login-btn" disabled={loading}>
            {loading ? "Sending OTP..." : "Log In"}
          </button>
        </form>

        <div className="signup-link">
          <span>Don't have an account? </span>
          <button className="signup-btn" onClick={() => navigate("/signup")}>
            Sign up
          </button>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
