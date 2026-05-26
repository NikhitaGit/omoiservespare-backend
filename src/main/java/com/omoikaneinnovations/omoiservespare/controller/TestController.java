package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.service.EmailTestService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/test")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:5174"}, allowCredentials = "true")
public class TestController {

    private final EmailTestService emailTestService;

    public TestController(EmailTestService emailTestService) {
        this.emailTestService = emailTestService;
    }

    @GetMapping("/email-config")
    public ResponseEntity<String> testEmailConfig() {
        boolean isValid = emailTestService.testEmailConnection();
        if (isValid) {
            return ResponseEntity.ok("SendGrid configuration is valid");
        } else {
            return ResponseEntity.badRequest().body("SendGrid configuration failed");
        }
    }

    @PostMapping("/send-otp")
    public ResponseEntity<String> testSendOtp(@RequestParam String email, @RequestParam String otp) {
        emailTestService.sendTestOtp(email, otp);
        return ResponseEntity.ok("Test OTP sent - check logs for details");
    }
}