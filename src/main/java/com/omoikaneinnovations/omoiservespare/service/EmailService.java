package com.omoikaneinnovations.omoiservespare.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${mail.from}")
    private String fromEmail;

    @Async
    public void sendOtpEmail(String toEmail, String otp) {

        try {

            SimpleMailMessage message = new SimpleMailMessage();

            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject("Your Login OTP");

            message.setText(
                    "Your OTP is: " + otp +
                    "\n\nThis OTP is valid for 5 minutes." +
                    "\n\nIf you did not request this OTP, please ignore this email."
            );

            mailSender.send(message);

            log.info("OTP email sent successfully to {}", toEmail);

        } catch (Exception e) {

            log.error("Failed to send OTP email to {}", toEmail, e);

        }
    }
}