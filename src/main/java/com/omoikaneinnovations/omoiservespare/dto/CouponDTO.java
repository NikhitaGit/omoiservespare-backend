package com.omoikaneinnovations.omoiservespare.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Getter
@Setter
public class CouponDTO {
    private Long id;
    private String code;
    private String description;
    private String discountType;
    private BigDecimal discountValue;
    private BigDecimal maxDiscount;
    private BigDecimal minOrderValue;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Integer perUserLimit;
    private String applicableOn;
    private Boolean isApplicable;
    private String notApplicableReason;
    private BigDecimal calculatedDiscount;
}
