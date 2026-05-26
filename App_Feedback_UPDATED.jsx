import React, { useState, useEffect } from "react";
import "./App_Feedback.css";

const AppFeedback = () => {
  const [feedbackData, setFeedbackData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [error, setError] = useState(null);

  const token = localStorage.getItem("token"); // Your JWT token key

  // Fetch feedback from backend
  const fetchFeedback = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const statusParam = statusFilter !== "ALL" ? `&status=${statusFilter}` : "";
      const response = await fetch(
        `http://localhost:8080/api/feedback?page=${page}&size=20${statusParam}`,
        {
          headers: {
            "Authorization": `Bearer ${token}`
          }
        }
      );

      if (response.ok) {
        const data = await response.json();
        console.log("Feedback data received:", data); // Debug log
        setFeedbackData(data.content);
        setTotalPages(data.totalPages);
        setTotalElements(data.totalElements);
      } else if (response.status === 403) {
        setError("Access denied. Only company admins can view feedback.");
      } else {
        setError("Failed to load feedback. Please try again.");
      }
    } catch (error) {
      console.error("Error loading feedback:", error);
      setError("Network error. Please check your connection.");
    } finally {
      setLoading(false);
    }
  };

  // Load feedback on mount and when filters change
  useEffect(() => {
    fetchFeedback();
    
    // Poll for updates every 30 seconds (real-time updates)
    const interval = setInterval(fetchFeedback, 30000);
    return () => clearInterval(interval);
  }, [page, statusFilter]);

  // Mark as reviewed
  const markAsReviewed = async (id) => {
    try {
      const response = await fetch(
        `http://localhost:8080/api/feedback/${id}/review`,
        {
          method: "PUT",
          headers: {
            "Authorization": `Bearer ${token}`
          }
        }
      );

      if (response.ok) {
        fetchFeedback(); // Refresh list
        alert("Feedback marked as reviewed");
      } else {
        alert("Failed to update status");
      }
    } catch (error) {
      console.error("Failed to update status:", error);
      alert("Failed to update status");
    }
  };

  // CSV Download from backend
  const downloadCSV = async () => {
    try {
      const response = await fetch(
        "http://localhost:8080/api/feedback/export/csv",
        {
          headers: {
            "Authorization": `Bearer ${token}`
          }
        }
      );

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `feedback_${new Date().toISOString().split('T')[0]}.csv`;
        a.click();
        window.URL.revokeObjectURL(url);
      } else {
        alert("Failed to export CSV");
      }
    } catch (error) {
      console.error("Failed to export CSV:", error);
      alert("Failed to export CSV");
    }
  };

  // Excel Download from backend
  const downloadExcel = async () => {
    try {
      const response = await fetch(
        "http://localhost:8080/api/feedback/export/excel",
        {
          headers: {
            "Authorization": `Bearer ${token}`
          }
        }
      );

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `feedback_${new Date().toISOString().split('T')[0]}.xlsx`;
        a.click();
        window.URL.revokeObjectURL(url);
      } else {
        alert("Failed to export Excel");
      }
    } catch (error) {
      console.error("Failed to export Excel:", error);
      alert("Failed to export Excel");
    }
  };

  // Average Rating
  const avgRating = feedbackData.length > 0
    ? feedbackData.reduce((acc, f) => acc + f.rating, 0) / feedbackData.length
    : 0;

  return (
    <div className="feedback-page">
      <h2>User Feedback & Ratings</h2>

      {/* ERROR MESSAGE */}
      {error && (
        <div style={{ 
          padding: "10px", 
          backgroundColor: "#fee", 
          color: "#c00", 
          borderRadius: "4px",
          marginBottom: "20px"
        }}>
          {error}
        </div>
      )}

      {/* SUMMARY */}
      <div className="rating-summary">
        <h3>Average Rating</h3>
        <div className="stars">{"⭐".repeat(Math.round(avgRating))}</div>
        <p>{avgRating.toFixed(1)} / 5</p>
        <p>Total Feedback: {totalElements}</p>
      </div>

      {/* FILTERS */}
      <div className="filters" style={{ margin: "20px 0" }}>
        <label style={{ marginRight: "10px", fontWeight: "bold" }}>
          Filter by Status: 
        </label>
        <select 
          value={statusFilter} 
          onChange={(e) => { 
            setStatusFilter(e.target.value); 
            setPage(0); 
          }}
          style={{ 
            padding: "8px", 
            borderRadius: "4px", 
            border: "1px solid #ddd" 
          }}
        >
          <option value="ALL">All Feedback</option>
          <option value="NEW">New</option>
          <option value="REVIEWED">Reviewed</option>
        </select>
      </div>

      {/* DOWNLOAD BUTTONS */}
      <div className="download-buttons">
        <button className="csv" onClick={downloadCSV}>Download CSV</button>
        <button className="excel" onClick={downloadExcel}>Download Excel</button>
      </div>

      {/* LOADING STATE */}
      {loading && <p>Loading feedback...</p>}

      {/* NO DATA STATE */}
      {!loading && feedbackData.length === 0 && !error && (
        <p>No feedback available</p>
      )}

      {/* TABLE */}
      {!loading && feedbackData.length > 0 && (
        <table className="feedback-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>User</th>
              <th>Rating</th>
              <th>Comment</th>
              <th>Status</th>
              <th>Submitted</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {feedbackData.map((f) => (
              <tr key={f.id}>
                <td>{f.id}</td>
                <td>{f.userEmail}</td>
                <td>{"⭐".repeat(f.rating)}</td>
                <td>{f.comments}</td>
                <td>
                  <span 
                    style={{
                      padding: "4px 12px",
                      borderRadius: "12px",
                      fontSize: "12px",
                      fontWeight: "bold",
                      backgroundColor: f.status === "NEW" ? "#fef3c7" : "#d1fae5",
                      color: f.status === "NEW" ? "#92400e" : "#065f46"
                    }}
                  >
                    {f.status}
                  </span>
                </td>
                <td>{new Date(f.createdAt).toLocaleDateString()}</td>
                <td>
                  {f.status === "NEW" && (
                    <button 
                      onClick={() => markAsReviewed(f.id)}
                      style={{
                        padding: "6px 12px",
                        backgroundColor: "#3b82f6",
                        color: "white",
                        border: "none",
                        borderRadius: "4px",
                        cursor: "pointer"
                      }}
                    >
                      Mark Reviewed
                    </button>
                  )}
                  {f.status === "REVIEWED" && f.reviewedAt && (
                    <small>Reviewed: {new Date(f.reviewedAt).toLocaleDateString()}</small>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {/* PAGINATION */}
      {totalPages > 1 && (
        <div 
          className="pagination" 
          style={{ 
            display: "flex", 
            justifyContent: "center", 
            alignItems: "center", 
            gap: "20px", 
            marginTop: "20px" 
          }}
        >
          <button 
            disabled={page === 0} 
            onClick={() => setPage(page - 1)}
            style={{
              padding: "8px 16px",
              backgroundColor: page === 0 ? "#cbd5e1" : "#3b82f6",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: page === 0 ? "not-allowed" : "pointer"
            }}
          >
            Previous
          </button>
          <span>Page {page + 1} of {totalPages}</span>
          <button 
            disabled={page >= totalPages - 1} 
            onClick={() => setPage(page + 1)}
            style={{
              padding: "8px 16px",
              backgroundColor: page >= totalPages - 1 ? "#cbd5e1" : "#3b82f6",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: page >= totalPages - 1 ? "not-allowed" : "pointer"
            }}
          >
            Next
          </button>
        </div>
      )}
    </div>
  );
};

export default AppFeedback;
