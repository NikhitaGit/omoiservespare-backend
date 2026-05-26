package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.entity.BaseDish;
import com.omoikaneinnovations.omoiservespare.entity.Dish;
import com.omoikaneinnovations.omoiservespare.entity.FoodType;
import com.omoikaneinnovations.omoiservespare.entity.MenuItem;
import com.omoikaneinnovations.omoiservespare.repository.DishRepository;
import com.omoikaneinnovations.omoiservespare.repository.MenuItemRepository;
import org.apache.poi.ss.usermodel.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import com.omoikaneinnovations.omoiservespare.repository.BaseDishRepository;
import java.io.InputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class ExcelMenuService {

    @Autowired
    private MenuItemRepository menuItemRepository;

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private BaseDishRepository baseDishRepository;

    @Transactional
    public void uploadMenuExcel(Long canteenId, MultipartFile file) {

        List<Long> excelDishIds = new ArrayList<>();

        try (InputStream is = file.getInputStream()) {

            Workbook workbook = WorkbookFactory.create(is);
            Sheet sheet = workbook.getSheetAt(0);

            List<BaseDish> allBaseDishes = baseDishRepository.findAll();

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {

                Row row = sheet.getRow(i);
                if (row == null) continue;

                String name = getString(row.getCell(0));
                if (name == null || name.isBlank()) continue;

                BigDecimal price = getDecimal(row.getCell(2));
                Boolean available = getBoolean(row.getCell(3));
                Integer prepMin = getInteger(row.getCell(4));
                String overrideImageUrl = getString(row.getCell(6));

                // 🔥 1️⃣ MATCH EXISTING BASE DISH
                BaseDish baseDish = allBaseDishes.stream()
                        .filter(bd -> 
                            name.toLowerCase()
                                .contains(bd.getName().toLowerCase()))
                        .findFirst()
                        .orElseThrow(() ->
                            new RuntimeException(
                                "No BaseDish found for: " + name
                            ));

                // 🔥 2️⃣ CREATE OR FIND VARIANT DISH
                Dish dish = dishRepository
                        .findByBaseDishAndNameIgnoreCase(baseDish, name)
                        .orElseGet(() -> {
                            Dish d = new Dish();
                            d.setBaseDish(baseDish);
                            d.setName(name);
                            d.setIsActive(true);
                            return dishRepository.save(d);
                        });

                excelDishIds.add(dish.getId());

                // 🔥 3️⃣ CREATE OR UPDATE MENU ITEM
                MenuItem item = menuItemRepository
                        .findByCanteenIdAndDishId(canteenId, dish.getId())
                        .orElse(new MenuItem());

                item.setCanteenId(canteenId);
                item.setDish(dish);
                item.setPrice(price);
                item.setIsAvailable(available);
                item.setPrepMin(prepMin);
                item.setOverrideImageUrl(overrideImageUrl);

                menuItemRepository.save(item);
            }

            // 🔥 4️⃣ DELETE REMOVED ITEMS
            if (!excelDishIds.isEmpty()) {
                menuItemRepository.deleteByCanteenIdAndDishIdNotIn(
                        canteenId,
                        excelDishIds
                );
            }

        } catch (Exception e) {
            throw new RuntimeException("Excel upload failed", e);
        }
    }

 
    // ===================== HELPERS =====================

    private String getString(Cell cell) {
        if (cell == null)
            return null;

        if (cell.getCellType() == CellType.STRING)
            return cell.getStringCellValue().trim();

        return cell.toString().trim();
    }

    private BigDecimal getDecimal(Cell cell) {
        if (cell == null)
            return BigDecimal.ZERO;

        if (cell.getCellType() == CellType.NUMERIC)
            return BigDecimal.valueOf(cell.getNumericCellValue());

        try {
            return new BigDecimal(cell.toString());
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private Boolean getBoolean(Cell cell) {
        if (cell == null)
            return true;

        if (cell.getCellType() == CellType.BOOLEAN)
            return cell.getBooleanCellValue();

        String value = cell.toString().trim().toLowerCase();
        return value.equals("yes") || value.equals("true") || value.equals("1");
    }

    private Integer getInteger(Cell cell) {
        if (cell == null)
            return 0;

        if (cell.getCellType() == CellType.NUMERIC)
            return (int) cell.getNumericCellValue();

        try {
            return Integer.parseInt(cell.toString());
        } catch (Exception e) {
            e.printStackTrace(); // VERY IMPORTANT
            throw new RuntimeException("Excel upload failed", e);
        }
    }

    private FoodType getFoodType(Cell cell) {
        if (cell == null)
            return null;

        String value = cell.toString().trim().toLowerCase();

        switch (value) {
            case "veg":
                return FoodType.VEG;
            case "non-veg":
            case "non veg":
            case "non_veg":
                return FoodType.NON_VEG;
            case "egg":
                return FoodType.EGG;
            default:
                return FoodType.VEG;
        }
    }
}
