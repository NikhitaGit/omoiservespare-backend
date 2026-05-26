package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.MenuItemResponseDTO;
import com.omoikaneinnovations.omoiservespare.dto.MenuSearchResponseDTO;
import com.omoikaneinnovations.omoiservespare.entity.BaseDish;
import com.omoikaneinnovations.omoiservespare.entity.Category;
import com.omoikaneinnovations.omoiservespare.entity.FoodType;
import com.omoikaneinnovations.omoiservespare.entity.MenuItem;
import com.omoikaneinnovations.omoiservespare.repository.MenuItemRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class MenuService {

    @Autowired
    private MenuItemRepository menuItemRepository;

    // ===============================
    // CANTEEN MENU
    // ===============================
    public List<MenuItemResponseDTO> getMenuByCanteen(Long canteenId) {
        return menuItemRepository
                .findByCanteenId(canteenId)
                .stream()
                .filter(MenuItem::getIsAvailable)
                .map(MenuItemResponseDTO::new)
                .toList();
    }

    // ===============================
    // SEARCH
    // ===============================
    public List<MenuSearchResponseDTO> searchMenu(
            String name,
            String tag,
            String category) {

        FoodType foodType = null;

        if (tag != null && !tag.isBlank()) {
            foodType = FoodType.valueOf(tag.toUpperCase());
        }

        return menuItemRepository.searchItems(name, foodType, category);
    }

    // ===============================
    // HOME (Multi-category support)
    // ===============================
    public List<MenuItemResponseDTO> getHomeMenu() {

        List<BaseDish> baseDishes =
                menuItemRepository.findAllAvailableBaseDishes();

       return baseDishes.stream()
        .map(bd -> new MenuItemResponseDTO(
                bd.getId(),
                null,
                bd.getName(),
                bd.getCategories()
                        .stream()
                        .map(Category::getName)
                        .collect(Collectors.toList()),
                null,
                null,
                bd.getFoodType(),
                null,                       // ✅ isAvailable (not relevant for home)
                bd.getDefaultImageUrl(),
                null
        ))
        .toList();

    }

    // ===============================
    // ITEM AVAILABILITY (Single Canteen Check)
    // ===============================
    public Map<String, Object> getItemAvailability(String itemName) {
        List<MenuItem> items = menuItemRepository.findByDishNameAndAvailable(itemName);
        
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("itemName", itemName);
        result.put("canteenCount", items.size());
        
        if (items.size() == 1) {
            MenuItem item = items.get(0);
            result.put("canteenId", item.getCanteen().getId());
            result.put("canteenName", item.getCanteen().getName());
            result.put("menuItemId", item.getId());
            result.put("price", item.getPrice());
        }
        
        return result;
    }
}
