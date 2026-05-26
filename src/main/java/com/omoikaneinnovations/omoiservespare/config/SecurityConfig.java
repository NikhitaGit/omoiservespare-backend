package com.omoikaneinnovations.omoiservespare.config;

import com.omoikaneinnovations.omoiservespare.security.JwtAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

        private final JwtAuthFilter jwtAuthFilter;

        public SecurityConfig(JwtAuthFilter jwtAuthFilter) {
                this.jwtAuthFilter = jwtAuthFilter;
        }

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

                http
                                // ✅ REQUIRED for Spring Security 6
                                .cors(Customizer.withDefaults())

                                .csrf(csrf -> csrf.disable())

                                .exceptionHandling(ex -> ex
                                                .authenticationEntryPoint((request, response, authException) -> {
                                                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 🔥
                                                                                                                 // FORCE
                                                                                                                 // 401
                                                }))

                                .authorizeHttpRequests(auth -> auth
                                                // 🔓 PUBLIC APIs
                                                .requestMatchers(
                                                                "/api/auth/**",
                                                                "/api/canteens/**",
                                                                "/api/menu/**",
                                                                "/api/helpdesk/init",
                                                                "/api/helpdesk/status",
                                                                "/api/kafka/**",
                                                                "/api/vendor/register",
                                                                "/api/vendor/status/**",
                                                                "/api/admin/create-first",
                                                                "/api/util/**") // Add utility endpoints
                                                .permitAll()

                                                // 🔒 everything else requires JWT
                                                .anyRequest().authenticated())

                                // 🔐 JWT filter
                                .addFilterBefore(
                                                jwtAuthFilter,
                                                UsernamePasswordAuthenticationFilter.class);

                return http.build();
        }

        @Bean
        public CorsConfigurationSource corsConfigurationSource() {

                CorsConfiguration config = new CorsConfiguration();

                config.setAllowedOrigins(List.of("http://localhost:5173", "http://localhost:5174"));
                config.setAllowedMethods(List.of(
                                "GET",
                                "POST",
                                "PUT",
                                "DELETE",
                                "OPTIONS"));

                // 🔥 CRITICAL: allow custom headers (case-insensitive)
                config.setAllowedHeaders(List.of(
                                "authorization",
                                "content-type",
                                "x-device-id"));

                config.setAllowCredentials(true);
                config.setMaxAge(3600L);

                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();

                source.registerCorsConfiguration("/**", config);
                return source;
        }

        @Bean
        public PasswordEncoder passwordEncoder() {
                return new BCryptPasswordEncoder();
        }
}
