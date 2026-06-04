package com.omoikaneinnovations.omoiservespare.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class MailTestController {

    private final JavaMailSender mailSender;

    @GetMapping("/mail-test")
    public String mailTest() {

        try {

            SimpleMailMessage msg = new SimpleMailMessage();

            msg.setTo("nikita.a@omoikaneinnovations.com");
            msg.setSubject("SMTP Test");
            msg.setText("Testing email from Render");

            mailSender.send(msg);

            return "Mail sent successfully";

        } catch (Exception e) {

            e.printStackTrace();

            return "Mail failed: " + e.getMessage();
        }
    }
}