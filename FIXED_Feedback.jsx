import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../styles/feedback.css";

const Feedback = () => {
  const navigate = useNavigate();
  const [rating, setRating] = useState(0);
  const [comments, setComments] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    if (rating === 0) {
      alert("Please select a rating");
      return;
    }
    
    if (!comments.trim()) {
      alert("Please enter your feedback");
      return;
    }

    setLoading(true);

    try {
      // Get auth token from localStorage
      const token = localStorage.getItem("authToken");
      
      if (!token) {
        alert("Please login first");
        navigate("/login");
        return;
      }

      // Send feedback to backend API
      const response = await fetch("http://localhost:8080/api/feedback", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
          rating: rating,
          comments: comments
        })
      });

      if (response.ok) {
        alert("Thank you for your feedback!");
        setRating(0);
        setComments("");
        navigate(-1); // go back to profile
      } else {
        const error = await response.text();
        alert(`Failed to submit feedback: ${error}`);
      }
    } catch (error) {
      console.error("Error submitting feedback:", error);
      alert("Failed to submit feedback. Please try again.");
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
      </div>

      {/* Comments */}
      <textarea
        placeholder="Enter your feedback (max 2000 characters)"
        value={comments}
        onChange={(e) => setComments(e.target.value)}
        maxLength={2000}
      />

      <div className="help-card">
        ⭐ Need help with your order?
        <p>Get instant help from our customer support.</p>
      </div>

      <button
        className={`submit-btn ${rating && comments ? "active" : ""}`}
        onClick={handleSubmit}
        disabled={!rating || !comments || loading}
      >
        {loading ? "Submitting..." : "Submit feedback"}
      </button>
    </div>
  );
};

export default Feedback;
