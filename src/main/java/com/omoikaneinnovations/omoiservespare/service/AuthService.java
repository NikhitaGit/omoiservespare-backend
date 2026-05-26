package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.domain.AccountType;
import com.omoikaneinnovations.omoiservespare.dto.HREmployeeDTO;
import com.omoikaneinnovations.omoiservespare.dto.LoginResponse;
import com.omoikaneinnovations.omoiservespare.entity.Otp;
import com.omoikaneinnovations.omoiservespare.entity.RefreshToken;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.OtpRepository;
import com.omoikaneinnovations.omoiservespare.repository.RefreshTokenRepository;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.security.JwtUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final OtpRepository otpRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final EmailService emailService;
    private final SmsService smsService;
    private final JwtUtil jwtUtil;
    private final HRApiService hrApiService;

    public AuthService(
            UserRepository userRepository,
            OtpRepository otpRepository,
            RefreshTokenRepository refreshTokenRepository,
            EmailService emailService,
            SmsService smsService,
            JwtUtil jwtUtil,
            HRApiService hrApiService) {

        this.userRepository = userRepository;
        this.otpRepository = otpRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.emailService = emailService;
        this.smsService = smsService;
        this.jwtUtil = jwtUtil;
        this.hrApiService = hrApiService;
    }

    /*
     * ===============================
     * LOGIN → VALIDATE WITH HR & SEND OTP
     * ===============================
     */
    public boolean validateLogin(
            String companyName,
            String email,
            String phoneNumber,
            AccountType accountType) {

        logger.info("=== LOGIN VALIDATION START ===");
        logger.info("Company: {}", companyName);
        logger.info("Email: {}", email);
        logger.info("Phone: {}", phoneNumber);
        logger.info("Account Type: {}", accountType);

        // Step 1: Validate company exists in HR system
        logger.info("Step 1: Validating company in HR system...");
        if (!hrApiService.validateCompany(companyName)) {
            logger.warn("Company validation FAILED for: {}", companyName);
            return false;
        }
        logger.info("Company validation PASSED for: {}", companyName);

        // Step 2: Fetch employee data from HR system
        HREmployeeDTO hrEmployee = null;
        
        // Try to find by email first
        if (email != null && !email.trim().isEmpty()) {
            logger.info("Step 2a: Looking up employee by email...");
            Optional<HREmployeeDTO> hrEmployeeOpt = hrApiService.getEmployeeByEmail(email.trim());
            if (hrEmployeeOpt.isPresent()) {
                hrEmployee = hrEmployeeOpt.get();
                logger.info("Employee found by email: {}", email);
            } else {
                logger.warn("Employee NOT found by email: {}", email);
            }
        }
        
        // If not found by email, try phone number
        if (hrEmployee == null && phoneNumber != null && !phoneNumber.trim().isEmpty()) {
            logger.info("Step 2b: Looking up employee by phone...");
            Optional<HREmployeeDTO> hrEmployeeOpt = hrApiService.getEmployeeByPhone(phoneNumber.trim());
            if (hrEmployeeOpt.isPresent()) {
                hrEmployee = hrEmployeeOpt.get();
                logger.info("Employee found by phone: {}", phoneNumber);
            } else {
                logger.warn("Employee NOT found by phone: {}", phoneNumber);
            }
        }

        // Step 3: Validate employee exists in HR system
        if (hrEmployee == null) {
            logger.error("VALIDATION FAILED: Employee not found in HR system for email: {} or phone: {}", email, phoneNumber);
            return false;
        }
        logger.info("Step 3: Employee found in HR system: {}", hrEmployee.getEmail());

        // Step 4: Validate employee is active
        if (!"active".equalsIgnoreCase(hrEmployee.getStatus())) {
            logger.warn("VALIDATION FAILED: Employee is not active: {} (status: {})", hrEmployee.getEmail(), hrEmployee.getStatus());
            return false;
        }
        logger.info("Step 4: Employee is active");

        // Step 5: Create or update user in local database
        logger.info("Step 5: Creating/updating user in local database...");
        User user = userRepository.findByEmail(hrEmployee.getEmail())
                .orElse(new User());

        // Map HR data to local user
        user.setEmail(hrEmployee.getEmail());
        user.setCompanyName(hrEmployee.getCompanyName() != null ? hrEmployee.getCompanyName() : companyName);
        user.setPhoneNumber(hrEmployee.getPhoneNumber());
        
        // Map job title to account type
        if (hrEmployee.getJobTitle() != null && 
            (hrEmployee.getJobTitle().toLowerCase().contains("manager") ||
             hrEmployee.getJobTitle().toLowerCase().contains("lead") ||
             hrEmployee.getJobTitle().toLowerCase().contains("director"))) {
            user.setAccountType(AccountType.PROFESSIONAL);
        } else {
            user.setAccountType(accountType != null ? accountType : AccountType.PROFESSIONAL);
        }

        // Save user to local database
        userRepository.save(user);
        logger.info("User created/updated in local database: {}", user.getEmail());

        // Step 6: Generate and send OTP
        logger.info("Step 6: Generating and sending OTP...");
        generateAndSendOtp(hrEmployee.getEmail(), hrEmployee.getPhoneNumber());

        logger.info("=== LOGIN VALIDATION SUCCESS ===");
        return true;
    }

    @Transactional
    public void generateAndSendOtp(String email, String phoneNumber) {

        otpRepository.deleteByEmail(email);

        String otpValue = generateOtp();

        Otp otp = new Otp();
        otp.setEmail(email);
        otp.setOtp(otpValue);
        otp.setExpiresAt(LocalDateTime.now().plusMinutes(5));

        otpRepository.save(otp);

        // 🔥 LOG OTP FOR DEVELOPMENT/TESTING
        System.out.println("===========================================");
        System.out.println("🔐 OTP GENERATED FOR: " + email);
        System.out.println("📧 OTP CODE: " + otpValue);
        System.out.println("⏰ EXPIRES AT: " + otp.getExpiresAt());
        System.out.println("===========================================");

        // Send email asynchronously (won't block)
        emailService.sendOtpEmail(email, otpValue);

        // Send SMS asynchronously (won't block)
        if (phoneNumber != null && !phoneNumber.isBlank()) {
            smsService.sendOtpSms(phoneNumber, otpValue);
        }
    }

    @Transactional
    public boolean verifyOtp(String email, String otpValue) {

        Optional<Otp> otpOpt = otpRepository.findByEmailAndOtp(email, otpValue);

        if (otpOpt.isEmpty()) {
            return false;
        }

        Otp otp = otpOpt.get();

        if (otp.getExpiresAt().isBefore(LocalDateTime.now())) {
            return false;
        }

        otpRepository.deleteByEmail(email);
        return true;
    }

    private String generateOtp() {
        int otp = 1000 + new java.security.SecureRandom().nextInt(9000);
        return String.valueOf(otp);
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }

    /*
     * ===============================
     * LOGIN SUCCESS → ISSUE TOKENS
     * ===============================
     */
    @Transactional
    public LoginResponse loginSuccess(
            User user,
            String deviceId,
            HttpServletResponse response) {

        // 🔐 ACCESS TOKEN WITH ROLE (RBAC ENABLED)
        String accessToken = jwtUtil.generateTokenWithRole(
                user.getEmail(),
                user.getRole() != null ? user.getRole().name() : "USER",
                user.getAccountType());

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken(jwtUtil.generateRefreshToken());
        refreshToken.setUser(user);
        refreshToken.setDeviceId(deviceId);
        refreshToken.setExpiresAt(LocalDateTime.now().plusDays(7));
        refreshToken.setRevoked(false);
        refreshToken.setLastUsedAt(LocalDateTime.now());

        refreshTokenRepository.save(refreshToken);
        
        // 🔒 SECURE: Set both tokens as httpOnly cookies
        setAccessTokenCookie(response, accessToken);
        setRefreshCookie(response, refreshToken.getToken());

        // ✅ Return token in response body AND set as cookie for compatibility
        return new LoginResponse(
            true, 
            "Login successful", 
            accessToken,
            user.getEmail(),
            user.getCompanyName(),
            user.getPhoneNumber(),
            user.getAccountType()
        );
    }
    
    /*
     * ===============================
     * SET ACCESS TOKEN AS HTTPONLY COOKIE
     * ===============================
     */
    private void setAccessTokenCookie(HttpServletResponse response, String token) {
        Cookie cookie = new Cookie("accessToken", token);
        cookie.setHttpOnly(true);  // 🔒 Cannot be accessed by JavaScript
        cookie.setSecure(false);   // Set to true in production with HTTPS
        cookie.setPath("/");
        cookie.setMaxAge(15 * 60); // 15 minutes
        cookie.setAttribute("SameSite", "Lax"); // CSRF protection
        response.addCookie(cookie);
        
        logger.info("Access token set as httpOnly cookie");
    }

    /*
     * ===============================
     * REFRESH ACCESS TOKEN
     * ===============================
     */
    @Transactional
    public LoginResponse refreshAccessToken(
            String refreshTokenValue,
            String deviceId,
            HttpServletResponse response) {

        RefreshToken token = refreshTokenRepository
                .findByToken(refreshTokenValue)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Invalid refresh token"));

        // 🚨 REUSE DETECTION
        if (token.isRevoked()) {
            refreshTokenRepository.revokeAllByUser(token.getUser());
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Token reuse detected");
        }

        // 🚨 DEVICE MISMATCH
        if (!token.getDeviceId().equals(deviceId)) {
            refreshTokenRepository.revokeAllByUser(token.getUser());
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Device mismatch");
        }

        // 🚨 EXPIRY CHECK
        if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Refresh token expired");
        }

        // 🔁 ROTATE REFRESH TOKEN
        token.setRevoked(true);
        refreshTokenRepository.save(token);

        RefreshToken newToken = new RefreshToken();
        newToken.setToken(jwtUtil.generateRefreshToken());
        newToken.setUser(token.getUser());
        newToken.setDeviceId(deviceId);
        newToken.setExpiresAt(LocalDateTime.now().plusDays(7));
        newToken.setRevoked(false);
        newToken.setLastUsedAt(LocalDateTime.now());

        refreshTokenRepository.save(newToken);
        setRefreshCookie(response, newToken.getToken());

        // 🔐 NEW ACCESS TOKEN WITH ROLE (RBAC ENABLED)
        String newAccessToken = jwtUtil.generateTokenWithRole(
                token.getUser().getEmail(),
                token.getUser().getRole() != null ? token.getUser().getRole().name() : "USER",
                token.getUser().getAccountType());

        return new LoginResponse(true, "Token refreshed", newAccessToken);
    }

    /*
     * ===============================
     * REFRESH COOKIE
     * ===============================
     */
    private void setRefreshCookie(HttpServletResponse response, String token) {

        Cookie cookie = new Cookie("refreshToken", token);
        cookie.setHttpOnly(true);
        cookie.setSecure(false); // 🔒 true in production (HTTPS)
        cookie.setPath("/api/auth/refresh");
        cookie.setMaxAge(30 * 24 * 60 * 60);

        response.addCookie(cookie);
    }
}
