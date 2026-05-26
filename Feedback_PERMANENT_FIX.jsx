import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../styles/feedback.css";

const Feedback = () => {
  const navigate = useNavigate();
  const [rating, setRating] = useState(0);
  const [comments, setComments] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async () => {
    // Validation
    if (rating === 0) {
      setError("Please select a rating");
      return;
    }
    if (!comments.trim()) {
      setError("Please enter your feedback");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // Get auth token - try both possible keys
      const token = localStorage.getItem("token") || localStorage.getItem("authToken");
      
      if (!token) {
        setError("Please login first");
        setTimeout(() => navigate("/login"), 2000);
        return;
      }

      console.log("Submitting feedback:", { rating, comments: comments.substring(0, 50) + "..." });

      // Send feedback to backend API
      const response = await fetch("http://localhost:8080/api/feedback", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          rating: rating,
          comments: comments.trim()
        })
      });

      console.log("Response status:", response.status);

      if (response.ok) {
        const data = await response.json();
        console.log("Feedback submitted successfully:", data);
        
        alert("Thank you for your feedback! 🎉");
        
        // Reset form
        setRating(0);
        setComments("");
        
        // Navigate back
        setTimeout(() => navigate(-1), 1000);
      } else {
        const errorText = await response.text();
        console.error("Feedback submission failed:", response.status, errorText);
        
        if (response.status === 401) {
          setError("Session expired. Please login again.");
          setTimeout(() => navigate("/login"), 2000);
        } else if (response.status === 403) {
          setError("Access denied. Please check your account permissions.");
        } else {
          setError(`Failed to submit feedback: ${errorText || "Unknown error"}`);
        }
      }
    } catch (error) {
      console.error("Error submitting feedback:", error);
      setError("Network error. Please check your connection and try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="feedback-container">
      {/* Header */}
      <header className="feedback-header">
        <h3>Send Feedback</h3>
      </header>

      <p className="subtitle">
        Tell us what you love about the app, or what we could be doing better.
      </p>

      {/* Error Message */}
      {error && (
        <div style={{
          padding: "12px",
          backgroundColor: "#fee",
          color: "#c00",
          borderRadius: "8px",
          marginBottom: "16px",
          border: "1px solid #fcc"
        }}>
          {error}
        </div>
      )}

      {/* Rating Stars */}
      <div className="rating-section">
        <label>Rating:</label>
        <div className="stars">
          {[1, 2, 3, 4, 5].map((star) => (
            <span
              key={star}
              className={`star ${rating >= star ? "filled" : ""}`}
              onClick={() => setRating(star)}
              style={{ cursor: "pointer", fontSize: "2rem" }}
            >
              {rating >= star ? "⭐" : "☆"}
            </span>
          ))}
        </div>
        {rating > 0 && (
          <p style={{ marginTop: "8px", color: "#666" }}>
            You rated: {rating} star{rating > 1 ? "s" : ""}
          </p>
        )}
      </div>

      {/* Comments */}
      <textarea
        placeholder="Enter your feedback (max 2000 characters)"
        value={comments}
        onChange={(e) => {
          setComments(e.target.value);
          setError(null); // Clear error when user types
        }}
        maxLength={2000}
        style={{
          width: "100%",
          minHeight: "150px",
          padding: "12px",
          borderRadius: "8px",
          border: "1px solid #ddd",
          fontSize: "14px",
          fontFamily: "inherit",
          resize: "vertical"
        }}
      />
      <div style={{ textAlign: "right", fontSize: "12px", color: "#666", marginTop: "4px" }}>
        {comments.length} / 2000 characters
      </div>

      <div className="help-card">
        ⭐ Need help with your order?
        <p>Get instant help from our customer support.</p>
      </div>

      <button
        className={`submit-btn ${rating && comments.trim() ? "active" : ""}`}
        onClick={handleSubmit}
        disabled={!rating || !comments.trim() || loading}
        style={{
          width: "100%",
          padding: "14px",
          backgroundColor: (!rating || !comments.trim() || loading) ? "#ccc" : "#4CAF50",
          color: "white",
          border: "none",
          borderRadius: "8px",
          fontSize: "16px",
          fontWeight: "bold",
          cursor: (!rating || !comments.trim() || loading) ? "not-allowed" : "pointer",
          transition: "background-color 0.3s"
        }}
      >
        {loading ? "Submitting..." : "Submit feedback"}
      </button>
    </div>
  );
};

export default Feedback;
