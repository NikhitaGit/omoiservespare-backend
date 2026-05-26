package com.omoikaneinnovations.omoiservespare.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

import com.omoikaneinnovations.omoiservespare.entity.Category;
import com.omoikaneinnovations.omoiservespare.entity.FoodType;
import com.omoikaneinnovations.omoiservespare.entity.MenuItem;
import java.util.stream.Collectors;


public class MenuItemResponseDTO {

    private Long id;
    private Long canteenId;
    private String name;

    // 🔥 UPDATED: Multi-category support
    private List<String> categories;

    private BigDecimal price;
    private Integer prepMin;
    private FoodType foodType;
    private Boolean isAvailable;
    private String defaultImageUrl;
    private String overrideImageUrl;

    // ==========================================
    // FULL CONSTRUCTOR
    // ==========================================
    public MenuItemResponseDTO(
            Long id,
            Long canteenId,
            String name,
            List<String> categories,
            BigDecimal price,
            Integer prepMin,
            FoodType foodType,
            Boolean isAvailable,
            String defaultImageUrl,
            String overrideImageUrl) {

        this.id = id;
        this.canteenId = canteenId;
        this.name = name;
        this.categories = categories;
        this.price = price;
        this.prepMin = prepMin;
        this.foodType = foodType;
        this.isAvailable = isAvailable;
        this.defaultImageUrl = defaultImageUrl;
        this.overrideImageUrl = overrideImageUrl;
    }

    // ==========================================
    // ENTITY CONSTRUCTOR (USED IN SERVICE)
    // ==========================================
    public MenuItemResponseDTO(MenuItem item) {

        this.id = item.getId();
        this.canteenId = item.getCanteenId();
        this.name = item.getDish().getName();

        // 🔥 Map multiple categories safely
        this.categories = item.getDish()
                .getBaseDish()
                .getCategories()
                .stream()
                .map(Category::getName)
                .collect(Collectors.toList());

        this.isAvailable = item.getIsAvailable();
        this.foodType = item.getDish()
                .getBaseDish()
                .getFoodType();

        this.defaultImageUrl = item.getDish()
                .getBaseDish()
                .getDefaultImageUrl();

        this.price = item.getPrice();
        this.prepMin = item.getPrepMin();
        this.overrideImageUrl = item.getOverrideImageUrl();
    }

    // ==========================================
    // GETTERS
    // ==========================================

    public Long getId() {
        return id;
    }

    public Long getCanteenId() {
        return canteenId;
    }

    public String getName() {
        return name;
    }

    public List<String> getCategories() {
        return categories;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public Integer getPrepMin() {
        return prepMin;
    }

    public FoodType getFoodType() {
        return foodType;
    }

    public String getDefaultImageUrl() {
        return defaultImageUrl;
    }

    public String getOverrideImageUrl() {
        return overrideImageUrl;
    }

    public Boolean getIsAvailable() {
    return isAvailable;
}

}
