package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "base_dishes", uniqueConstraints = {
        @UniqueConstraint(columnNames = "name")
})
public class BaseDish {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "food_type", nullable = false)
    private FoodType foodType;

    @Column(name = "default_image_url")
    private String defaultImageUrl;

    @Column(name = "is_active")
    private Boolean isActive = true;

    // 🔥 NEW: MANY TO MANY WITH CATEGORY
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "base_dish_categories",
            joinColumns = @JoinColumn(name = "base_dish_id"),
            inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    private List<Category> categories;

    @OneToMany(mappedBy = "baseDish", cascade = CascadeType.ALL)
    private List<Dish> variants;

    // ===== GETTERS & SETTERS =====

    public Long getId() { return id; }

    public String getName() { return name; }

    public void setName(String name) { this.name = name; }

    public FoodType getFoodType() { return foodType; }

    public void setFoodType(FoodType foodType) { this.foodType = foodType; }

    public String getDefaultImageUrl() { return defaultImageUrl; }

    public void setDefaultImageUrl(String defaultImageUrl) { this.defaultImageUrl = defaultImageUrl; }

    public Boolean getIsActive() { return isActive; }

    public void setIsActive(Boolean active) { isActive = active; }

    public List<Category> getCategories() { return categories; }

    public void setCategories(List<Category> categories) { this.categories = categories; }

    public List<Dish> getVariants() { return variants; }

    public void setVariants(List<Dish> variants) { this.variants = variants; }
}
