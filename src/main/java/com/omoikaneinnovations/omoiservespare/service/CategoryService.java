package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.CategoryResponseDTO;
import com.omoikaneinnovations.omoiservespare.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<CategoryResponseDTO> getAllActiveCategories() {
        return categoryRepository
                .findByIsActiveTrueOrderByIdAsc()
                .stream()
                .map(c -> new CategoryResponseDTO(
                        c.getId(),
                        c.getName()))
                .toList();
    }
}
