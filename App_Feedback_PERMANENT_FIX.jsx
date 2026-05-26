import React, { useState, useEffect, useCallback } from "react";
import "./App_Feedback.css";

const AppFeedback = () => {
  const [feedbackData, setFeedbackData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [error, setError] = useState(null);
  const [lastFetch, setLastFetch] = useState(null);

  // Get token - try both possible keys
  const getToken = () => {
    return localStorage.getItem("token") || localStorage.getItem("authToken");
  };

  // Fetch feedback from backend
  const fetchFeedback = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const token = getToken();
      
      if (!token) {
        setError("Authentication required. Please login.");
        setLoading(false);
        return;
      }

      const statusParam = statusFilter !== "ALL" ? `&status=${statusFilter}` : "";
      const url = `http://localhost:8080/api/feedback?page=${page}&size=20${statusParam}`;
      
      console.log("Fetching feedback:", url);

      const response = await fetch(url, {
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        }
      });

      console.log("Response status:", response.status);

      if (response.ok) {
        const data = await response.json();
        console.log("Feedback data received:", data);
        
        setFeedbackData(data.content || []);
        setTotalPages(data.totalPages || 0);
        setTotalElements(data.totalElements || 0);
        setLastFetch(new Date());
        setError(null);
      } else if (response.status === 401) {
        setError("Session expired. Please login again.");
        // Clear invalid token
        localStorage.removeItem("token");
        localStorage.removeItem("authToken");
      } else if (response.status === 403) {
        setError("Access denied. Only company admins (PROFESSIONAL accounts) can view feedback.");
      } else {
        const errorText = await response.text();
        setError(`Failed to load feedback: ${errorText || "Unknown error"}`);
      }
    } catch (error) {
      console.error("Error loading feedback:", error);
      setError("Network error. Please check your connection and ensure the backend is running.");
    } finally {
      setLoading(false);
    }
  }, [page, statusFilter]);

  // Load feedback on mount and when filters change
  useEffect(() => {
    fetchFeedback();
  }, [fetchFeedback]);

  // Real-time updates - poll every 10 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      console.log("Auto-refreshing feedback...");
      fetchFeedback();
    }, 10000); // 10 seconds

    return () => clearInterval(interval);
  }, [fetchFeedback]);

  // Mark as reviewed
  const markAsReviewed = async (id) => {
    try {
      const token = getToken();
      
      if (!token) {
        alert("Authentication required. Please login.");
        return;
      }

      const response = await fetch(`http://localhost:8080/api/feedback/${id}/review`, {
        method: "PUT",
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        }
      });

      if (response.ok) {
        console.log("Feedback marked as reviewed:", id);
        fetchFeedback(); // Refresh list
        alert("Feedback marked as reviewed ✓");
      } else if (response.status === 401) {
        alert("Session expired. Please login again.");
      } else if (response.status === 403) {
        alert("Access denied. Only company admins can review feedback.");
      } else {
        const errorText = await response.text();
        alert(`Failed to update status: ${errorText}`);
      }
    } catch (error) {
      console.error("Failed to update status:", error);
      alert("Network error. Failed to update status.");
    }
  };

  // CSV Download
  const downloadCSV = async () => {
    try {
      const token = getToken();
      
      if (!token) {
        alert("Authentication required. Please login.");
        return;
      }

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
        a.download = `feedback_${new Date().toISOString().split('T')[0]}.csv`;
        a.click();
        window.URL.revokeObjectURL(url);
        console.log("CSV downloaded successfully");
      } else {
        alert("Failed to export CSV. Please try again.");
      }
    } catch (error) {
      console.error("Failed to export CSV:", error);
      alert("Network error. Failed to export CSV.");
    }
  };

  // Excel Download
  const downloadExcel = async () => {
    try {
      const token = getToken();
      
      if (!token) {
        alert("Authentication required. Please login.");
        return;
      }

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
        a.download = `feedback_${new Date().toISOString().split('T')[0]}.xlsx`;
        a.click();
        window.URL.revokeObjectURL(url);
        console.log("Excel downloaded successfully");
      } else {
        alert("Failed to export Excel. Please try again.");
      }
    } catch (error) {
      console.error("Failed to export Excel:", error);
      alert("Network error. Failed to export Excel.");
    }
  };

  // Average Rating
  const avgRating = feedbackData.length > 0
    ? feedbackData.reduce((acc, f) => acc + f.rating, 0) / feedbackData.length
    : 0;

  return (
    <div className="feedback-page">
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h2>User Feedback & Ratings</h2>
        <button 
          onClick={fetchFeedback}
          disabled={loading}
          style={{
            padding: "8px 16px",
            backgroundColor: "#3b82f6",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: loading ? "not-allowed" : "pointer",
            opacity: loading ? 0.6 : 1
          }}
        >
          {loading ? "Refreshing..." : "🔄 Refresh"}
        </button>
      </div>

      {lastFetch && (
        <p style={{ fontSize: "12px", color: "#666", marginTop: "4px" }}>
          Last updated: {lastFetch.toLocaleTimeString()} (auto-refresh every 10s)
        </p>
      )}

      {/* ERROR MESSAGE */}
      {error && (
        <div style={{
          padding: "12px",
          backgroundColor: "#fee",
          color: "#c00",
          borderRadius: "8px",
          marginTop: "16px",
          marginBottom: "16px",
          border: "1px solid #fcc"
        }}>
          <strong>Error:</strong> {error}
          {error.includes("login") && (
            <div style={{ marginTop: "8px" }}>
              <a href="/login" style={{ color: "#c00", textDecoration: "underline" }}>
                Go to Login
              </a>
            </div>
          )}
        </div>
      )}

      {/* SUMMARY */}
      <div className="rating-summary">
        <h3>Average Rating</h3>
        <div className="stars">
          {"⭐".repeat(Math.round(avgRating))}
        </div>
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
        <button className="csv" onClick={downloadCSV}>
          📥 Download CSV
        </button>
        <button className="excel" onClick={downloadExcel}>
          📊 Download Excel
        </button>
      </div>

      {/* LOADING STATE */}
      {loading && !feedbackData.length && (
        <div style={{ textAlign: "center", padding: "40px" }}>
          <p>Loading feedback...</p>
        </div>
      )}

      {/* NO DATA STATE */}
      {!loading && feedbackData.length === 0 && !error && (
        <div style={{ textAlign: "center", padding: "40px", color: "#666" }}>
          <p>No feedback available</p>
          <p style={{ fontSize: "14px", marginTop: "8px" }}>
            Feedback will appear here once users submit their reviews.
          </p>
        </div>
      )}

      {/* TABLE */}
      {feedbackData.length > 0 && (
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
                <td style={{ maxWidth: "300px", wordWrap: "break-word" }}>
                  {f.comments}
                </td>
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
                    <small>
                      Reviewed: {new Date(f.reviewedAt).toLocaleDateString()}
                    </small>
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
          <span>
            Page {page + 1} of {totalPages}
          </span>
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
