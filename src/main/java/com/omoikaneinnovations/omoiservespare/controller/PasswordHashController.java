package com.omoikaneinnovations.omoiservespare.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Utility controller for generating password hashes
 * FOR DEVELOPMENT USE ONLY - Remove in production
 */
@RestController
@RequestMapping("/api/util")
@RequiredArgsConstructor
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:5174"})
public class PasswordHashController {
    
    private final PasswordEncoder passwordEncoder;
    
    @PostMapping("/hash-password")
    public ResponseEntity<Map<String, String>> hashPassword(@RequestBody Map<String, String> request) {
        String password = request.get("password");
        String hash = passwordEncoder.encode(password);
        
        return ResponseEntity.ok(Map.of(
                "password", password,
                "hash", hash,
                "length", String.valueOf(hash.length())
        ));
    }
    
    @PostMapping("/verify-password")
    public ResponseEntity<Map<String, Object>> verifyPassword(@RequestBody Map<String, String> request) {
        String password = request.get("password");
        String hash = request.get("hash");
        
        boolean matches = passwordEncoder.matches(password, hash);
        
        return ResponseEntity.ok(Map.of(
                "password", password,
                "hash", hash,
                "matches", matches
        ));
    }
}
