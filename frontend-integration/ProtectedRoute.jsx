import React from "react";
import { Navigate } from "react-router-dom";
import { isAuthenticated, getUserRole } from "./authApi";

/**
 * Protected Route Component
 * Restricts access based on authentication and role
 * 
 * Usage:
 * <ProtectedRoute allowedRoles={["ADMIN"]}>
 *   <AdminDashboard />
 * </ProtectedRoute>
 */
const ProtectedRoute = ({ children, allowedRoles = [] }) => {
  // Check if user is authenticated
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }

  // Check if user has required role
  if (allowedRoles.length > 0) {
    const userRole = getUserRole();
    
    if (!allowedRoles.includes(userRole)) {
      // Redirect based on user's actual role
      if (userRole === "ADMIN") {
        return <Navigate to="/admin/dashboard" replace />;
      } else if (userRole === "VENDOR") {
        return <Navigate to="/vendor/monitor" replace />;
      } else if (userRole === "USER") {
        return <Navigate to="/user/dashboard" replace />;
      }
      
      return <Navigate to="/unauthorized" replace />;
    }
  }

  return children;
};

export default ProtectedRoute;
