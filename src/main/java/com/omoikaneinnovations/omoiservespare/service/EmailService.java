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
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    @Value("${sendgrid.api.key}")
    private String sendGridApiKey;

    @Value("${sendgrid.from.email}")
    private String fromEmail;

    @Value("${sendgrid.enabled:true}")
    private boolean sendGridEnabled;

    @Async
    public void sendOtpEmail(String toEmail, String otp) {
        if (!sendGridEnabled) {
            logger.info("SendGrid is disabled. OTP email NOT sent to: {}", toEmail);
            logger.info("Use the OTP from console output to complete login");
            return;
        }

        try {
            logger.info("Sending OTP email to: {}", toEmail);

            Email from = new Email(fromEmail);
            Email to = new Email(toEmail);
            String subject = "Your Login OTP";

            Content content = new Content(
                    "text/plain",
                    "Your OTP is: " + otp +
                    "\n\nThis OTP is valid for 5 minutes." +
                    "\n\nIf you did not request this, please ignore."
            );

            Mail mail = new Mail(from, subject, to, content);
            SendGrid sg = new SendGrid(sendGridApiKey);

            Request request = new Request();
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            
            Response response = sg.api(request);
            
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                logger.info("OTP email sent successfully to: {}", toEmail);
            } else {
                logger.error("Failed to send OTP email. Status: {}, Body: {}", 
                    response.getStatusCode(), response.getBody());
            }
        } catch (IOException e) {
            logger.error("Failed to send OTP email to: " + toEmail, e);
            // Don't throw - allow login to continue even if email fails
        } catch (Exception e) {
            logger.error("Unexpected error sending OTP email to: " + toEmail, e);
        }
    }
}
