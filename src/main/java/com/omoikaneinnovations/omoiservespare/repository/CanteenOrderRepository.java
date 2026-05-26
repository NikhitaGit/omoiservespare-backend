package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.CanteenOrder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CanteenOrderRepository extends JpaRepository<CanteenOrder, Long> {

    List<CanteenOrder> findByCanteenIdOrderByCreatedAtDesc(Long canteenId);

}