package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.UserAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserAddressRepository extends JpaRepository<UserAddress, Long> {

    /**
     * Find all addresses for a specific user
     */
    @Query("SELECT ua FROM UserAddress ua WHERE ua.user.id = :userId ORDER BY ua.isDefault DESC, ua.createdAt DESC")
    List<UserAddress> findByUserIdOrderByIsDefaultDescCreatedAtDesc(@Param("userId") Long userId);

    /**
     * Find default address for a user
     */
    @Query("SELECT ua FROM UserAddress ua WHERE ua.user.id = :userId AND ua.isDefault = true")
    Optional<UserAddress> findByUserIdAndIsDefaultTrue(@Param("userId") Long userId);

    /**
     * Check if user has any addresses
     */
    @Query("SELECT COUNT(ua) > 0 FROM UserAddress ua WHERE ua.user.id = :userId")
    boolean existsByUserId(@Param("userId") Long userId);

    /**
     * Count addresses for a user
     */
    @Query("SELECT COUNT(ua) FROM UserAddress ua WHERE ua.user.id = :userId")
    long countByUserId(@Param("userId") Long userId);

    /**
     * Reset all default flags for a user (before setting a new default)
     */
    @Modifying
    @Query("UPDATE UserAddress ua SET ua.isDefault = false WHERE ua.user.id = :userId")
    void resetDefaultForUser(@Param("userId") Long userId);

    /**
     * Find address by ID and user ID (for security)
     */
    @Query("SELECT ua FROM UserAddress ua WHERE ua.id = :id AND ua.user.id = :userId")
    Optional<UserAddress> findByIdAndUserId(@Param("id") Long id, @Param("userId") Long userId);

    /**
     * Delete address by ID and user ID (for security)
     */
    @Modifying
    @Query("DELETE FROM UserAddress ua WHERE ua.id = :id AND ua.user.id = :userId")
    void deleteByIdAndUserId(@Param("id") Long id, @Param("userId") Long userId);
}
