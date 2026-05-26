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

  // AUTO-DETECT TOKEN - tries multiple common keys
  const getToken = () => {
    const possibleKeys = ["token", "authToken", "jwt", "accessToken", "jwtToken"];
    
    for (const key of possibleKeys) {
      const token = localStorage.getItem(key);
      if (token && token.startsWith("eyJ")) {
        console.log(`✓ Token found with key: "${key}"`);
        return token;
      }
    }
    
    console.error("✗ No JWT token found in localStorage");
    console.log("Available keys:", Object.keys(localStorage));
    return null;
  };

  // Fetch feedback from backend
  const fetchFeedback = async () => {
    setLoading(true);
    setError(null);
    
    const token = getToken();
    
    if (!token) {
      setError("Not logged in. Please login first.");
      setLoading(false);
      return;
    }
    
    try {
      const statusParam = statusFilter !== "ALL" ? `&status=${statusFilter}` : "";
      const url = `http://localhost:8080/api/feedback?page=${page}&size=20${statusParam}`;
      
      console.log("Fetching feedback from:", url);
      console.log("Using token:", token.substring(0, 20) + "...");
      
      const response = await fetch(url, {
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        }
      });

      console.log("Response status:", response.status);

      if (response.ok) {
        const data = await response.json();
        console.log("✓ Feedback data received:", data);
        setFeedbackData(data.content);
        setTotalPages(data.totalPages);
        setTotalElements(data.totalElements);
      } else if (response.status === 401) {
        setError("Authentication failed. Please login again.");
        console.error("401 Unauthorized - Token may be expired");
      } else if (response.status === 403) {
        setError("Access denied. Only company admins (PROFESSIONAL users) can view feedback.");
      } else {
        const errorText = await response.text();
        setError(`Failed to load feedback: ${response.status}`);
        console.error("Error response:", errorText);
      }
    } catch (error) {
      console.error("Network error:", error);
      setError("Network error. Please check if backend is running on port 8080.");
    } finally {
      setLoading(false);
    }
  };

  // Load feedback on mount and when filters change
  useEffect(() => {
    fetchFeedback();
    
    // Poll for updates every 30 seconds
    const interval = setInterval(fetchFeedback, 30000);
    return () => clearInterval(interval);
  }, [page, statusFilter]);

  // Mark as reviewed
  const markAsReviewed = async (id) => {
    const token = getToken();
    if (!token) {
      alert("Not logged in");
      return;
    }
    
    try {
      const response = await fetch(
        `http://localhost:8080/api/feedback/${id}/review`,
        {
          method: "PUT",
          headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json"
          }
        }
      );

      if (response.ok) {
        fetchFeedback();
        alert("Feedback marked as reviewed");
      } else {
        alert(`Failed to update status: ${response.status}`);
      }
    } catch (error) {
      console.error("Failed to update status:", error);
      alert("Failed to update status");
    }
  };

  // CSV Download
  const downloadCSV = async () => {
    const token = getToken();
    if (!token) {
      alert("Not logged in");
      return;
    }
    
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
        alert(`Failed to export CSV: ${response.status}`);
      }
    } catch (error) {
      console.error("Failed to export CSV:", error);
      alert("Failed to export CSV");
    }
  };

  // Excel Download
  const downloadExcel = async () => {
    const token = getToken();
    if (!token) {
      alert("Not logged in");
      return;
    }
    
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
        alert(`Failed to export Excel: ${response.status}`);
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
          padding: "15px", 
          backgroundColor: "#fee", 
          color: "#c00", 
          borderRadius: "4px",
          marginBottom: "20px",
          border: "1px solid #fcc"
        }}>
          <strong>Error:</strong> {error}
          <br />
          <small>Check browser console (F12) for more details</small>
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
        <p>No feedback available. Submit some feedback first!</p>
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
