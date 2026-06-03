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

    @Value("${mail.from}")
    private String fromEmail;

    public boolean testEmailConnection() {

        try {

            log.info("SMTP configuration loaded successfully");
            log.info("From Email: {}", fromEmail);

            return true;

        } catch (Exception e) {

            log.error("SMTP configuration test failed", e);
            return false;
        }
    }

    public void sendTestOtp(String toEmail, String otp) {

        try {

            SimpleMailMessage message = new SimpleMailMessage();

            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject("Test OTP Email");

            message.setText(
                    "Your OTP is: " + otp +
                    "\n\nThis OTP is valid for 5 minutes." +
                    "\n\nThis is a test email."
            );

            mailSender.send(message);

            log.info("Test email sent successfully to {}", toEmail);

        } catch (Exception e) {

            log.error("Failed to send test email", e);
        }
    }
}