package com.omoikaneinnovations.omoiservespare.security;

import com.omoikaneinnovations.omoiservespare.entity.User;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 🔐 Security Utility Methods
 * 
 * Helper methods for accessing current user in controllers
 */
public class SecurityUtils {
    
    /**
     * Get current authenticated user from request
     * 
     * @return Current user or null if not authenticated
     */
    public static User getCurrentUser() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            return null;
        }
        
        HttpServletRequest request = attributes.getRequest();
        return (User) request.getAttribute("currentUser");
    }
    
    /**
     * Get current user ID
     * 
     * @return User ID or null
     */
    public static Long getCurrentUserId() {
        User user = getCurrentUser();
        return user != null ? user.getId() : null;
    }
    
    /**
     * Get current user email
     * 
     * @return User email or null
     */
    public static String getCurrentUserEmail() {
        User user = getCurrentUser();
        return user != null ? user.getEmail() : null;
    }
    
    /**
     * Check if current user is admin
     */
    public static boolean isCurrentUserAdmin() {
        User user = getCurrentUser();
        return user != null && user.isAdmin();
    }
    
    /**
     * Check if current user is vendor
     */
    public static boolean isCurrentUserVendor() {
        User user = getCurrentUser();
        return user != null && user.isVendor();
    }
    
    /**
     * Check if current user owns the resource
     * 
     * @param resourceOwnerId Owner ID of the resource
     * @return true if current user owns the resource or is admin
     */
    public static boolean canAccessResource(Long resourceOwnerId) {
        User user = getCurrentUser();
        if (user == null) {
            return false;
        }
        
        // Admin can access everything
        if (user.isAdmin()) {
            return true;
        }
        
        // Check ownership
        return user.getId().equals(resourceOwnerId);
    }
}
