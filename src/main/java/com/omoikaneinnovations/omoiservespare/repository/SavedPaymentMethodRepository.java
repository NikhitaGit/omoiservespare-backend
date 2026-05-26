package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.SavedPaymentMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface SavedPaymentMethodRepository extends JpaRepository<SavedPaymentMethod, Long> {
    List<SavedPaymentMethod> findByCustomerId(Long customerId);
    Optional<SavedPaymentMethod> findByCustomerIdAndIsDefaultTrue(Long customerId);
    Optional<SavedPaymentMethod> findByToken(String token);
}