package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class InvoiceDTO {
    private String invoiceNumber;
    private String invoiceType;
    private String canteenName;
    private BigDecimal subtotal;
    private BigDecimal cgst;
    private BigDecimal sgst;
    private BigDecimal totalAmount;
    private LocalDateTime invoiceDate;
    private String paymentStatus;
    private List<InvoiceItemDTO> items;
    private String fromName;
    private String toName;
}