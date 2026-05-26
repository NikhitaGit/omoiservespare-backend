package com.omoikaneinnovations.omoiservespare.security;

import java.lang.annotation.*;

/**
 * 🏪 Vendor Approval Check Annotation
 * 
 * Use this on vendor endpoints to ensure vendor is APPROVED
 * 
 * Example:
 * @RequireRole(Role.VENDOR)
 * @RequireVendorApproval
 * public ResponseEntity<?> updateMenu() { ... }
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequireVendorApproval {
}
