import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { FiArrowLeft } from "react-icons/fi";
import { fetchCanteens } from "../api/canteenApi";
import CanteenCard from "../components/CanteenCard";
import "../styles/canteenList.css";

const CanteenList = () => {
  const [canteens, setCanteens] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const loadCanteens = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await fetchCanteens();
        setCanteens(data);
      } catch (err) {
        console.error("Failed to load canteens:", err);
        setError(err.message || "Failed to load canteens. Please try again.");
      } finally {
        setLoading(false);
      }
    };

    loadCanteens();
  }, []);

  if (loading) {
    return (
      <div className="canteen-container">
        <p style={{ textAlign: "center", padding: "20px" }}>
          Loading canteens...
        </p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="canteen-container">
        <div style={{ textAlign: "center", padding: "20px" }}>
          <p style={{ color: "red", marginBottom: "10px" }}>{error}</p>
          <button
            onClick={() => window.location.reload()}
            style={{
              padding: "10px 20px",
              backgroundColor: "#007bff",
              color: "white",
              border: "none",
              borderRadius: "5px",
              cursor: "pointer",
            }}
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  if (!canteens.length) {
    return (
      <div className="canteen-container">
        <p style={{ textAlign: "center", padding: "20px" }}>
          No canteens available
        </p>
      </div>
    );
  }

  /* 🔍 SEARCH FILTER */
  const filtered = canteens.filter((c) =>
    c.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="canteen-container">
      {/* 🔝 TOP BAR */}
      <div className="top-bar">
        <div className="search-wrap">
          <span className="back-btn" onClick={() => navigate(-1)}>
            <FiArrowLeft />
          </span>
          <input
            type="text"
            placeholder="Search canteen..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      {/* 🏢 CANTEEN LIST */}
      <div className="canteen-list">
        {filtered.length > 0 ? (
          filtered.map((c) => (
            <CanteenCard
              key={c.id}
              image={c.imageUrl}
              name={c.name}
              place={c.place}
              prepTime={c.prepTime}
              rating={c.rating}
              onClick={() => {
                localStorage.setItem("canteenId", c.id);
                localStorage.setItem("selectedCanteen", c.name);
                navigate(`/canteen/${c.id}`);
              }}
            />
          ))
        ) : (
          <p style={{ textAlign: "center", padding: "20px" }}>
            No canteens match your search
          </p>
        )}
      </div>
    </div>
  );
};

export default CanteenList;
