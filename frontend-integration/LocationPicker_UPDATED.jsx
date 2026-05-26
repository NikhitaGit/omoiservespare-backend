import React, { useEffect, useState, useRef } from "react";
import { FiArrowLeft, FiSearch, FiPlus, FiHome } from "react-icons/fi";
import { MdMyLocation } from "react-icons/md";
import { BsBriefcase } from "react-icons/bs";
import { useNavigate } from "react-router-dom";
import "./LocationPicker.css";

// ✅ Import location API service
import {
  saveLocation,
  getAllAddresses,
  deleteAddress,
  updateAddress,
  getCurrentGPSLocation
} from "../api/locationApi";

export default function LocationPicker({ open = true, onClose, onSelect }) {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const [saved, setSaved] = useState([]);
  const [selectedId, setSelectedId] = useState(null);
  const [locLoading, setLocLoading] = useState(false);
  const [locError, setLocError] = useState("");
  const [showAdd, setShowAdd] = useState(false);
  const [newTitle, setNewTitle] = useState("Home");
  const [newAddress, setNewAddress] = useState("");
  const [newPhone, setNewPhone] = useState("");
  const [openMenuId, setOpenMenuId] = useState(null);
  const [showEdit, setShowEdit] = useState(false);
  const [editId, setEditId] = useState(null);
  const [editTitle, setEditTitle] = useState("Home");
  const [editAddress, setEditAddress] = useState("");
  const [editPhone, setEditPhone] = useState("");

  const sheetRef = useRef(null);
  const inputRef = useRef(null);

  // ✅ Load addresses from backend on mount
  useEffect(() => {
    fetchAddresses();
  }, []);

  const fetchAddresses = async () => {
    try {
      const addresses = await getAllAddresses();
      setSaved(addresses || []);
    } catch (error) {
      console.error("Failed to load addresses:", error);
      setSaved([]);
    }
  };

  // ✅ Handle "Use Current Location" with backend integration
  const handleUseCurrentLocation = async () => {
    setLocError("");
    setLocLoading(true);

    try {
      // Get GPS coordinates from browser
      const coords = await getCurrentGPSLocation();

      // Save to backend (backend will reverse geocode)
      const response = await saveLocation({
        type: "CURRENT",
        title: "Current Location",
        latitude: coords.latitude,
        longitude: coords.longitude,
        phoneNumber: newPhone.trim() || null // Send null instead of empty string
      });

      console.log("✅ Location saved:", response);

      // Refresh address list
      await fetchAddresses();

      // Notify parent component
      onSelect?.({
        type: "current",
        title: "Current location",
        subtitle: response.data.address,
        coords: {
          lat: coords.latitude,
          lng: coords.longitude
        }
      });

      onClose?.();
    } catch (error) {
      console.error("❌ Location error:", error);
      if (error.code === 1) {
        setLocError("Location permission denied.");
      } else if (error.code === 2) {
        setLocError("Location unavailable.");
      } else {
        setLocError("Could not fetch location.");
      }
    } finally {
      setLocLoading(false);
    }
  };

  // ✅ Handle "Add Address" with backend integration
  const handleAddAddress = async () => {
    const addr = newAddress.trim();
    if (!addr) return;

    try {
      const response = await saveLocation({
        type: "MANUAL",
        title: newTitle,
        address: addr,
        phoneNumber: newPhone.trim() || null // Send null instead of empty string
      });

      console.log("✅ Address saved:", response);

      // Refresh address list
      await fetchAddresses();

      // Reset form
      setShowAdd(false);
      setNewAddress("");
      setNewPhone("");
      setNewTitle("Home");
    } catch (error) {
      console.error("❌ Failed to save address:", error);
      alert("Failed to save address. Please try again.");
    }
  };

  // ✅ Handle "Delete Address" with backend integration
  const handleDelete = async (id) => {
    try {
      await deleteAddress(id);
      console.log("✅ Address deleted");

      // Refresh address list
      await fetchAddresses();

      setOpenMenuId(null);
      if (selectedId === id) setSelectedId(null);
    } catch (error) {
      console.error("❌ Failed to delete address:", error);
      alert("Failed to delete address. Please try again.");
    }
  };

  // ✅ Handle "Edit Address" with backend integration
  const handleSaveEdit = async () => {
    const addr = editAddress.trim();
    if (!addr || !editId) return;

    try {
      await updateAddress(editId, {
        type: "MANUAL",
        title: editTitle,
        address: addr,
        phoneNumber: editPhone.trim() || null // Send null instead of empty string
      });

      console.log("✅ Address updated");

      // Refresh address list
      await fetchAddresses();

      setShowEdit(false);
      setEditId(null);
    } catch (error) {
      console.error("❌ Failed to update address:", error);
      alert("Failed to update address. Please try again.");
    }
  };

  const handleSelectSaved = (item) => {
    setSelectedId(item.id);
    onSelect?.({ type: "saved", ...item });
    onClose?.();
  };

  const openEdit = (a) => {
    setOpenMenuId(null);
    setEditId(a.id);
    setEditTitle(a.title || "Home");
    setEditAddress(a.address || "");
    setEditPhone(a.phoneNumber || "");
    setShowEdit(true);
  };

  const handleBackToHome = () => {
    onClose?.();
    navigate("/home");
  };

  const filteredSaved = saved.filter((a) => {
    const q = query.trim().toLowerCase();
    if (!q) return true;
    const hay = `${a.title} ${a.address} ${a.phoneNumber}`.toLowerCase();
    return hay.includes(q);
  });

  if (!open) return null;

  return (
    <div className="lp-page">
      <div className="lp-backdrop">
        <div className="lp-sheet" ref={sheetRef} role="dialog" aria-modal="true">
          <div className="lp-topbar">
            <button className="lp-back-icon" onClick={handleBackToHome} aria-label="Back">
              <FiArrowLeft />
            </button>
            <div className="lp-title">Select a location</div>
            <div className="lp-topbar-spacer" />
          </div>

          <div className="lp-body">
            <div className="lp-search-wrap">
              <span className="lp-search-ico">
                <FiSearch />
              </span>
              <input
                ref={inputRef}
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search for area, street name..."
                aria-label="Search location"
              />
            </div>

            <div className="lp-actions">
              <button
                className="lp-action-card"
                onClick={handleUseCurrentLocation}
                disabled={locLoading}
              >
                <div className="lp-action-left">
                  <span className="lp-action-icon loc">
                    <MdMyLocation />
                  </span>
                  <div>
                    <div className="lp-action-title">
                      {locLoading ? "Fetching current location..." : "Use current location"}
                    </div>
                    <div className="lp-action-subtitle">Use GPS to detect your location</div>
                  </div>
                </div>
                <span className="lp-arrow">›</span>
              </button>

              {locError ? <div className="lp-error">{locError}</div> : null}

              <button className="lp-action-card" onClick={() => setShowAdd(true)}>
                <div className="lp-action-left">
                  <span className="lp-action-icon add">
                    <FiPlus />
                  </span>
                  <div>
                    <div className="lp-action-title">Add Address</div>
                    <div className="lp-action-subtitle">Save a new delivery location</div>
                  </div>
                </div>
                <span className="lp-arrow">›</span>
              </button>
            </div>

            <div className="lp-section">
              <div className="lp-section-title">SAVED ADDRESSES</div>
              {filteredSaved.length === 0 ? (
                <div className="lp-empty">
                  No saved addresses yet. Click <b>Add Address</b> to create one.
                </div>
              ) : (
                <div className="lp-list">
                  {filteredSaved.map((a) => {
                    const t = (a.title || "").toLowerCase();
                    const isWork = t === "work";
                    return (
                      <div key={a.id} className={`lp-card ${selectedId === a.id ? "active" : ""}`}>
                        <button
                          className="lp-card-main"
                          onClick={() => handleSelectSaved(a)}
                          type="button"
                        >
                          <div className={`lp-card-ico ${isWork ? "work" : "home"}`}>
                            {isWork ? <BsBriefcase /> : <FiHome />}
                          </div>
                          <div className="lp-card-body">
                            <div className="lp-card-title-row">
                              <div className="lp-card-title">{a.title}</div>
                              <button
                                type="button"
                                className="lp-dots"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setOpenMenuId((prev) => (prev === a.id ? null : a.id));
                                }}
                                aria-label="More options"
                              >
                                ⋮
                              </button>
                              {openMenuId === a.id && (
                                <div className="lp-menu" onClick={(e) => e.stopPropagation()}>
                                  <button
                                    type="button"
                                    className="lp-menu-item"
                                    onClick={() => openEdit(a)}
                                  >
                                    Edit address
                                  </button>
                                  <button
                                    type="button"
                                    className="lp-menu-item danger"
                                    onClick={() => handleDelete(a.id)}
                                  >
                                    Delete address
                                  </button>
                                </div>
                              )}
                            </div>
                            <div className="lp-card-address">{a.address}</div>
                            {a.phoneNumber ? (
                              <div className="lp-card-phone">Phone number: {a.phoneNumber}</div>
                            ) : null}
                          </div>
                        </button>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            <div className="lp-bottom-space" />
          </div>

          {/* ADD ADDRESS MODAL */}
          {showAdd && (
            <div className="lp-modal-backdrop" onMouseDown={() => setShowAdd(false)}>
              <div className="lp-modal" onMouseDown={(e) => e.stopPropagation()}>
                <div className="lp-modal-header">Add Address</div>
                <label className="lp-field">
                  <span>Type</span>
                  <select value={newTitle} onChange={(e) => setNewTitle(e.target.value)}>
                    <option value="Home">Home</option>
                    <option value="Work">Work</option>
                    <option value="Other">Other</option>
                  </select>
                </label>
                <label className="lp-field">
                  <span>Address</span>
                  <textarea
                    value={newAddress}
                    onChange={(e) => setNewAddress(e.target.value)}
                    placeholder="Enter full address"
                    rows={4}
                  />
                </label>
                <label className="lp-field">
                  <span>Phone</span>
                  <input
                    value={newPhone}
                    onChange={(e) => setNewPhone(e.target.value)}
                    placeholder="+91-xxxxxxxxxx"
                  />
                </label>
                <div className="lp-modal-actions">
                  <button className="lp-btn ghost" onClick={() => setShowAdd(false)}>
                    Cancel
                  </button>
                  <button className="lp-btn" onClick={handleAddAddress}>
                    Save
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* EDIT ADDRESS MODAL */}
          {showEdit && (
            <div className="lp-modal-backdrop" onMouseDown={() => setShowEdit(false)}>
              <div className="lp-modal" onMouseDown={(e) => e.stopPropagation()}>
                <div className="lp-modal-header">Edit Address</div>
                <label className="lp-field">
                  <span>Type</span>
                  <select value={editTitle} onChange={(e) => setEditTitle(e.target.value)}>
                    <option value="Home">Home</option>
                    <option value="Work">Work</option>
                    <option value="Other">Other</option>
                  </select>
                </label>
                <label className="lp-field">
                  <span>Address</span>
                  <textarea
                    value={editAddress}
                    onChange={(e) => setEditAddress(e.target.value)}
                    placeholder="Enter full address"
                    rows={4}
                  />
                </label>
                <label className="lp-field">
                  <span>Phone</span>
                  <input
                    value={editPhone}
                    onChange={(e) => setEditPhone(e.target.value)}
                    placeholder="+91-xxxxxxxxxx"
                  />
                </label>
                <div className="lp-modal-actions">
                  <button className="lp-btn ghost" onClick={() => setShowEdit(false)}>
                    Cancel
                  </button>
                  <button className="lp-btn" onClick={handleSaveEdit}>
                    Save changes
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
