import { useState } from "react";
import "./SignupPage.css";
import { useNavigate } from "react-router-dom";
import logo from "../assets/TransperantLogo.png";

const SignupPage = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    companyName: "", // ✅ FIXED: Changed from companyname to companyName
    email: "",
    password: "",
    confirmPassword: "",
  });
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const { companyName, email, password, confirmPassword } = formData;

    if (!companyName || !email || !password || !confirmPassword) {
      alert("Please fill in all fields.");
      return;
    }

    if (password !== confirmPassword) {
      alert("Passwords do not match!");
      return;
    }

    setLoading(true);

    try {
      // ✅ Call backend signup API
      const response = await fetch("http://localhost:8080/api/auth/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          companyName,
          email,
          password,
          confirmPassword,
          accountType: "PROFESSIONAL", // Default account type
        }),
      });

      const data = await response.json();

      if (data.success) {
        alert("Account created successfully! 🎉");
        navigate("/login");
      } else {
        alert(data.message || "Signup failed");
      }
    } catch (error) {
      console.error("Signup error:", error);
      alert("Network error. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container">
      {/* Back Arrow */}
      <button className="back-arrow" onClick={() => navigate(-1)}>
        <i className="fa-solid fa-arrow-left">←</i>
      </button>

      {/* Logo */}
      <div className="logo">
        <img src={logo} alt="Company Logo" />
      </div>

      {/* Form */}
      <div className="form-box">
        <div className="header">
          <h2>Create an Account!</h2>
        </div>

        <form onSubmit={handleSubmit}>
          {/* Company Name - FIXED field name */}
          <div className="input-box">
            <input
              type="text"
              name="companyName" // ✅ FIXED: Changed from companyname
              placeholder="Company Name"
              value={formData.companyName} // ✅ FIXED: Changed from companyname
              onChange={handleChange}
              required
            />
          </div>

          {/* Email */}
          <div className="input-box">
            <input
              type="email"
              name="email"
              placeholder="Email Address"
              value={formData.email}
              onChange={handleChange}
              required
            />
          </div>

          {/* Password */}
          <div className="input-box">
            <input
              type="password"
              name="password"
              placeholder="Password"
              value={formData.password}
              onChange={handleChange}
              required
            />
          </div>

          {/* Confirm Password */}
          <div className="input-box">
            <input
              type="password"
              name="confirmPassword"
              placeholder="Confirm Password"
              value={formData.confirmPassword}
              onChange={handleChange}
              required
            />
          </div>

          {/* Submit */}
          <button type="submit" className="btn" disabled={loading}>
            {loading ? "Creating Account..." : "SUBMIT"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default SignupPage;