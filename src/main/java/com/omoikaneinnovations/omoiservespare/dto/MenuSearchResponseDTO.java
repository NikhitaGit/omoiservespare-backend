package com.omoikaneinnovations.omoiservespare.dto;

import java.math.BigDecimal;

public class MenuSearchResponseDTO {

    private Long id;
    private Long canteenId;
    private String canteenName;
    private String itemName;
    private BigDecimal price;

    public MenuSearchResponseDTO(
            Long id,
            Long canteenId,
            String canteenName,
            String itemName,
            BigDecimal price) {
        this.id = id;
        this.canteenId = canteenId;
        this.canteenName = canteenName;
        this.itemName = itemName;
        this.price = price;
    }

    public Long getId() {
        return id;
    }

    public Long getCanteenId() {
        return canteenId;
    }

    public String getCanteenName() {
        return canteenName;
    }

    public String getItemName() {
        return itemName;
    }

    public BigDecimal getPrice() {
        return price;
    }
}
