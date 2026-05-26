package com.omoikaneinnovations.omoiservespare.security;

import com.omoikaneinnovations.omoiservespare.entity.Role;
import java.lang.annotation.*;

/**
 * 🔐 Role-Based Access Control Annotation
 * 
 * Use this on controller methods to restrict access by role
 * 
 * Example:
 * @RequireRole(Role.ADMIN)
 * public ResponseEntity<?> deleteUser() { ... }
 * 
 * @RequireRole({Role.VENDOR, Role.ADMIN})
 * public ResponseEntity<?> viewOrders() { ... }
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequireRole {
    Role[] value();
}
