package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;

@Data
@Getter
@Setter
public class CouponValidationRequest {
    private String couponCode;
    private BigDecimal orderValue;
    private Long restaurantId;
}
