package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface CouponRepository extends JpaRepository<Coupon, Long> {
    
    Optional<Coupon> findByCode(String code);
    
    @Query("SELECT c FROM Coupon c WHERE c.isActive = true " +
           "AND c.startDate <= :now AND c.endDate >= :now")
    List<Coupon> findActiveCoupons(LocalDateTime now);
    
    @Query("SELECT c FROM Coupon c WHERE c.isActive = true " +
           "AND c.startDate <= :now AND c.endDate >= :now " +
           "AND c.code = :code")
    Optional<Coupon> findActiveByCode(String code, LocalDateTime now);
}
