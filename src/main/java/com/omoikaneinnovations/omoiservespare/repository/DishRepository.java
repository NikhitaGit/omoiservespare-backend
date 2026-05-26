package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.BaseDish;
import com.omoikaneinnovations.omoiservespare.entity.Dish;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DishRepository extends JpaRepository<Dish, Long> {

    Optional<Dish> findByBaseDishAndNameIgnoreCase(BaseDish baseDish, String name);

}
