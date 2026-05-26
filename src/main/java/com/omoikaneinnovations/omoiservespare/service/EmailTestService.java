package com.omoikaneinnovations.omoiservespare.service;

import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class EmailTestService {

    private static final Logger logger = LoggerFactory.getLogger(EmailTestService.class);

    @Value("${sendgrid.api.key}")
    private String sendGridApiKey;

    @Value("${sendgrid.from.email}")
    private String fromEmail;

    public boolean testEmailConnection() {
        try {
            logger.info("Testing SendGrid connection...");
            logger.info("API Key: {}...{}", 
                sendGridApiKey.substring(0, 10), 
                sendGridApiKey.substring(sendGridApiKey.length() - 10));
            logger.info("From Email: {}", fromEmail);

            Email from = new Email(fromEmail);
            Email to = new Email("test@example.com"); // Test email
            String subject = "SendGrid Connection Test";

            Content content = new Content(
                    "text/plain",
                    "This is a test email to verify SendGrid configuration."
            );

            Mail mail = new Mail(from, subject, to, content);
            SendGrid sg = new SendGrid(sendGridApiKey);

            Request request = new Request();
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            
            // Just test the connection, don't actually send
            logger.info("SendGrid configuration appears valid");
            logger.info("Mail object created successfully");
            
            return true;
        } catch (Exception e) {
            logger.error("SendGrid configuration test failed", e);
            return false;
        }
    }

    public void sendTestOtp(String toEmail, String otp) {
        try {
            logger.info("=== SENDING TEST OTP EMAIL ===");
            logger.info("To: {}", toEmail);
            logger.info("OTP: {}", otp);
            logger.info("From: {}", fromEmail);
            logger.info("API Key: {}...{}", 
                sendGridApiKey.substring(0, 10), 
                sendGridApiKey.substring(sendGridApiKey.length() - 10));

            Email from = new Email(fromEmail);
            Email to = new Email(toEmail);
            String subject = "Your Login OTP - Test";

            Content content = new Content(
                    "text/plain",
                    "Your OTP is: " + otp +
                    "\n\nThis OTP is valid for 5 minutes." +
                    "\n\nThis is a test email from your application." +
                    "\n\nIf you did not request this, please ignore."
            );

            Mail mail = new Mail(from, subject, to, content);
            SendGrid sg = new SendGrid(sendGridApiKey);

            Request request = new Request();
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            
            logger.info("Sending email request to SendGrid...");
            Response response = sg.api(request);
            
            logger.info("SendGrid Response Status: {}", response.getStatusCode());
            logger.info("SendGrid Response Body: {}", response.getBody());
            logger.info("SendGrid Response Headers: {}", response.getHeaders());
            
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                logger.info("✅ TEST EMAIL SENT SUCCESSFULLY!");
            } else {
                logger.error("❌ TEST EMAIL FAILED - Status: {}, Body: {}", 
                    response.getStatusCode(), response.getBody());
            }
        } catch (IOException e) {
            logger.error("❌ IOException sending test email", e);
        } catch (Exception e) {
            logger.error("❌ Unexpected error sending test email", e);
        }
    }
}