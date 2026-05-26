package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.HREmployeeDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;

import java.util.Optional;

@Service
public class HRApiService {

    private static final Logger logger = LoggerFactory.getLogger(HRApiService.class);

    @Value("${hr.api.base-url:https://api.hrcompany.com/v1}")
    private String hrApiBaseUrl;

    @Value("${hr.api.token:demo-token}")
    private String hrApiToken;

    @Value("${hr.api.enabled:false}")
    private boolean hrApiEnabled;

    private final RestTemplate restTemplate;
    private final MockHRDataService mockHRDataService;

    public HRApiService(RestTemplate restTemplate, MockHRDataService mockHRDataService) {
        this.restTemplate = restTemplate;
        this.mockHRDataService = mockHRDataService;
    }

    /**
     * Fetch employee data from HR system by email
     */
    public Optional<HREmployeeDTO> getEmployeeByEmail(String email) {
        if (!hrApiEnabled) {
            logger.info("HR API is disabled, using mock HR data service for email: {}", email);
            return mockHRDataService.findByEmail(email);
        }

        try {
            logger.info("Fetching employee data from HR API for email: {}", email);

            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + hrApiToken);
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<String> entity = new HttpEntity<>(headers);

            String url = hrApiBaseUrl + "/employees/by-email/" + email;
            
            ResponseEntity<HREmployeeDTO> response = restTemplate.exchange(
                url, 
                HttpMethod.GET, 
                entity, 
                HREmployeeDTO.class
            );

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                logger.info("Successfully fetched employee data for: {}", email);
                return Optional.of(response.getBody());
            }

        } catch (HttpClientErrorException.NotFound e) {
            logger.warn("Employee not found in HR system for email: {}", email);
        } catch (Exception e) {
            logger.error("Error fetching employee data from HR API for email: " + email, e);
        }

        return Optional.empty();
    }

    /**
     * Fetch employee data from HR system by phone number
     */
    public Optional<HREmployeeDTO> getEmployeeByPhone(String phoneNumber) {
        if (!hrApiEnabled) {
            logger.info("HR API is disabled, using mock HR data service for phone: {}", phoneNumber);
            return mockHRDataService.findByPhone(phoneNumber);
        }

        try {
            logger.info("Fetching employee data from HR API for phone: {}", phoneNumber);

            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + hrApiToken);
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<String> entity = new HttpEntity<>(headers);

            String url = hrApiBaseUrl + "/employees/by-phone/" + phoneNumber;
            
            ResponseEntity<HREmployeeDTO> response = restTemplate.exchange(
                url, 
                HttpMethod.GET, 
                entity, 
                HREmployeeDTO.class
            );

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                logger.info("Successfully fetched employee data for phone: {}", phoneNumber);
                return Optional.of(response.getBody());
            }

        } catch (HttpClientErrorException.NotFound e) {
            logger.warn("Employee not found in HR system for phone: {}", phoneNumber);
        } catch (Exception e) {
            logger.error("Error fetching employee data from HR API for phone: " + phoneNumber, e);
        }

        return Optional.empty();
    }

    /**
     * Validate if company exists in HR system
     */
    public boolean validateCompany(String companyName) {
        if (!hrApiEnabled) {
            logger.info("HR API is disabled, using mock HR data service for company: {}", companyName);
            return mockHRDataService.isValidCompany(companyName);
        }

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + hrApiToken);
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<String> entity = new HttpEntity<>(headers);

            String url = hrApiBaseUrl + "/companies/validate/" + companyName;
            
            ResponseEntity<Boolean> response = restTemplate.exchange(
                url, 
                HttpMethod.GET, 
                entity, 
                Boolean.class
            );

            return response.getStatusCode() == HttpStatus.OK && 
                   Boolean.TRUE.equals(response.getBody());

        } catch (Exception e) {
            logger.error("Error validating company in HR API: " + companyName, e);
            return false;
        }
    }
}