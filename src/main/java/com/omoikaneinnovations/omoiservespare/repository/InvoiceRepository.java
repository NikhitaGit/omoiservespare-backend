package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {
    
    List<Invoice> findByOrder_OrderCode(String orderCode);
    
    List<Invoice> findByCustomer_Id(Long customerId);
    
    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);
    
    @Query("SELECT COUNT(i) FROM Invoice i WHERE i.invoiceNumber LIKE :prefix%")
    long countByInvoiceNumberStartingWith(@Param("prefix") String prefix);
    
    List<Invoice> findByCanteenOrderId(Long canteenOrderId);
}