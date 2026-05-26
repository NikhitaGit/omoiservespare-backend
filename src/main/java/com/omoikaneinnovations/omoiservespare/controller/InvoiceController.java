package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.InvoiceDTO;
import com.omoikaneinnovations.omoiservespare.dto.InvoiceItemDTO;
import com.omoikaneinnovations.omoiservespare.entity.Invoice;
import com.omoikaneinnovations.omoiservespare.service.InvoiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/invoices")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class InvoiceController {
    
    private final InvoiceService invoiceService;
    
    /**
     * Get all invoices for a specific order
     */
    @GetMapping("/order/{orderCode}")
    public ResponseEntity<List<InvoiceDTO>> getInvoicesForOrder(@PathVariable String orderCode) {
        List<Invoice> invoices = invoiceService.getInvoicesForOrder(orderCode);
        List<InvoiceDTO> dtos = invoices.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }
    
    /**
     * Get all invoices for a customer
     */
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<InvoiceDTO>> getInvoicesForCustomer(@PathVariable Long customerId) {
        List<Invoice> invoices = invoiceService.getInvoicesForCustomer(customerId);
        List<InvoiceDTO> dtos = invoices.stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }
    
    /**
     * Get a single invoice by invoice number
     */
    @GetMapping("/{invoiceNumber}")
    public ResponseEntity<InvoiceDTO> getInvoiceByNumber(@PathVariable String invoiceNumber) {
        Invoice invoice = invoiceService.getInvoiceByNumber(invoiceNumber);
        return ResponseEntity.ok(toDTO(invoice));
    }
    
    /**
     * Convert Invoice entity to DTO
     */
    private InvoiceDTO toDTO(Invoice invoice) {
        InvoiceDTO dto = new InvoiceDTO();
        dto.setInvoiceNumber(invoice.getInvoiceNumber());
        dto.setInvoiceType(invoice.getInvoiceType());
        dto.setCanteenName(invoice.getToName());
        dto.setSubtotal(invoice.getSubtotal());
        dto.setCgst(invoice.getCgst());
        dto.setSgst(invoice.getSgst());
        dto.setTotalAmount(invoice.getTotalAmount());
        dto.setInvoiceDate(invoice.getInvoiceDate());
        dto.setPaymentStatus(invoice.getPaymentStatus());
        dto.setFromName(invoice.getFromName());
        dto.setToName(invoice.getToName());
        
        // Add line items from canteen order
        if (invoice.getCanteenOrder() != null && invoice.getCanteenOrder().getItems() != null) {
            List<InvoiceItemDTO> items = invoice.getCanteenOrder().getItems()
                .stream()
                .map(item -> new InvoiceItemDTO(
                    item.getName(),
                    item.getQuantity(),
                    item.getPrice()
                ))
                .collect(Collectors.toList());
            dto.setItems(items);
        }
        
        return dto;
    }
}