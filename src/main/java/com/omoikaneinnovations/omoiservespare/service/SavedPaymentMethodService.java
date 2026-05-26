package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.SavedPaymentMethod;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.SavedPaymentMethodRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class SavedPaymentMethodService {

    private final SavedPaymentMethodRepository savedPaymentRepo;

    /**
     * Save a new payment method for customer
     */
    public SavedPaymentMethod savePaymentMethod(
            User customer,
            String methodType,
            String token,
            String lastFour,
            String expiryDate,
            Boolean isDefault) {

        // If setting as default, unset other defaults
        if (isDefault) {
            savedPaymentRepo.findByCustomerIdAndIsDefaultTrue(customer.getId())
                    .ifPresent(existing -> {
                        existing.setIsDefault(false);
                        savedPaymentRepo.save(existing);
                    });
        }

        SavedPaymentMethod method = new SavedPaymentMethod();
        method.setCustomer(customer);
        method.setMethodType(methodType);
        method.setToken(token);
        method.setLastFour(lastFour);
        method.setExpiryDate(expiryDate);
        method.setIsDefault(isDefault);
        method.setCreatedAt(LocalDateTime.now());

        SavedPaymentMethod saved = savedPaymentRepo.save(method);
        log.info("Payment method saved - Customer: {}, Type: {}, Last Four: {}", 
            customer.getId(), methodType, lastFour);

        return saved;
    }

    /**
     * Get all payment methods for customer
     */
    public List<SavedPaymentMethod> getCustomerPaymentMethods(Long customerId) {
        return savedPaymentRepo.findByCustomerId(customerId);
    }

    /**
     * Get default payment method for customer
     */
    public SavedPaymentMethod getDefaultPaymentMethod(Long customerId) {
        return savedPaymentRepo.findByCustomerIdAndIsDefaultTrue(customerId).orElse(null);
    }

    /**
     * Delete payment method
     */
    public void deletePaymentMethod(Long methodId) {
        savedPaymentRepo.deleteById(methodId);
        log.info("Payment method deleted - Method ID: {}", methodId);
    }

    /**
     * Get payment method by token
     */
    public SavedPaymentMethod getPaymentMethodByToken(String token) {
        return savedPaymentRepo.findByToken(token).orElse(null);
    }

    /**
     * Set payment method as default
     */
    public void setAsDefault(Long methodId, Long customerId) {
        // Unset current default
        savedPaymentRepo.findByCustomerIdAndIsDefaultTrue(customerId)
                .ifPresent(existing -> {
                    existing.setIsDefault(false);
                    savedPaymentRepo.save(existing);
                });

        // Set new default
        savedPaymentRepo.findById(methodId).ifPresent(method -> {
            method.setIsDefault(true);
            savedPaymentRepo.save(method);
            log.info("Payment method set as default - Method ID: {}", methodId);
        });
    }
}