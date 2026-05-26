import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../styles/feedback.css";

const Feedback = () => {
  const navigate = useNavigate();
  const [rating, setRating] = useState(0);
  const [comments, setComments] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    console.log("=== FEEDBACK SUBMISSION DEBUG ===");
    console.log("Rating:", rating);
    console.log("Comments:", comments);
    console.log("Comments length:", comments.length);
    
    // Validation
    if (rating === 0) {
      alert("Please select a rating (1-5 stars)");
      return;
    }
    
    if (!comments.trim()) {
      alert("Please enter your feedback");
      return;
    }

    if (comments.length > 2000) {
      alert("Comments must be less than 2000 characters");
      return;
    }

    setLoading(true);

    try {
      // Get auth token
      const token = localStorage.getItem("authToken");
      console.log("Token exists:", !!token);
      
      if (!token) {
        alert("Please login first");
        navigate("/login");
        return;
      }

      // Prepare payload - MUST match backend DTO exactly
      const payload = {
        rating: rating,           // Integer 1-5
        comments: comments.trim() // String, max 2000 chars
      };
      
      console.log("Sending payload:", JSON.stringify(payload, null, 2));

      // Send to backend
      const response = await fetch("http://localhost:8080/api/feedback", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });

      console.log("Response status:", response.status);
      console.log("Response ok:", response.ok);

      if (response.ok) {
        const data = await response.json();
        console.log("Success! Response:", data);
        console.log("Feedback ID:", data.id);
        
        alert("Thank you for your feedback!");
        setRating(0);
        setComments("");
        navigate(-1);
      } else {
        // Error handling
        const errorText = await response.text();
        console.error("Error response:", errorText);
        
        let errorMessage = "Failed to submit feedback";
        try {
          const errorJson = JSON.parse(errorText);
          errorMessage = errorJson.message || errorJson.error || errorText;
        } catch (e) {
          errorMessage = errorText;
        }
        
        alert(`Error: ${errorMessage}`);
      }
    } catch (error) {
      console.error("Network error:", error);
      alert(`Network error: ${error.message}\n\nMake sure backend is running on port 8080`);
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

      {/* Rating Stars */}
      <div className="rating-section" style={{ margin: "20px 0" }}>
        <label style={{ display: "block", marginBottom: "10px", fontWeight: "bold" }}>
          Rating: {rating > 0 ? `${rating}/5` : "Select rating"}
        </label>
        <div className="stars" style={{ display: "flex", gap: "10px" }}>
          {[1, 2, 3, 4, 5].map((star) => (
            <span
              key={star}
              onClick={() => setRating(star)}
              style={{
                cursor: "pointer",
                fontSize: "2.5rem",
                color: rating >= star ? "gold" : "#ddd",
                transition: "color 0.2s"
              }}
            >
              {rating >= star ? "⭐" : "☆"}
            </span>
          ))}
        </div>
      </div>

      {/* Comments */}
      <textarea
        placeholder="Enter your feedback (max 2000 characters)"
        value={comments}
        onChange={(e) => setComments(e.target.value)}
        maxLength={2000}
        style={{
          width: "100%",
          minHeight: "150px",
          padding: "10px",
          fontSize: "16px",
          border: "1px solid #ddd",
          borderRadius: "5px",
          marginBottom: "10px"
        }}
      />
      <div style={{ textAlign: "right", fontSize: "12px", color: "#666" }}>
        {comments.length}/2000 characters
      </div>

      <div className="help-card" style={{
        background: "#f0f8ff",
        padding: "15px",
        borderRadius: "5px",
        margin: "20px 0"
      }}>
        ⭐ Need help with your order?
        <p style={{ margin: "5px 0 0 0" }}>Get instant help from our customer support.</p>
      </div>

      <button
        className={`submit-btn ${rating && comments.trim() ? "active" : ""}`}
        onClick={handleSubmit}
        disabled={!rating || !comments.trim() || loading}
        style={{
          width: "100%",
          padding: "15px",
          fontSize: "16px",
          fontWeight: "bold",
          border: "none",
          borderRadius: "5px",
          cursor: rating && comments.trim() && !loading ? "pointer" : "not-allowed",
          background: rating && comments.trim() && !loading ? "#007bff" : "#ccc",
          color: "white"
        }}
      >
        {loading ? "Submitting..." : "Submit feedback"}
      </button>

      {/* Debug Info (remove in production) */}
      <div style={{
        marginTop: "20px",
        padding: "10px",
        background: "#f5f5f5",
        borderRadius: "5px",
        fontSize: "12px",
        fontFamily: "monospace"
      }}>
        <strong>Debug Info:</strong><br />
        Rating: {rating}<br />
        Comments length: {comments.length}<br />
        Token exists: {localStorage.getItem("authToken") ? "Yes" : "No"}<br />
        Backend URL: http://localhost:8080/api/feedback
      </div>
    </div>
  );
};

export default Feedback;
