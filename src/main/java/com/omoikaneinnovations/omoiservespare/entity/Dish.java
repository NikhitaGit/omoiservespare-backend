package com.omoikaneinnovations.omoiservespare.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "dishes", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "base_dish_id", "name" })
})
public class Dish {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "base_dish_id", nullable = false)
    private BaseDish baseDish;

    @Column(nullable = false)
    private String name; // Variant name

    @Column(name = "is_active")
    private Boolean isActive = true;

    public Long getId() {
        return id;
    }

    public BaseDish getBaseDish() {
        return baseDish;
    }

    public void setBaseDish(BaseDish baseDish) {
        this.baseDish = baseDish;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean active) {
        isActive = active;
    }
}
