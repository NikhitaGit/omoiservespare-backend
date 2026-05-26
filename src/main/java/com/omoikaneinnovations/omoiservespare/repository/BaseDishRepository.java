package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.BaseDish;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BaseDishRepository extends JpaRepository<BaseDish, Long> {

    Optional<BaseDish> findByNameIgnoreCase(String name);
}
