package com.omoikaneinnovations.omoiservespare.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;

    @Value("${email.from.address}")
    private String fromAddress;

    @Value("${email.from.name}")
    private String fromName;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    /**
     * Send OTP email to user
     * 
     * @param toEmail User's email address
     * @param otp Generated OTP code
     */


    public void sendOtpEmail(String toEmail, String otp) {
        try {
            log.info("📧 Sending OTP email to: {}", toEmail);
            
            log.info("SMTP USERNAME: {}", fromAddress);
log.info("FROM NAME: {}", fromName);

log.info("JavaMailSender class: {}", mailSender.getClass().getName());

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromAddress, fromName);
            helper.setTo(toEmail);
            helper.setSubject("Your OTP Code - OmoiServeSpare");
            helper.setText(buildOtpEmailHtml(otp), true); // true = HTML
            
            log.info("SMTP Host: {}", "smtp.gmail.com");
            log.info("SMTP Username Loaded: {}", System.getenv("SENDER_USERNAME") != null);
log.info("SMTP Password Loaded: {}", System.getenv("SENDER_PASSWORD") != null);
log.info("From Address: {}", fromAddress);
log.info("From Name: {}", fromName);
            mailSender.send(message);
            
            log.info("✅ OTP email sent successfully to: {}", toEmail);
            
        } catch (MessagingException e) {
            log.error("❌ Failed to send OTP email to: {}", toEmail, e);
            // Fallback: Log OTP to console in case of email failure
            log.warn("========================================");
            log.warn("  FALLBACK OTP for {}: {}", toEmail, otp);
            log.warn("========================================");
            throw new RuntimeException("Failed to send OTP email", e);
        } catch (Exception e) {
            log.error("❌ Unexpected error sending OTP email to: {}", toEmail, e);
            // Fallback: Log OTP to console
            log.warn("========================================");
            log.warn("  FALLBACK OTP for {}: {}", toEmail, otp);
            log.warn("========================================");
            // throw new RuntimeException("Failed to send OTP email", e);
            return;
        }
    }

    /**
     * Build professional HTML email template for OTP
     * 
     * @param otp The OTP code to display
     * @return HTML email content
     */
    private String buildOtpEmailHtml(String otp) {
        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Your OTP Code</title>
            </head>
            <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
                <table width="100%%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4; padding: 20px;">
                    <tr>
                        <td align="center">
                            <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                
                                <!-- Header -->
                                <tr>
                                    <td style="background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); padding: 40px 20px; text-align: center;">
                                        <h1 style="margin: 0; color: #06c9ffff; font-size: 28px; font-weight: bold;">
                                            🍽️ OmoiServeSpare
                                        </h1>
                                        <p style="margin: 10px 0 0 0; color: #0cbcd0ff; font-size: 14px; opacity: 0.9;">
                                            Your Food Ordering Platform
                                        </p>
                                    </td>
                                </tr>
                                
                                <!-- Content -->
                                <tr>
                                    <td style="padding: 40px 30px;">
                                        <h2 style="margin: 0 0 20px 0; color: #333333; font-size: 24px; text-align: center;">
                                            Verify Your Email
                                        </h2>
                                        
                                        <p style="margin: 0 0 30px 0; color: #666666; font-size: 16px; line-height: 1.5; text-align: center;">
                                            Use the following One-Time Password (OTP) to complete your login:
                                        </p>
                                        
                                        <!-- OTP Box -->
                                        <div style="background: linear-gradient(135deg, #4CAF50 0%%, #2196F3 100%%); border: 3px solid #1976D2; border-radius: 12px; padding: 30px; text-align: center; margin: 0 0 30px 0; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
                                            <div style="font-size: 48px; font-weight: bold; color: #FFFFFF; letter-spacing: 12px; font-family: 'Courier New', monospace; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); background-color: rgba(0,0,0,0.2); padding: 20px; border-radius: 8px; display: inline-block;">
                                                %s
                                            </div>
                                        </div>
                                        
                                        <!-- Warning -->
                                        <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 0 0 20px 0; border-radius: 4px;">
                                            <p style="margin: 0; color: #856404; font-size: 14px; line-height: 1.5;">
                                                ⚠️ <strong>Security Notice:</strong> This OTP is valid for <strong>5 minutes</strong> only. Do not share this code with anyone.
                                            </p>
                                        </div>
                                        
                                        <p style="margin: 0 0 20px 0; color: #666666; font-size: 14px; line-height: 1.5; text-align: center;">
                                            If you didn't request this OTP, please ignore this email or contact our support team.
                                        </p>
                                        
                                        <!-- Button -->
                                        <div style="text-align: center; margin: 30px 0;">
                                            <a href="#" style="display: inline-block; padding: 12px 30px; background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); color: #ffffff; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px;">
                                                Return to App
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                
                                <!-- Footer -->
                                <tr>
                                    <td style="background-color: #cb00f8ff; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
                                        <p style="margin: 0 0 10px 0; color: #6c757d; font-size: 14px;">
                                            <strong>OmoiServeSpare</strong> - Your Campus Food Ordering Platform
                                        </p>
                                        <p style="margin: 0 0 10px 0; color: #6c757d; font-size: 12px;">
                                            📧 support@omoiservespare.com | 📱 +91 1234567890
                                        </p>
                                        <p style="margin: 0; color: #adb5bd; font-size: 11px;">
                                            © 2026 OmoiServeSpare. All rights reserved.
                                        </p>
                                        <div style="margin-top: 15px;">
                                            <a href="#" style="color: #6c757d; text-decoration: none; margin: 0 10px; font-size: 12px;">Privacy Policy</a>
                                            <a href="#" style="color: #6c757d; text-decoration: none; margin: 0 10px; font-size: 12px;">Terms of Service</a>
                                            <a href="#" style="color: #6c757d; text-decoration: none; margin: 0 10px; font-size: 12px;">Help Center</a>
                                        </div>
                                    </td>
                                </tr>
                                
                            </table>
                        </td>
                    </tr>
                </table>
            </body>
            </html>
            """.formatted(otp);
    }

    /**
     * Send a generic email (for future use)
     * 
     * @param toEmail Recipient email
     * @param subject Email subject
     * @param body Email body (HTML)
     */
    public void sendEmail(String toEmail, String subject, String body) {
        try {
            log.info("📧 Sending email to: {}, Subject: {}", toEmail, subject);
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromAddress, fromName);
            helper.setTo(toEmail);
            helper.setSubject(subject);
            helper.setText(body, true); // true = HTML
            
            mailSender.send(message);
            
            log.info("✅ Email sent successfully to: {}", toEmail);
            
        } catch (Exception e) {
            log.error("❌ Failed to send email to: {}", toEmail, e);
            throw new RuntimeException("Failed to send email", e);
        }
    }
}
