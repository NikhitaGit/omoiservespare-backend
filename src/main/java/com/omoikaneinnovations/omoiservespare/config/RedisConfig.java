package com.omoikaneinnovations.omoiservespare.config;

import io.lettuce.core.ClientOptions;
import io.lettuce.core.TimeoutOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceClientConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.*;

import java.time.Duration;

@Configuration
@ConditionalOnProperty(name = "spring.redis.enabled", havingValue = "true", matchIfMissing = false)
public class RedisConfig {

    @Value("${spring.data.redis.host:localhost}")
    private String redisHost;
    
    @Value("${spring.data.redis.port:6379}")
    private int redisPort;

    @Bean
    public LettuceConnectionFactory redisConnectionFactory() {
        // Configure client with aggressive timeouts
        ClientOptions clientOptions = ClientOptions.builder()
            .timeoutOptions(TimeoutOptions.enabled(Duration.ofSeconds(1)))
            .build();
        
        LettuceClientConfiguration clientConfig = LettuceClientConfiguration.builder()
            .commandTimeout(Duration.ofSeconds(1))
            .clientOptions(clientOptions)
            .build();
        
        RedisStandaloneConfiguration redisConfig = new RedisStandaloneConfiguration(redisHost, redisPort);
        LettuceConnectionFactory factory = new LettuceConnectionFactory(redisConfig, clientConfig);
        
        // Don't validate connection on startup
        factory.setValidateConnection(false);
        factory.setShareNativeConnection(false);
        
        return factory;
    }

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        template.setEnableDefaultSerializer(false);

        // Use String serializer for keys
        template.setKeySerializer(new StringRedisSerializer());
        
        // Use JdkSerializationRedisSerializer for values (recommended for Spring Boot 4.x)
        template.setValueSerializer(new JdkSerializationRedisSerializer());

        return template;
    }
}