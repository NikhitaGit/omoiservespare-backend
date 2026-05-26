package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.PaymentVelocity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PaymentVelocityRepository extends JpaRepository<PaymentVelocity, Long> {

    Optional<PaymentVelocity> findByCustomerId(Long customerId);
}