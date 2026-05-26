package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.entity.DeviceFingerprint;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DeviceFingerprintRepository extends JpaRepository<DeviceFingerprint, Long> {

    List<DeviceFingerprint> findByCustomerId(Long customerId);

    Optional<DeviceFingerprint> findByCustomerIdAndDeviceId(Long customerId, String deviceId);

    List<DeviceFingerprint> findByCustomerIdAndIsTrustedTrue(Long customerId);
}