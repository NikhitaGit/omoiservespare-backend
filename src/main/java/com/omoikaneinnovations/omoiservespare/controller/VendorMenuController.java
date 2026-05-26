package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.MenuItemRequestDTO;
import com.omoikaneinnovations.omoiservespare.dto.MenuItemResponseDTO;
import com.omoikaneinnovations.omoiservespare.entity.*;
import com.omoikaneinnovations.omoiservespare.repository.*;
import com.omoikaneinnovations.omoiservespare.service.ExcelMenuService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.multipart.MultipartFile;
import java.util.Map;
import java.util.List;
import com.cloudinary.Cloudinary;
import java.io.IOException;

@RestController
@RequestMapping("/api/vendor/menu")
@CrossOrigin(origins = "*")
public class VendorMenuController {

    @Autowired
private Cloudinary cloudinary;

    @Autowired
    private MenuItemRepository menuItemRepository;

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private BaseDishRepository baseDishRepository;

    @Autowired
    private ExcelMenuService excelMenuService;

    // ===============================
    // GET MENU BY CANTEEN
    // ===============================
    @GetMapping("/{canteenId}")
    public List<MenuItemResponseDTO> getMenu(
            @PathVariable Long canteenId) {

        return menuItemRepository
                .findByCanteenId(canteenId)
                .stream()
                .map(MenuItemResponseDTO::new)
                .toList();
    }

    // ===============================
    // CREATE ITEM
    // ===============================
    @PostMapping("/{canteenId}")
    public ResponseEntity<?> createItem(
            @PathVariable Long canteenId,
            @RequestBody MenuItemRequestDTO dto) {

        BaseDish baseDish = baseDishRepository
                .findByNameIgnoreCase(dto.getName())
                .orElseThrow(() ->
                        new RuntimeException("BaseDish not found. Create BaseDish first."));

        Dish dish = dishRepository
                .findByBaseDishAndNameIgnoreCase(baseDish, dto.getName())
                .orElseGet(() -> {
                    Dish d = new Dish();
                    d.setBaseDish(baseDish);
                    d.setName(dto.getName());
                    return dishRepository.save(d);
                });

        MenuItem item = new MenuItem();
        item.setCanteenId(canteenId);
        item.setDish(dish);
        item.setPrice(dto.getPrice());
        item.setPrepMin(dto.getPrepMin());
        item.setIsAvailable(dto.getIsAvailable());

        menuItemRepository.save(item);

        return ResponseEntity.ok().build();
    }

    // ===============================
    // UPDATE ITEM
    // ===============================
    @PutMapping("/{menuItemId}")
    public ResponseEntity<?> updateItem(
            @PathVariable Long menuItemId,
            @RequestBody MenuItemRequestDTO dto) {

        MenuItem item = menuItemRepository.findById(menuItemId)
                .orElseThrow();

        item.setPrice(dto.getPrice());
        item.setPrepMin(dto.getPrepMin());
        item.setIsAvailable(dto.getIsAvailable());

        menuItemRepository.save(item);

        return ResponseEntity.ok().build();
    }

    // ===============================
    // DELETE ITEM
    // ===============================
    @DeleteMapping("/{menuItemId}")
    public ResponseEntity<?> deleteItem(
            @PathVariable Long menuItemId) {

        menuItemRepository.deleteById(menuItemId);
        return ResponseEntity.ok().build();
    }

    // ===============================
    // TOGGLE AVAILABILITY
    // ===============================
    @PostMapping("/{menuItemId}/availability")
    public ResponseEntity<?> toggleAvailability(
            @PathVariable Long menuItemId) {

        MenuItem item = menuItemRepository.findById(menuItemId)
                .orElseThrow();

        item.setIsAvailable(!item.getIsAvailable());
        menuItemRepository.save(item);

        return ResponseEntity.ok().build();
    }

    // ===============================
    // EXCEL UPLOAD
    // ===============================
    @PostMapping("/upload/{canteenId}")
    public ResponseEntity<?> uploadMenuExcel(
            @PathVariable Long canteenId,
            @RequestParam("file") MultipartFile file) {

        excelMenuService.uploadMenuExcel(canteenId, file);
        return ResponseEntity.ok("Menu uploaded successfully");
    }

    @PostMapping("/{id}/upload-image")
public ResponseEntity<?> uploadImage(
        @PathVariable Long id,
        @RequestParam("image") MultipartFile image) throws IOException {

    MenuItem item = menuItemRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Menu item not found"));

    // Upload to Cloudinary (or local storage)
    Map uploadResult = cloudinary.uploader().upload(image.getBytes(), Map.of());

    String imageUrl = uploadResult.get("secure_url").toString();

    item.setOverrideImageUrl(imageUrl);

    menuItemRepository.save(item);

    return ResponseEntity.ok(Map.of("imageUrl", imageUrl));
}
}
