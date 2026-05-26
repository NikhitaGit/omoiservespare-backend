package com.omoikaneinnovations.omoiservespare.dto;

import java.math.BigDecimal;

public class CanteenResponseDTO {

    private final Long id;
    private final String name;
    private final String place;
    private final String prepTime;
    private final BigDecimal rating;
    private final String imageUrl;

    public CanteenResponseDTO(
            Long id,
            String name,
            String place,
            String prepTime,
            BigDecimal rating,
            String imageUrl
    ) {
        this.id = id;
        this.name = name;
        this.place = place;
        this.prepTime = prepTime;
        this.rating = rating;
        this.imageUrl = imageUrl;
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public String getPlace() { return place; }
    public String getPrepTime() { return prepTime; }
    public BigDecimal getRating() { return rating; }
    public String getImageUrl() { return imageUrl; }
}
