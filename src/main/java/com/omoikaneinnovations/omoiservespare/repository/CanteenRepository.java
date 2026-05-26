package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.Canteen;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CanteenRepository extends JpaRepository<Canteen, Long> {

    List<Canteen> findByIsActiveTrue();
}
