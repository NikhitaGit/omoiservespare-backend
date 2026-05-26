package com.omoikaneinnovations.omoiservespare.security;

import com.omoikaneinnovations.omoiservespare.entity.Role;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.entity.VendorStatus;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Arrays;

/**
 * 🔐 Role-Based Access Control (RBAC) Aspect
 * 
 * Automatically enforces role-based authorization on annotated methods
 * 
 * Flow:
 * 1. Extract JWT token from request
 * 2. Get user from database
 * 3. Check if user has required role
 * 4. Check vendor approval if needed
 * 5. Allow or deny access
 */
@Aspect
@Component
@RequiredArgsConstructor
@Slf4j
public class RoleAuthorizationAspect {
    
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    
    /**
     * Intercept methods with @RequireRole annotation
     */
    @Around("@annotation(requireRole)")
    public Object checkRole(ProceedingJoinPoint joinPoint, RequireRole requireRole) throws Throwable {
        
        // Get HTTP request
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            log.error("No request context available");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized");
        }
        
        HttpServletRequest request = attributes.getRequest();
        
        // Extract token
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.warn("Missing or invalid Authorization header");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Missing authentication token");
        }
        
        String token = authHeader.substring(7);
        
        // Validate token
        if (!jwtUtil.validateToken(token)) {
            log.warn("Invalid JWT token");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid or expired token");
        }
        
        // Get user email from token
        String email = jwtUtil.extractEmail(token);
        
        // Fetch user from database
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Check if account is active
        if (!user.getAccountActive()) {
            log.warn("Account suspended: {}", email);
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Your account has been suspended. Please contact support.");
        }
        
        // Check if user has required role
        Role[] allowedRoles = requireRole.value();
        boolean hasRole = Arrays.asList(allowedRoles).contains(user.getRole());
        
        if (!hasRole) {
            log.warn("Access denied for user {} with role {}. Required: {}", 
                email, user.getRole(), Arrays.toString(allowedRoles));
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("You don't have permission to access this resource");
        }
        
        log.debug("Role check passed for user {} with role {}", email, user.getRole());
        
        // Store user in request attribute for controllers to use
        request.setAttribute("currentUser", user);
        
        // Proceed with method execution
        return joinPoint.proceed();
    }
    
    /**
     * Intercept methods with @RequireVendorApproval annotation
     */
    @Around("@annotation(requireVendorApproval)")
    public Object checkVendorApproval(ProceedingJoinPoint joinPoint, RequireVendorApproval requireVendorApproval) throws Throwable {
        
        // Get HTTP request
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized");
        }
        
        HttpServletRequest request = attributes.getRequest();
        
        // Get user (should be set by @RequireRole aspect)
        User user = (User) request.getAttribute("currentUser");
        
        if (user == null) {
            // Fallback: extract from token
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                String email = jwtUtil.extractEmail(token);
                user = userRepository.findByEmail(email).orElse(null);
            }
        }
        
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized");
        }
        
        // Check if vendor is approved
        if (user.getRole() == Role.VENDOR) {
            if (user.getVendorStatus() != VendorStatus.APPROVED) {
                log.warn("Vendor not approved: {} (status: {})", user.getEmail(), user.getVendorStatus());
                
                String message = switch (user.getVendorStatus()) {
                    case PENDING -> "Your vendor application is pending approval";
                    case SUSPENDED -> "Your vendor account has been suspended";
                    case REJECTED -> "Your vendor application was rejected";
                    default -> "Vendor account not approved";
                };
                
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(message);
            }
        }
        
        log.debug("Vendor approval check passed for user {}", user.getEmail());
        
        // Proceed with method execution
        return joinPoint.proceed();
    }
}
