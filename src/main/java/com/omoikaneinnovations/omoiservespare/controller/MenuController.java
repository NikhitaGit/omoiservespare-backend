package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.MenuItemResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.MenuSearchResponseDTO;
import com.omoikaneinnovations.omoiservespare.service.MenuService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/menu")
public class MenuController {

    @Autowired
    private MenuService menuService;

    @GetMapping("/{canteenId}")
    public List<MenuItemResponseDTO> getMenu(@PathVariable Long canteenId) {
        return menuService.getMenuByCanteen(canteenId);
    }

    @GetMapping("/search")
    public List<MenuSearchResponseDTO> search(
            @RequestParam String name,
            @RequestParam(required = false) String tag,
            @RequestParam(required = false) String category) {

        return menuService.searchMenu(name, tag, category);
    }

    // ✅ HOME endpoint
    @GetMapping("/home")
    public List<MenuItemResponseDTO> getHomeMenu() {
        return menuService.getHomeMenu();
    }

    // ✅ Get canteen availability count for an item
    @GetMapping("/availability/{itemName}")
    public Map<String, Object> getItemAvailability(@PathVariable String itemName) {
        return menuService.getItemAvailability(itemName);
    }
}
