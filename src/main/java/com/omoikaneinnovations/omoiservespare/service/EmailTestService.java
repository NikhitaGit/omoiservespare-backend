package com.omoikaneinnovations.omoiservespare.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailTestService {

    private final JavaMailSender mailSender;
    private final EmailService emailService;

    @Value("${mail.from}")
    private String fromEmail;
    
    @Value("${spring.mail.host}")
    private String smtpHost;
    
    @Value("${spring.mail.port}")
    private int smtpPort;
    
    @Value("${spring.mail.username}")
    private String senderEmail;

    public boolean testEmailConnection() {

        try {
            log.info("========================================");
            log.info("🔍 EMAIL CONFIGURATION TEST");
            log.info("========================================");
            log.info("SMTP Host: {}", smtpHost);
            log.info("SMTP Port: {}", smtpPort);
            log.info("Sender Email: {}", senderEmail);
            log.info("From Email: {}", fromEmail);
            log.info("========================================");

            // Test by sending a simple email to verify SMTP works
            try {
                SimpleMailMessage testMessage = new SimpleMailMessage();
                testMessage.setFrom(fromEmail);
                testMessage.setTo(senderEmail); // Send to self
                testMessage.setSubject("SMTP Test");
                testMessage.setText("SMTP connection test successful");
                
                mailSender.send(testMessage);
                log.info("✅ SMTP Connection successful!");
                return true;
            } catch (Exception e) {
                log.error("❌ SMTP CONNECTION FAILED: {}", e.getMessage(), e);
                
                if (e.getMessage() != null) {
                    if (e.getMessage().contains("Authentication")) {
                        log.error("💡 FIX: Wrong username/password. Check SENDER_USERNAME and SENDER_PASSWORD");
                    } else if (e.getMessage().contains("Connection")) {
                        log.error("💡 FIX: Cannot connect to SMTP server. Check host and port");
                    }
                }
                return false;
            }

        } catch (Exception e) {

            log.error("SMTP configuration test failed", e);
            return false;
        }
    }

    public void sendTestOtp(String toEmail, String otp) {

        try {
            log.info("========================================");
            log.info("📧 SENDING TEST OTP VIA FULL EMAIL SERVICE");
            log.info("Recipient: {}", toEmail);
            log.info("OTP: {}", otp);
            log.info("========================================");

            // Use the full EmailService (HTML email)
            emailService.sendOtpEmail(toEmail, otp);

            log.info("========================================");
            log.info("✅ TEST EMAIL SENT SUCCESSFULLY");
            log.info("========================================");

        } catch (Exception e) {

            log.error("========================================");
            log.error("❌ TEST EMAIL FAILED");
            log.error("Error: {}", e.getMessage());
            log.error("========================================");
            log.error("Full stack trace:", e);
            throw e;
        }
    }
}