package com.omoikaneinnovations.omoiservespare.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.omoikaneinnovations.omoiservespare.domain.AccountType;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtUtil {

    /**
     * 🔐 JWT Secret from application.properties / Render env
     */
    @Value("${jwt.secret}")
    private String secretKey;

    /**
     * ⏱ Access token validity
     */
    private static final long ACCESS_TOKEN_EXPIRATION = 1000L * 60 * 60 * 24; // 24 hours

    /*
     * =========================
     * GET SIGNING KEY
     * =========================
     */
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    /*
     * =========================
     * GENERATE ACCESS TOKEN
     * =========================
     */
    public String generateToken(String email, AccountType accountType) {

        return Jwts.builder()
                .setSubject(email)
                .claim("accountType", accountType)
                .setIssuedAt(new Date())
                .setExpiration(
                        new Date(System.currentTimeMillis() + ACCESS_TOKEN_EXPIRATION))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * 🔐 Generate token with role (RBAC)
     */
    public String generateTokenWithRole(String email, String role, AccountType accountType) {
        return Jwts.builder()
                .setSubject(email)
                .claim("role", role)
                .claim("accountType", accountType)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_EXPIRATION))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /*
     * =========================
     * EXTRACT EMAIL
     * =========================
     */
    public String extractEmail(String token) {
        return getClaims(token).getSubject();
    }

    /*
     * =========================
     * EXTRACT ROLE
     * =========================
     */

    public String extractAccountType(String token) {
        return getClaims(token).get("accountType", String.class);
    }

    /**
     * Extract role from token (RBAC)
     */
    public String extractRole(String token) {
        return getClaims(token).get("role", String.class);
    }

    /*
     * =========================
     * VALIDATE TOKEN
     * =========================
     */
    public boolean validateToken(String token) {
        try {
            getClaims(token); // verifies signature + expiry
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    /*
     * =========================
     * PARSE CLAIMS
     * =========================
     */
    private Claims getClaims(String token) {

        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    /*
     * =========================
     * REFRESH TOKEN
     * =========================
     */
    public String generateRefreshToken() {
        return UUID.randomUUID().toString();
    }
}