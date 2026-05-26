package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.CanteenResponseDTO;
import com.omoikaneinnovations.omoiservespare.entity.Canteen;
import com.omoikaneinnovations.omoiservespare.repository.CanteenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CanteenService {

    @Autowired
    private CanteenRepository canteenRepository;

    public List<CanteenResponseDTO> getAllActiveCanteens() {

        return canteenRepository
                .findByIsActiveTrue()
                .stream()
                .map(this::mapToDTO)
                .toList();
    }

    private CanteenResponseDTO mapToDTO(Canteen c) {
        return new CanteenResponseDTO(
                c.getId(),
                c.getName(),
                c.getPlace(),
                c.getPrepTime(),
                c.getRating(),
                c.getImageUrl()
        );
    }
}
