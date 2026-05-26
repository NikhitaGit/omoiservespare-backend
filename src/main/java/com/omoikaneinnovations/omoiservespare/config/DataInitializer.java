package com.omoikaneinnovations.omoiservespare.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @EventListener(ApplicationReadyEvent.class)
    public void init() {
        logger.info("Application started successfully!");
        logger.info("Users are validated through HR API integration");
        
        // ✅ REMOVED: Hardcoded sample users and signup functionality
        // Users are now pre-registered through HR system
        // Login validates credentials against HR API
    }

}
