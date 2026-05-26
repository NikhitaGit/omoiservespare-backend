package com.omoikaneinnovations.omoiservespare.config;

import org.flywaydb.core.Flyway;
import org.springframework.boot.autoconfigure.flyway.FlywayMigrationStrategy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Flyway Repair Configuration
 * Automatically repairs failed migrations on startup
 */
@Configuration
public class FlywayRepairConfig {

    @Bean
    public FlywayMigrationStrategy repairStrategy() {
        return flyway -> {
            // Repair any failed migrations
            flyway.repair();
            // Then run migrations
            flyway.migrate();
        };
    }
}
