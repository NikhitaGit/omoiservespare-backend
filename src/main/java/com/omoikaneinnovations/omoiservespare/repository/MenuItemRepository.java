package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.dto.MenuSearchResponseDTO;
import com.omoikaneinnovations.omoiservespare.entity.FoodType;
import com.omoikaneinnovations.omoiservespare.entity.MenuItem;
import com.omoikaneinnovations.omoiservespare.entity.BaseDish;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface MenuItemRepository extends JpaRepository<MenuItem, Long> {

    List<MenuItem> findByCanteenId(Long canteenId);

    Optional<MenuItem> findByCanteenIdAndDishId(Long canteenId, Long dishId);

 @Query("""
    SELECT DISTINCT new com.omoikaneinnovations.omoiservespare.dto.MenuSearchResponseDTO(
        m.id,
        c2.id,
        c2.name,
        d.name,
        m.price
    )
    FROM MenuItem m
    JOIN m.dish d
    JOIN d.baseDish bd
    JOIN bd.categories c
    JOIN Canteen c2 ON m.canteenId = c2.id
    WHERE LOWER(bd.name) LIKE LOWER(CONCAT('%', :name, '%'))
    AND (:foodType IS NULL OR bd.foodType = :foodType)
    AND (:category IS NULL OR :category = '' OR LOWER(c.name) = LOWER(:category))
    AND m.isAvailable = true
    ORDER BY c2.id ASC
""")

    List<MenuSearchResponseDTO> searchItems(
            String name,
            FoodType foodType,
            String category);

    void deleteByCanteenIdAndDishIdNotIn(Long canteenId, List<Long> dishIds);

    // ✅ Find menu items by base dish name (for availability check)
    @Query("""
        SELECT m FROM MenuItem m
        JOIN m.dish d
        JOIN d.baseDish bd
        WHERE LOWER(bd.name) = LOWER(:dishName)
        AND m.isAvailable = true
    """)
    List<MenuItem> findByDishNameAndAvailable(String dishName);

    // ✅ CORRECT: Fetch only distinct base dishes
 @Query("""
    SELECT DISTINCT bd
    FROM MenuItem m
    JOIN m.dish d
    JOIN d.baseDish bd
    JOIN bd.categories c
    WHERE m.isAvailable = true
    AND bd.isActive = true
""")
List<BaseDish> findAllAvailableBaseDishes();


}
