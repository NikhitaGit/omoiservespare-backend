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
  const [debugInfo, setDebugInfo] = useState([]);

  // Enhanced token detection with debugging
  const getToken = () => {
    const possibleKeys = ["token", "authToken", "jwt", "accessToken", "jwtToken"];
    const debug = [];
    
    debug.push("🔍 Searching for JWT token in localStorage...");
    debug.push(`Available keys: ${Object.keys(localStorage).join(", ")}`);
    
    for (const key of possibleKeys) {
      const token = localStorage.getItem(key);
      if (token) {
        debug.push(`Found "${key}": ${token.substring(0, 20)}...`);
        if (token.startsWith("eyJ")) {
          debug.push(`✓ Valid JWT token found with key: "${key}"`);
          setDebugInfo(debug);
          return token;
        } else {
          debug.push(`✗ "${key}" doesn't look like a JWT (should start with "eyJ")`);
        }
      }
    }
    
    debug.push("✗ No valid JWT token found!");
    debug.push("💡 Make sure you're logged in and the token is stored in localStorage");
    setDebugInfo(debug);
    return null;
  };

  // Fetch feedback from backend
  const fetchFeedback = async () => {
    setLoading(true);
    setError(null);
    const debug = [...debugInfo];
    
    const token = getToken();
    
    if (!token) {
      setError("Not logged in. Please login first to view feedback.");
      setLoading(false);
      return;
    }
    
    try {
      const statusParam = statusFilter !== "ALL" ? `&status=${statusFilter}` : "";
      const url = `http://localhost:8080/api/feedback?page=${page}&size=20${statusParam}`;
      
      debug.push(`📡 Fetching: ${url}`);
      debug.push(`🔑 Using token: ${token.substring(0, 30)}...`);
      setDebugInfo(debug);
      
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        }
      });

      debug.push(`📥 Response status: ${response.status} ${response.statusText}`);
      setDebugInfo(debug);

      if (response.ok) {
        const data = await response.json();
        debug.push(`✓ Success! Received ${data.content.length} feedback items`);
        setDebugInfo(debug);
        
        setFeedbackData(data.content);
        setTotalPages(data.totalPages);
        setTotalElements(data.totalElements);
      } else if (response.status === 401) {
        const errorText = await response.text();
        debug.push(`✗ 401 Unauthorized: ${errorText}`);
        setDebugInfo(debug);
        setError("Authentication failed. Your session may have expired. Please login again.");
      } else if (response.status === 403) {
        debug.push("✗ 403 Forbidden: Access denied");
        setDebugInfo(debug);
        setError("Access denied. Only company admins (PROFESSIONAL users) can view feedback.");
      } else {
        const errorText = await response.text();
        debug.push(`✗ Error ${response.status}: ${errorText}`);
        setDebugInfo(debug);
        setError(`Failed to load feedback: ${response.status} - ${errorText}`);
      }
    } catch (error) {
      debug.push(`✗ Network error: ${error.message}`);
      setDebugInfo(debug);
      setError(`Network error: ${error.message}. Check if backend is running on port 8080.`);
    } finally {
      setLoading(false);
    }
  };

  // Load feedback on mount and when filters change
  useEffect(() => {
    fetchFeedback();
  }, [page, statusFilter]);

  // Mark as reviewed
  const markAsReviewed = async (id) => {
    const token = getToken();
    if (!token) {
      alert("Not logged in. Please login first.");
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
        alert("Feedback marked as reviewed!");
        fetchFeedback(); // Refresh the list
      } else {
        const errorText = await response.text();
        alert(`Failed to update: ${response.status} - ${errorText}`);
      }
    } catch (error) {
      console.error("Failed to update status:", error);
      alert(`Network error: ${error.message}`);
    }
  };

  // CSV Download
  const downloadCSV = async () => {
    const token = getToken();
    if (!token) {
      alert("Not logged in. Please login first.");
      return;
    }
    
    try {
      const response = await fetch(
        "http://localhost:8080/api/feedback/export/csv",
        {
          method: "GET",
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
        
        // Get filename from Content-Disposition header or use default
        const contentDisposition = response.headers.get("Content-Disposition");
        const filename = contentDisposition 
          ? contentDisposition.split("filename=")[1].replace(/"/g, "")
          : `feedback_${new Date().toISOString().split('T')[0]}.csv`;
        
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
        
        alert("CSV downloaded successfully!");
      } else {
        const errorText = await response.text();
        alert(`Failed to export CSV: ${response.status} - ${errorText}`);
      }
    } catch (error) {
      console.error("Failed to export CSV:", error);
      alert(`Network error: ${error.message}`);
    }
  };

  // Excel Download
  const downloadExcel = async () => {
    const token = getToken();
    if (!token) {
      alert("Not logged in. Please login first.");
      return;
    }
    
    try {
      const response = await fetch(
        "http://localhost:8080/api/feedback/export/excel",
        {
          method: "GET",
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
        
        // Get filename from Content-Disposition header or use default
        const contentDisposition = response.headers.get("Content-Disposition");
        const filename = contentDisposition 
          ? contentDisposition.split("filename=")[1].replace(/"/g, "")
          : `feedback_${new Date().toISOString().split('T')[0]}.xlsx`;
        
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
        
        alert("Excel downloaded successfully!");
      } else {
        const errorText = await response.text();
        alert(`Failed to export Excel: ${response.status} - ${errorText}`);
      }
    } catch (error) {
      console.error("Failed to export Excel:", error);
      alert(`Network error: ${error.message}`);
    }
  };

  // Average Rating
  const avgRating = feedbackData.length > 0
    ? feedbackData.reduce((acc, f) => acc + f.rating, 0) / feedbackData.length
    : 0;

  return (
    <div className="feedback-page">
      <h2>User Feedback & Ratings</h2>

      {/* DEBUG PANEL (can be hidden in production) */}
      {debugInfo.length > 0 && (
        <details style={{ 
          marginBottom: "20px", 
          padding: "10px", 
          backgroundColor: "#f8f9fa",
          border: "1px solid #dee2e6",
          borderRadius: "4px"
        }}>
          <summary style={{ cursor: "pointer", fontWeight: "bold" }}>
            🔧 Debug Info (click to expand)
          </summary>
          <pre style={{ 
            fontSize: "12px", 
            marginTop: "10px",
            whiteSpace: "pre-wrap",
            wordWrap: "break-word"
          }}>
            {debugInfo.join("\n")}
          </pre>
        </details>
      )}

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
          <strong>⚠️ Error:</strong> {error}
          <br />
          <button 
            onClick={fetchFeedback}
            style={{
              marginTop: "10px",
              padding: "8px 16px",
              backgroundColor: "#dc3545",
              color: "white",
              border: "none",
              borderRadius: "4px",
              cursor: "pointer"
            }}
          >
            🔄 Retry
          </button>
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
      <div className="download-buttons" style={{ marginBottom: "20px" }}>
        <button 
          className="csv" 
          onClick={downloadCSV}
          style={{
            padding: "10px 20px",
            backgroundColor: "#28a745",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer",
            marginRight: "10px"
          }}
        >
          📥 Download CSV
        </button>
        <button 
          className="excel" 
          onClick={downloadExcel}
          style={{
            padding: "10px 20px",
            backgroundColor: "#007bff",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer"
          }}
        >
          📥 Download Excel
        </button>
      </div>

      {/* LOADING STATE */}
      {loading && (
        <div style={{ textAlign: "center", padding: "40px" }}>
          <p>⏳ Loading feedback...</p>
        </div>
      )}

      {/* NO DATA STATE */}
      {!loading && feedbackData.length === 0 && !error && (
        <div style={{ 
          textAlign: "center", 
          padding: "40px",
          backgroundColor: "#f8f9fa",
          borderRadius: "4px"
        }}>
          <p>📭 No feedback available yet.</p>
          <p style={{ fontSize: "14px", color: "#6c757d" }}>
            Feedback will appear here once users submit their ratings.
          </p>
        </div>
      )}

      {/* TABLE */}
      {!loading && feedbackData.length > 0 && (
        <div style={{ overflowX: "auto" }}>
          <table className="feedback-table" style={{
            width: "100%",
            borderCollapse: "collapse",
            backgroundColor: "white",
            boxShadow: "0 1px 3px rgba(0,0,0,0.1)"
          }}>
            <thead>
              <tr style={{ backgroundColor: "#f8f9fa" }}>
                <th style={{ padding: "12px", textAlign: "left", borderBottom: "2px solid #dee2e6" }}>ID</th>
                <th style={{ padding: "12px", textAlign: "left", borderBottom: "2px solid #dee2e6" }}>User</th>
                <th style={{ padding: "12px", textAlign: "left", borderBottom: "2px solid #dee2e6" }}>Rating</th>
                <th style={{ padding: "12px", textAlign: "left", borderBottom: "2px solid #dee2e6" }}>Comment</th>
                <th style={{ padding: "12px", textAlign: "left", borderBottom: "2px solid #dee2e6" }}>Status</th>
                <th style={{ padding: "12px", textAlign: "left", borderBottom: "2px solid #dee2e6" }}>Submitted</th>
                <th style={{ padding: "12px", textAlign: "left", borderBottom: "2px solid #dee2e6" }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {feedbackData.map((f) => (
                <tr key={f.id} style={{ borderBottom: "1px solid #dee2e6" }}>
                  <td style={{ padding: "12px" }}>{f.id}</td>
                  <td style={{ padding: "12px" }}>{f.userEmail}</td>
                  <td style={{ padding: "12px" }}>{"⭐".repeat(f.rating)}</td>
                  <td style={{ padding: "12px", maxWidth: "300px" }}>{f.comments || "No comment"}</td>
                  <td style={{ padding: "12px" }}>
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
                  <td style={{ padding: "12px" }}>
                    {new Date(f.createdAt).toLocaleDateString()}
                  </td>
                  <td style={{ padding: "12px" }}>
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
                        ✓ Mark Reviewed
                      </button>
                    )}
                    {f.status === "REVIEWED" && f.reviewedAt && (
                      <small style={{ color: "#6c757d" }}>
                        Reviewed: {new Date(f.reviewedAt).toLocaleDateString()}
                      </small>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
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
            ← Previous
          </button>
          <span style={{ fontWeight: "bold" }}>
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
            Next →
          </button>
        </div>
      )}
    </div>
  );
};

export default AppFeedback;
