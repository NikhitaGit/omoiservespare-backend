package com.omoikaneinnovations.omoiservespare.security;

import com.omoikaneinnovations.omoiservespare.entity.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 🔐 Security Utility Methods
 * 
 * Helper methods for accessing current user in controllers
 */
public class SecurityUtils {
    
    private static final Logger logger = LoggerFactory.getLogger(SecurityUtils.class);
    
    /**
     * Get current authenticated user from request
     * 
     * @return Current user or null if not authenticated
     */
    public static User getCurrentUser() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            logger.warn("🔐 SecurityUtils.getCurrentUser() - RequestAttributes is NULL");
            return null;
        }
        
        HttpServletRequest request = attributes.getRequest();
        User user = (User) request.getAttribute("currentUser");
        
        if (user == null) {
            logger.warn("🔐 SecurityUtils.getCurrentUser() - currentUser attribute is NULL for path: {}", request.getRequestURI());
        } else {
            logger.debug("🔐 SecurityUtils.getCurrentUser() - Found user: id={}, email={}", user.getId(), user.getEmail());
        }
        
        return user;
    }
    
    /**
     * Get current user ID
     * 
     * @return User ID or null
     */
    public static Long getCurrentUserId() {
        User user = getCurrentUser();
        Long userId = user != null ? user.getId() : null;
        
        if (userId == null) {
            logger.warn("🔐 SecurityUtils.getCurrentUserId() - Returning NULL");
        } else {
            logger.debug("🔐 SecurityUtils.getCurrentUserId() - Returning userId: {}", userId);
        }
        
        return userId;
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
