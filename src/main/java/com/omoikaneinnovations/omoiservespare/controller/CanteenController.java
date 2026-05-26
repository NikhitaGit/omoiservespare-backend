package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.CanteenResponseDTO;
import com.omoikaneinnovations.omoiservespare.service.CanteenService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/canteens")
@CrossOrigin(origins = "*")
public class CanteenController {

    private final CanteenService canteenService;

    public CanteenController(CanteenService canteenService) {
        this.canteenService = canteenService;
    }

    @GetMapping
    public ResponseEntity<List<CanteenResponseDTO>> getAllCanteens() {
        return ResponseEntity.ok()
                .header("Cache-Control", "no-store")
                .body(canteenService.getAllActiveCanteens());
    }
}
