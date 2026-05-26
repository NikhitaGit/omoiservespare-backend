package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.RefreshToken;
import com.omoikaneinnovations.omoiservespare.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    Optional<RefreshToken> findByToken(String token);

    // 🔒 Global logout
    @Modifying
    @Transactional
    @Query("""
        UPDATE RefreshToken rt
        SET rt.revoked = true
        WHERE rt.user = :user
    """)
    void revokeAllByUser(@Param("user") User user);

    // 🔓 Single-device logout
    @Modifying
    @Transactional
    @Query("""
        UPDATE RefreshToken rt
        SET rt.revoked = true
        WHERE rt.user = :user
          AND rt.deviceId = :deviceId
    """)
    void revokeAllByUserAndDeviceId(
            @Param("user") User user,
            @Param("deviceId") String deviceId
    );
}

