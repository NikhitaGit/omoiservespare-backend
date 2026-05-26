package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:5174"})
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // ✅ GET CURRENT LOGGED-IN USER
    @GetMapping("/me")
    public User getProfile() {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        String email = authentication.getName();
        String accountType = (String) authentication.getDetails();

        System.out.println("📧 Extracted email from token: " + email);
        System.out.println("🏷️ Extracted accountType from token: " + accountType);

        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @GetMapping("/mode")
    public String getMode(Authentication auth) {

        String accountType = (String) auth.getDetails();
        return "Account type: " + accountType;
    }

}
