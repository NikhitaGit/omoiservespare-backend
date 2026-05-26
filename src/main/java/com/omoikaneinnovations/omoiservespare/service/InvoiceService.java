package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.CanteenOrder;
import com.omoikaneinnovations.omoiservespare.entity.Invoice;
import com.omoikaneinnovations.omoiservespare.entity.Order;
import com.omoikaneinnovations.omoiservespare.repository.InvoiceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class InvoiceService {
    
    private final InvoiceRepository invoiceRepository;
    
    /**
     * Generate invoices when order is paid
     * Creates one invoice per canteen order
     */
    @Transactional
    public List<Invoice> generateInvoicesForOrder(Order order) {
        log.info("Generating invoices for order: {}", order.getOrderCode());
        List<Invoice> invoices = new ArrayList<>();
        
        // One invoice per canteen
        for (CanteenOrder canteenOrder : order.getCanteenOrders()) {
            Invoice invoice = new Invoice();
            
            // Generate unique invoice number: CAN-2026-03-00001
            invoice.setInvoiceNumber(generateInvoiceNumber("CAN"));
            invoice.setInvoiceType("CANTEEN");
            
            invoice.setOrder(order);
            invoice.setCanteenOrder(canteenOrder);
            invoice.setCanteenId(canteenOrder.getCanteenId());
            invoice.setCustomer(order.getCustomer());
            
            // Calculate GST amounts
            BigDecimal subtotal = canteenOrder.getSubtotal();
            BigDecimal gstRate = new BigDecimal("0.05"); // 5% GST
            BigDecimal totalGst = subtotal.multiply(gstRate);
            BigDecimal cgst = totalGst.divide(new BigDecimal("2"), 2, RoundingMode.HALF_UP);
            BigDecimal sgst = totalGst.divide(new BigDecimal("2"), 2, RoundingMode.HALF_UP);
            
            invoice.setSubtotal(subtotal);
            invoice.setCgst(cgst);
            invoice.setSgst(sgst);
            invoice.setTotalAmount(subtotal.add(cgst).add(sgst));
            
            invoice.setInvoiceDate(LocalDateTime.now());
            invoice.setPaymentStatus("PAID");
            
            invoice.setFromName("Omoi Servespare");
            invoice.setToName(getCanteenName(canteenOrder.getCanteenId()));
            
            Invoice saved = invoiceRepository.save(invoice);
            invoices.add(saved);
            
            log.info("Created invoice {} for canteen order {}", 
                saved.getInvoiceNumber(), canteenOrder.getId());
        }
        
        return invoices;
    }
    
    /**
     * Generate unique invoice number with format: PREFIX-YYYY-MM-NNNNN
     * Example: CAN-2026-03-00001
     */
    private String generateInvoiceNumber(String prefix) {
        LocalDate now = LocalDate.now();
        String yearMonth = String.format("%d-%02d", now.getYear(), now.getMonthValue());
        String searchPrefix = prefix + "-" + yearMonth;
        
        // Get count for this month
        long count = invoiceRepository.countByInvoiceNumberStartingWith(searchPrefix);
        
        return String.format("%s-%s-%05d", prefix, yearMonth, count + 1);
    }
    
    /**
     * Get canteen name by ID
     */
    private String getCanteenName(Long canteenId) {
        return switch (canteenId.intValue()) {
            case 1 -> "Main Canteen";
            case 2 -> "North Wing Canteen";
            case 3 -> "South Wing Canteen";
            case 4 -> "Cafeteria";
            default -> "Canteen " + canteenId;
        };
    }
    
    /**
     * Get all invoices for an order
     */
    public List<Invoice> getInvoicesForOrder(String orderCode) {
        return invoiceRepository.findByOrder_OrderCode(orderCode);
    }
    
    /**
     * Get all invoices for a customer
     */
    public List<Invoice> getInvoicesForCustomer(Long customerId) {
        return invoiceRepository.findByCustomer_Id(customerId);
    }
    
    /**
     * Get a single invoice by invoice number
     */
    public Invoice getInvoiceByNumber(String invoiceNumber) {
        return invoiceRepository.findByInvoiceNumber(invoiceNumber)
            .orElseThrow(() -> new RuntimeException("Invoice not found: " + invoiceNumber));
    }
}