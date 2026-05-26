package com.omoikaneinnovations.omoiservespare.config;

import org.flywaydb.core.Flyway;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class FlywayConfig {

    /**
     * Ensure Flyway runs before JPA/Hibernate initializes
     * This bean is created early in the Spring lifecycle
     */
    @Bean
    public Flyway flyway(DataSource dataSource) {
        Flyway flyway = Flyway.configure()
                .dataSource(dataSource)
                .locations("classpath:db/migration")
                .baselineOnMigrate(true)
                .baselineVersion("0")
                .validateOnMigrate(false)  // Disable validation to allow modified migrations
                .load();
        
        // Run migrations immediately
        flyway.migrate();
        
        return flyway;
    }
}
