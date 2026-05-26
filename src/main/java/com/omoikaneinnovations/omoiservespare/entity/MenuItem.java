package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "menu_items", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "canteen_id", "dish_id" })
})
public class MenuItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "canteen_id", nullable = false)
    private Long canteenId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "canteen_id", nullable = false, insertable = false, updatable = false)
    private Canteen canteen;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dish_id", nullable = false)
    private Dish dish;

    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal price;

    @Column(name = "is_available")
    private Boolean isAvailable = true;

    @Column(name = "prep_min")
    private Integer prepMin;

    @Column(name = "override_image_url")
    private String overrideImageUrl;

    // ===== GETTERS & SETTERS =====

    public Long getId() {
        return id;
    }

    public Long getCanteenId() {
        return canteenId;
    }

    public void setCanteenId(Long canteenId) {
        this.canteenId = canteenId;
    }

    public Canteen getCanteen() {
        return canteen;
    }

    public void setCanteen(Canteen canteen) {
        this.canteen = canteen;
    }

    public Dish getDish() {
        return dish;
    }

    public void setDish(Dish dish) {
        this.dish = dish;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Boolean getIsAvailable() {
        return isAvailable;
    }

    public void setIsAvailable(Boolean available) {
        isAvailable = available;
    }

    public Integer getPrepMin() {
        return prepMin;
    }

    public void setPrepMin(Integer prepMin) {
        this.prepMin = prepMin;
    }

    public String getOverrideImageUrl() {
        return overrideImageUrl;
    }

    public void setOverrideImageUrl(String overrideImageUrl) {
        this.overrideImageUrl = overrideImageUrl;
    }

}