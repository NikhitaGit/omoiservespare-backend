import React, { useState, useEffect } from "react";
import "./App_Feedback.css";

const AppFeedback = () => {
  const [feedbackData, setFeedbackData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("ALL"); // ALL, NEW, REVIEWED

  // Fetch feedback from backend
  useEffect(() => {
    fetchFeedback();
  }, [filter]);

  const fetchFeedback = async () => {
    try {
      const token = localStorage.getItem("authToken");
      
      if (!token) {
        alert("Please login first");
        return;
      }

      let url = "http://localhost:8080/api/feedback";
      if (filter !== "ALL") {
        url += `?status=${filter}`;
      }

      const response = await fetch(url, {
        headers: {
          "Authorization": `Bearer ${token}`
        }
      });

      if (response.ok) {
        const data = await response.json();
        setFeedbackData(data);
      } else {
        console.error("Failed to fetch feedback");
      }
    } catch (error) {
      console.error("Error fetching feedback:", error);
    } finally {
      setLoading(false);
    }
  };

  // Mark as reviewed
  const markAsReviewed = async (id) => {
    try {
      const token = localStorage.getItem("authToken");
      
      const response = await fetch(`http://localhost:8080/api/feedback/${id}/review`, {
        method: "PUT",
        headers: {
          "Authorization": `Bearer ${token}`
        }
      });

      if (response.ok) {
        alert("Feedback marked as reviewed");
        fetchFeedback(); // Refresh list
      }
    } catch (error) {
      console.error("Error marking feedback as reviewed:", error);
    }
  };

  // CSV Download
  const downloadCSV = async () => {
    try {
      const token = localStorage.getItem("authToken");
      
      const response = await fetch("http://localhost:8080/api/feedback/export/csv", {
        headers: {
          "Authorization": `Bearer ${token}`
        }
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "feedback.csv";
        a.click();
      }
    } catch (error) {
      console.error("Error downloading CSV:", error);
    }
  };

  // Excel Download
  const downloadExcel = async () => {
    try {
      const token = localStorage.getItem("authToken");
      
      const response = await fetch("http://localhost:8080/api/feedback/export/excel", {
        headers: {
          "Authorization": `Bearer ${token}`
        }
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "feedback.xlsx";
        a.click();
      }
    } catch (error) {
      console.error("Error downloading Excel:", error);
    }
  };

  // Average Rating
  const avgRating = feedbackData.length > 0
    ? feedbackData.reduce((acc, f) => acc + f.rating, 0) / feedbackData.length
    : 0;

  if (loading) {
    return <div className="feedback-page"><h2>Loading feedback...</h2></div>;
  }

  return (
    <div className="feedback-page">
      <h2>User Feedback & Ratings</h2>

      {/* SUMMARY */}
      <div className="rating-summary">
        <h3>Average Rating</h3>
        <div className="stars">
          {"⭐".repeat(Math.round(avgRating))}
        </div>
        <p>{avgRating.toFixed(1)} / 5</p>
        <p>Total Feedback: {feedbackData.length}</p>
      </div>

      {/* FILTER BUTTONS */}
      <div className="filter-buttons">
        <button 
          className={filter === "ALL" ? "active" : ""} 
          onClick={() => setFilter("ALL")}
        >
          All
        </button>
        <button 
          className={filter === "NEW" ? "active" : ""} 
          onClick={() => setFilter("NEW")}
        >
          New
        </button>
        <button 
          className={filter === "REVIEWED" ? "active" : ""} 
          onClick={() => setFilter("REVIEWED")}
        >
          Reviewed
        </button>
      </div>

      {/* DOWNLOAD BUTTONS */}
      <div className="download-buttons">
        <button className="csv" onClick={downloadCSV}>
          Download CSV
        </button>
        <button className="excel" onClick={downloadExcel}>
          Download Excel
        </button>
      </div>

      {/* TABLE */}
      <table className="feedback-table">
        <thead>
          <tr>
            <th>User</th>
            <th>Company</th>
            <th>Rating</th>
            <th>Comment</th>
            <th>Status</th>
            <th>Date</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {feedbackData.length === 0 ? (
            <tr>
              <td colSpan="7" style={{ textAlign: "center" }}>
                No feedback available
              </td>
            </tr>
          ) : (
            feedbackData.map((f) => (
              <tr key={f.id}>
                <td>{f.userName || "Anonymous"}</td>
                <td>{f.companyName}</td>
                <td>{"⭐".repeat(f.rating)}</td>
                <td>{f.comments}</td>
                <td>
                  <span className={`status ${f.status.toLowerCase()}`}>
                    {f.status}
                  </span>
                </td>
                <td>{new Date(f.createdAt).toLocaleDateString()}</td>
                <td>
                  {f.status === "NEW" && (
                    <button 
                      className="review-btn"
                      onClick={() => markAsReviewed(f.id)}
                    >
                      Mark Reviewed
                    </button>
                  )}
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default AppFeedback;
