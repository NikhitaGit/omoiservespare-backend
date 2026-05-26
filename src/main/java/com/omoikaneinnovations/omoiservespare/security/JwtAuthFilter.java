package com.omoikaneinnovations.omoiservespare.security;

import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Optional;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthFilter.class);
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    public JwtAuthFilter(JwtUtil jwtUtil, UserRepository userRepository) {
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();

        return path.startsWith("/api/auth")
                || path.startsWith("/api/canteens")
                || path.startsWith("/api/menu");
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        String token = null;

        // 🔒 SECURE: Try to get token from httpOnly cookie first
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("accessToken".equals(cookie.getName())) {
                    token = cookie.getValue();
                    logger.debug("Token found in httpOnly cookie");
                    break;
                }
            }
        }

        // 🔄 FALLBACK: Support Authorization header for backward compatibility (temporary)
        if (token == null) {
            String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                token = authHeader.substring(7);
                logger.debug("Token found in Authorization header (fallback)");
            }
        }

        // No token found
        if (token == null) {
            filterChain.doFilter(request, response);
            return;
        }

        // Validate token
        if (!jwtUtil.validateToken(token)) {
            logger.warn("Invalid token");
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        // 🔑 Extract values from JWT
        String email = jwtUtil.extractEmail(token);
        String accountType = jwtUtil.extractAccountType(token);

        logger.debug("Authenticated user: {} with account type: {}", email, accountType);

        // 🔍 Fetch User entity from database (CRITICAL for SecurityUtils)
        Optional<User> userOptional = userRepository.findByEmail(email);
        if (userOptional.isEmpty()) {
            logger.warn("User not found in database: {}", email);
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        User user = userOptional.get();
        
        // ✅ Set currentUser attribute for SecurityUtils (CRITICAL FIX)
        request.setAttribute("currentUser", user);
        logger.debug("Set currentUser attribute: userId={}, email={}", user.getId(), user.getEmail());

        // 🔐 Create authentication WITHOUT authorities
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                email,
                null,
                null // no roles / authorities
        );

        // 👇 Attach accountType for business logic usage
        authentication.setDetails(accountType);

        SecurityContextHolder
                .getContext()
                .setAuthentication(authentication);

        filterChain.doFilter(request, response);
    }
}
