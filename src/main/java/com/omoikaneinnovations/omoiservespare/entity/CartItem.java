package com.omoikaneinnovations.omoiservespare.entity;

import java.io.Serializable;

public class CartItem implements Serializable {

    private Long menuItemId;
    private String name;
    private Double price;
    private Integer quantity;
    private String imageUrl;

    public CartItem() {}

    public CartItem(Long menuItemId, String name, Double price, Integer quantity, String imageUrl) {
        this.menuItemId = menuItemId;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
    }

    public Long getMenuItemId() { return menuItemId; }
    public String getName() { return name; }
    public Double getPrice() { return price; }
    public Integer getQuantity() { return quantity; }
    public String getImageUrl() { return imageUrl; }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }
}