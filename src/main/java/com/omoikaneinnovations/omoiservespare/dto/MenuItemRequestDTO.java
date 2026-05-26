package com.omoikaneinnovations.omoiservespare.dto;

import java.math.BigDecimal;

public class MenuItemRequestDTO {

    private String name;
    private BigDecimal price;
    private Integer prepMin;
    private Boolean isAvailable;

    public String getName() {
        return name;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public Integer getPrepMin() {
        return prepMin;
    }

    public Boolean getIsAvailable() {
        return isAvailable;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public void setPrepMin(Integer prepMin) {
        this.prepMin = prepMin;
    }

    public void setIsAvailable(Boolean isAvailable) {
        this.isAvailable = isAvailable;
    }
}
