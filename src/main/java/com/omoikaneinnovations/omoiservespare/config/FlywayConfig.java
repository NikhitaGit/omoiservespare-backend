package com.omoikaneinnovations.omoiservespare.config;

import org.flywaydb.core.Flyway;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
@ConditionalOnProperty(name = "spring.flyway.enabled", havingValue = "true", matchIfMissing = true)
public class FlywayConfig {

    /**
     * Flyway configuration
     * Uses Spring Boot managed datasource
     * Only active when spring.flyway.enabled=true (default)
     */
    @Bean(initMethod = "migrate")
    public Flyway flyway(DataSource dataSource) {

        return Flyway.configure()
                .dataSource(dataSource)
                .locations("classpath:db/migration")
                .baselineOnMigrate(true)
                .baselineVersion("0")
                .validateOnMigrate(false)
                .load();
    }
}