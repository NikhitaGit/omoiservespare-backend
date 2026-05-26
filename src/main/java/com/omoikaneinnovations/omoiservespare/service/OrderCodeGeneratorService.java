package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.OrderSequence;
import com.omoikaneinnovations.omoiservespare.repository.OrderSequenceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderCodeGeneratorService {
    
    private final OrderSequenceRepository orderSequenceRepository;
    
    // Payment method to prefix mapping
    private static final Map<String, String> PAYMENT_METHOD_PREFIXES = Map.of(
        "ONLINE", "ONL",
        "WALLET", "WLT", 
        "CASH", "CSH"
    );
    
    /**
     * Generate order code based on payment method
     * @param paymentMethod The payment method (ONLINE, WALLET, CASH)
     * @return Formatted order code (e.g., ONL0001, WLT0001, CSH0001)
     */
    @Transactional
    public String generateOrderCode(String paymentMethod) {
        // Normalize payment method
        String normalizedPaymentMethod = normalizePaymentMethod(paymentMethod);
        
        // Get or create sequence for this payment method
        OrderSequence sequence = orderSequenceRepository.findByPaymentMethodForUpdate(normalizedPaymentMethod)
                .orElseGet(() -> {
                    log.info("Creating new order sequence for payment method: {}", normalizedPaymentMethod);
                    OrderSequence newSequence = new OrderSequence();
                    newSequence.setPaymentMethod(normalizedPaymentMethod);
                    newSequence.setCurrentSequence(0L);
                    return orderSequenceRepository.save(newSequence);
                });
        
        // Increment sequence
        sequence.setCurrentSequence(sequence.getCurrentSequence() + 1);
        orderSequenceRepository.save(sequence);
        
        // Generate formatted order code
        String prefix = PAYMENT_METHOD_PREFIXES.get(normalizedPaymentMethod);
        String orderCode = String.format("%s%04d", prefix, sequence.getCurrentSequence());
        
        log.info("Generated order code: {} for payment method: {}", orderCode, normalizedPaymentMethod);
        return orderCode;
    }
    
    /**
     * Normalize payment method string to standard format
     */
    private String normalizePaymentMethod(String paymentMethod) {
        if (paymentMethod == null) {
            return "ONLINE"; // Default to online
        }
        
        String normalized = paymentMethod.toUpperCase().trim();
        
        // Map various payment method strings to our standard categories
        switch (normalized) {
            case "CARD":
            case "UPI":
            case "NETBANKING":
            case "RAZORPAY":
            case "PHONEPE":
            case "PAYTM":
            case "GPAY":
            case "ONLINE":
                return "ONLINE";
                
            case "WALLET":
            case "DIGITAL_WALLET":
            case "E_WALLET":
                return "WALLET";
                
            case "CASH":
            case "COD":
            case "CASH_ON_DELIVERY":
                return "CASH";
                
            default:
                log.warn("Unknown payment method: {}, defaulting to ONLINE", paymentMethod);
                return "ONLINE";
        }
    }
    
    /**
     * Get the next sequence number for a payment method (for preview purposes)
     */
    @Transactional(readOnly = true)
    public Long getNextSequenceNumber(String paymentMethod) {
        String normalizedPaymentMethod = normalizePaymentMethod(paymentMethod);
        return orderSequenceRepository.findById(normalizedPaymentMethod)
                .map(seq -> seq.getCurrentSequence() + 1)
                .orElse(1L);
    }
}