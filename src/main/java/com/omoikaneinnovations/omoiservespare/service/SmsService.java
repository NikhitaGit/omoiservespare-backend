package com.omoikaneinnovations.omoiservespare.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class SmsService {

    private static final Logger logger = LoggerFactory.getLogger(SmsService.class);

    @Value("${twilio.account.sid}")
    private String accountSid;

    @Value("${twilio.auth.token}")
    private String authToken;

    @Value("${twilio.phone.number}")
    private String fromNumber;

    @Async
    public void sendOtpSms(String toPhoneNumber, String otp) {
        try {
            logger.info("Sending SMS OTP to: {}", toPhoneNumber);

            Twilio.init(accountSid, authToken);

            Message message = Message.creator(
                    new PhoneNumber(toPhoneNumber),
                    new PhoneNumber(fromNumber),
                    "Your OTP is: " + otp + ". Valid for 5 minutes."
            ).create();

            logger.info("SMS sent successfully. SID: {}", message.getSid());
        } catch (Exception e) {
            logger.error("Failed to send SMS to: " + toPhoneNumber, e);
            // Don't throw - allow login to continue even if SMS fails
        }
    }
}
