package com.omoikaneinnovations.omoiservespare.service;

import com.sendgrid.*;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Slf4j
@Service
public class EmailService {

    @Value("${sendgrid.api.key}")
    private String sendGridApiKey;
    
    @Value("${sendgrid.from.email}")
    private String fromEmail;
    
    @Value("${sendgrid.from.name:OmoiServespare}")
    private String fromName;

    @Async
    @Retryable(
        maxAttempts = 3,
        backoff = @Backoff(delay = 2000, multiplier = 2)
    )
    public void sendOtp(String to, String otp) {
        try {
            log.info("Sending OTP email to: {}", to);
            
            Email from = new Email(fromEmail, fromName);
            Email toEmail = new Email(to);
            String subject = "Your Login OTP - Secure Authentication";
            
            // Create HTML content
            String htmlContent = buildOtpEmailHtml(otp);
            Content content = new Content("text/html", htmlContent);
            
            Mail mail = new Mail(from, subject, toEmail, content);
            
            SendGrid sg = new SendGrid(sendGridApiKey);
            Request request = new Request();
            
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            
            Response response = sg.api(request);
            
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                log.info("OTP email sent successfully to: {}. Status: {}", to, response.getStatusCode());
            } else {
                log.error("Failed to send OTP email. Status: {}, Body: {}", 
                    response.getStatusCode(), response.getBody());
                throw new RuntimeException("SendGrid returned non-success status: " + response.getStatusCode());
            }
            
        } catch (IOException e) {
            log.error("Error sending OTP email to {}: {}", to, e.getMessage(), e);
            throw new RuntimeException("Failed to send OTP email", e);
        }
    }
    
    private String buildOtpEmailHtml(String otp) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Your OTP Code</title>
            </head>
            <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
                <table role="presentation" style="width: 100%%; border-collapse: collapse;">
                    <tr>
                        <td align="center" style="padding: 40px 0;">
                            <table role="presentation" style="width: 600px; border-collapse: collapse; background-color: #ffffff; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                                <!-- Header -->
                                <tr>
                                    <td style="padding: 40px 30px; background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); text-align: center;">
                                        <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 600;">🔐 Secure Login</h1>
                                    </td>
                                </tr>
                                
                                <!-- Content -->
                                <tr>
                                    <td style="padding: 40px 30px;">
                                        <p style="margin: 0 0 20px; color: #333333; font-size: 16px; line-height: 1.5;">
                                            Hello,
                                        </p>
                                        <p style="margin: 0 0 30px; color: #333333; font-size: 16px; line-height: 1.5;">
                                            Your One-Time Password (OTP) for secure authentication is:
                                        </p>
                                        
                                        <!-- OTP Box -->
                                        <div style="background-color: #f8f9fa; border: 2px dashed #667eea; border-radius: 8px; padding: 25px; text-align: center; margin: 30px 0;">
                                            <div style="font-size: 36px; font-weight: bold; color: #667eea; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                                                %s
                                            </div>
                                        </div>
                                        
                                        <p style="margin: 30px 0 20px; color: #333333; font-size: 16px; line-height: 1.5;">
                                            ⏰ <strong>This OTP is valid for 10 minutes.</strong>
                                        </p>
                                        
                                        <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
                                            <p style="margin: 0; color: #856404; font-size: 14px;">
                                                <strong>⚠️ Security Notice:</strong> Never share this OTP with anyone. Our team will never ask for your OTP.
                                            </p>
                                        </div>
                                        
                                        <p style="margin: 30px 0 0; color: #666666; font-size: 14px; line-height: 1.5;">
                                            If you didn't request this OTP, please ignore this email or contact support immediately.
                                        </p>
                                    </td>
                                </tr>
                                
                                <!-- Footer -->
                                <tr>
                                    <td style="padding: 30px; background-color: #f8f9fa; text-align: center; border-top: 1px solid #e9ecef;">
                                        <p style="margin: 0 0 10px; color: #666666; font-size: 14px;">
                                            Best regards,<br>
                                            <strong>OmoiServespare Team</strong>
                                        </p>
                                        <p style="margin: 10px 0 0; color: #999999; font-size: 12px;">
                                            © 2026 OmoiServespare. All rights reserved.
                                        </p>
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
}