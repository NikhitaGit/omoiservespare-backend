package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.OrderSequence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.util.Optional;

@Repository
public interface OrderSequenceRepository extends JpaRepository<OrderSequence, String> {
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT os FROM OrderSequence os WHERE os.paymentMethod = :paymentMethod")
    Optional<OrderSequence> findByPaymentMethodForUpdate(@Param("paymentMethod") String paymentMethod);
    
    @Modifying
    @Query("UPDATE OrderSequence os SET os.currentSequence = os.currentSequence + 1 WHERE os.paymentMethod = :paymentMethod")
    int incrementSequence(@Param("paymentMethod") String paymentMethod);
}