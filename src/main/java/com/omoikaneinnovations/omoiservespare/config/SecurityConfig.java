package com.omoikaneinnovations.omoiservespare.config;

import com.omoikaneinnovations.omoiservespare.security.JwtAuthFilter;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
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

                // ✅ Enable CORS
                .cors(Customizer.withDefaults())

                // ✅ Disable CSRF for JWT authentication
                .csrf(csrf -> csrf.disable())

                // ✅ Handle unauthorized access
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint((request, response, authException) -> {
                            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        }))

                // ✅ API authorization rules
                .authorizeHttpRequests(auth -> auth

                        // 🔓 Public APIs
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
                                "/api/util/**"
                        ).permitAll()

                        // 🔒 Protected APIs (requires authentication)
                        .anyRequest().authenticated())

                // ✅ JWT Filter
                .addFilterBefore(
                        jwtAuthFilter,
                        UsernamePasswordAuthenticationFilter.class
                );

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {

        CorsConfiguration config = new CorsConfiguration();

        // ✅ Frontend URLs allowed to access backend
        config.setAllowedOrigins(List.of(
                "https://lata-frontend-flame.vercel.app",
                "https://lata-frontend-git-main-omoi-servespare-s-projects.vercel.app",
                "http://localhost:5173",
                "http://localhost:5174",
                "http://localhost:3000"
        ));

        // ✅ Allowed HTTP methods
        config.setAllowedMethods(List.of(
                "GET",
                "POST",
                "PUT",
                "DELETE",
                "PATCH",
                "OPTIONS"
        ));

        // ✅ Allowed headers
        config.setAllowedHeaders(List.of(
                "Authorization",
                "Content-Type",
                "X-Device-Id",
                "Accept",
                "Origin"
        ));

        // ✅ Allow credentials (JWT/cookies)
        config.setAllowCredentials(true);

        // ✅ Cache preflight response
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();

        source.registerCorsConfiguration("/**", config);

        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}